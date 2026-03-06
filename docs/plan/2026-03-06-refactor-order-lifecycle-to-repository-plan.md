---
title: "refactor: move order lifecycle logic from bloc layer to order repository"
type: refactor
date: 2026-03-06
issue: https://github.com/VGVentures/very-yummy-coffee/issues/35
---

## Refactor: Move Order Lifecycle Logic to OrderRepository

## Overview

Order lifecycle management -- specifically `createOrder()` guard checks before adding items -- is duplicated across multiple blocs in three apps. This refactor moves that logic into `OrderRepository.addItemToCurrentOrder()` so it auto-creates an order when `currentOrderId` is null, eliminating redundant checks in the bloc layer.

## Problem Statement / Motivation

Three apps duplicate the same pattern:

```dart
// mobile_app & kiosk_app ItemDetailBloc (identical code)
if (_orderRepository.currentOrderId == null) {
  await _orderRepository.createOrder();
}
_orderRepository.addItemToCurrentOrder(...);
```

The POS app's `MenuBloc._onItemAdded` calls `addItemToCurrentOrder` without any guard -- if no order exists, the call silently no-ops and the item is lost.

This violates the principle that domain orchestration belongs in the repository, not in presentation-layer blocs. Moving the logic down:

- Eliminates duplication across 3 apps
- Fixes the silent item-loss bug in POS `MenuBloc`
- Makes the API harder to misuse (callers can't forget the guard)

## Proposed Solution

### Phase 1: Repository Change

**File:** `shared/order_repository/lib/src/order_repository.dart`

1. Change `addItemToCurrentOrder` from `void` to `Future<void>`
2. Add auto-create logic at the top:

```dart
Future<void> addItemToCurrentOrder({
  required String itemName,
  required int itemPrice,
  required String options,
  required int quantity,
}) async {
  if (_currentOrderId == null) {
    await createOrder();
  }
  _wsRpcClient.sendAction('addItemToOrder', {
    'orderId': currentOrderId,
    'lineItemId': _uuid.v4(),
    'itemName': itemName,
    'itemPrice': itemPrice,
    'options': options,
    'quantity': quantity,
  });
}
```

> **Concurrency note:** Although `addItemToCurrentOrder` is now `async`, `createOrder()` assigns `_currentOrderId` synchronously before yielding to the event loop. So even if two `addItemToCurrentOrder` calls interleave at the `await`, only the first will see `null`. Add a doc comment on `createOrder()` stating this invariant, and add `assert(_currentOrderId != null)` after the `await createOrder()` call as a safety net.

**Out of scope:** `updateItemQuantity` has the same `if (currentOrderId == null) return;` guard but auto-creating an order on quantity update is nonsensical -- left as-is.

### Phase 2: Remove Bloc Guards (mobile_app)

**File:** `applications/mobile_app/lib/item_detail/bloc/item_detail_bloc.dart`

- Remove the `if (_orderRepository.currentOrderId == null) { await _orderRepository.createOrder(); }` guard block
- Add `await` to the `addItemToCurrentOrder(...)` call

### Phase 3: Remove Bloc Guards (kiosk_app)

**File:** `applications/kiosk_app/lib/item_detail/bloc/item_detail_bloc.dart`

- Remove the `if (_orderRepository.currentOrderId == null) { await _orderRepository.createOrder(); }` guard block (identical to mobile_app)
- Add `await` to the `addItemToCurrentOrder(...)` call

### Phase 4: Update POS MenuBloc

**File:** `applications/pos_app/lib/menu/bloc/menu_bloc.dart`

The handler changes from fire-and-forget to async with error handling:

```dart
Future<void> _onItemAdded(MenuItemAdded event, Emitter<MenuState> emit) async {
  if (!event.item.available) return;
  try {
    await _orderRepository.addItemToCurrentOrder(
      itemName: event.item.name,
      itemPrice: event.item.price,
      options: '',
      quantity: 1,
    );
  } on Exception catch (_) {
    emit(state.copyWith(status: MenuStatus.failure));
  }
}
```

> **Note:** The `MenuSubscriptionRequested` stream continuously emits, so any `MenuStatus.failure` from a failed add is transient -- the next stream emission overwrites it with `success`. This is acceptable without an explicit recovery mechanism.

### Phase 5: Update Tests

#### 5a. Repository Tests

**File:** `shared/order_repository/test/src/order_repository_test.dart`

Add new test group for `addItemToCurrentOrder`:

- `auto-creates order when currentOrderId is null` -- verify `sendAction('createOrder', ...)` called first, then `sendAction('addItemToOrder', ...)`
- `does not create order when currentOrderId is non-null` -- verify only `sendAction('addItemToOrder', ...)`
- `sends correct payload` -- verify `itemName`, `itemPrice`, `options`, `quantity`, `lineItemId` (any string)
- `propagates exception when auto-create fails` -- verify the future completes with an error, and `sendAction('addItemToOrder', ...)` is never called

#### 5b. mobile_app ItemDetailBloc Tests

**File:** `applications/mobile_app/test/item_detail/bloc/item_detail_bloc_test.dart`

- Remove all `createOrder()` mock setups and `verify`/`verifyNever` assertions from add-to-cart tests
- Change `addItemToCurrentOrder` mock from void to `thenAnswer((_) async {})`
- Remove the test that verifies `createOrder` is skipped when `currentOrderId` is non-null (this logic is now internal to the repository)
- Update the failure test (currently throws from `createOrder()`) to throw from `addItemToCurrentOrder` instead -- otherwise it becomes a false-positive test

#### 5c. kiosk_app ItemDetailBloc Tests

**File:** `applications/kiosk_app/test/item_detail/bloc/item_detail_bloc_test.dart`

- Same changes as mobile_app: remove `createOrder` mocks/verifications, update `addItemToCurrentOrder` to async mock
- Update the failure test to throw from `addItemToCurrentOrder` instead of `createOrder()`

#### 5d. pos_app MenuBloc Tests

**File:** `applications/pos_app/test/menu/bloc/menu_bloc_test.dart`

- Change `addItemToCurrentOrder` mock from void to `thenAnswer((_) async {})`

#### 5e. pos_app OrderTicketBloc Tests

**File:** `applications/pos_app/test/order_ticket/bloc/order_ticket_bloc_test.dart`

- No changes needed (`createOrder` tests remain valid -- POS still uses explicit create)

### Phase 6: Verify CI

Run tests across all affected packages:

```sh
cd shared/order_repository && dart test
cd applications/mobile_app && flutter test
cd applications/kiosk_app && flutter test
cd applications/pos_app && flutter test
```

No `pubspec.yaml` changes, so `.github/update_github_actions.sh` is not needed.

## Technical Considerations

- **Signature change cascade:** `void` -> `Future<void>` on `addItemToCurrentOrder` affects all call sites and test mocks. This is the primary source of mechanical changes.
- **No new dependencies:** The refactor only moves existing logic; no new packages or APIs.
- **`clearCurrentOrder` calls left as-is:** These are intentional user-triggered actions (POS "Clear", kiosk "Done", reconnect cleanup). They belong in the calling code, not auto-managed.
- **POS `OrderTicketBloc` unchanged:** The "New Order" button still calls `createOrder()` explicitly. This is idempotent -- `addItemToCurrentOrder` skips auto-create if an order already exists.

## Acceptance Criteria

- [ ] `OrderRepository.addItemToCurrentOrder` auto-creates an order when `currentOrderId` is null
- [ ] `addItemToCurrentOrder` return type is `Future<void>`
- [ ] mobile_app `ItemDetailBloc` no longer checks `currentOrderId`/calls `createOrder()` before adding items
- [ ] kiosk_app `ItemDetailBloc` no longer checks `currentOrderId`/calls `createOrder()` before adding items
- [ ] POS `MenuBloc._onItemAdded` is async, awaits the call, and has error handling
- [ ] POS `OrderTicketBloc` is unchanged (explicit create still works)
- [ ] Repository tests cover auto-create, non-auto-create, and error-propagation paths
- [ ] All existing bloc tests updated for the new `Future<void>` signature
- [ ] All tests pass across `order_repository`, `mobile_app`, `kiosk_app`, `pos_app`
- [ ] `createOrder()` has a doc comment noting the synchronous `_currentOrderId` assignment invariant
- [ ] mobile_app and kiosk_app failure tests throw from `addItemToCurrentOrder` (not `createOrder`)

## Success Metrics

- Zero `createOrder()` guard checks in any bloc across all 3 apps
- POS `MenuBloc` no longer silently drops items when no order exists
- All tests green with no new test gaps

## Dependencies & Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Test mock update misses a call site | Low | CI catches it | Run full test suite before PR |
| POS UX surprise (auto-creating orders on item tap) | Low | Minor | Acceptable per design decision; "New Order" button still works |

## References & Research

- Current OrderRepository: `shared/order_repository/lib/src/order_repository.dart`
- mobile_app ItemDetailBloc: `applications/mobile_app/lib/item_detail/bloc/item_detail_bloc.dart:97-116`
- kiosk_app ItemDetailBloc: `applications/kiosk_app/lib/item_detail/bloc/item_detail_bloc.dart:97-116`
- POS MenuBloc: `applications/pos_app/lib/menu/bloc/menu_bloc.dart:49-57`
- POS OrderTicketBloc: `applications/pos_app/lib/order_ticket/bloc/order_ticket_bloc.dart:35-42`
- kiosk OrderCompleteBloc: `applications/kiosk_app/lib/order_complete/bloc/order_complete_bloc.dart:32-38`
- GitHub Issue: https://github.com/VGVentures/very-yummy-coffee/issues/35
