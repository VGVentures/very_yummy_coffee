---
title: "Simplicity Review: feat/pos-app plan"
date: 2026-03-03
reviewed_plan: docs/plan/2026-03-03-feat-pos-app-plan.md
---

# Simplicity Review: POS App Plan

## Simplification Analysis

### Core Purpose

Build a Flutter iPad POS screen that lets a cashier:
1. Browse the menu by category and tap items to add them to an order ticket.
2. Submit ("charge") the ticket, which routes the order to the KDS.
3. View in-progress and historical orders.

The app reuses all existing shared infrastructure — repositories, WS client, UI package, and the established AppBloc/router pattern from `kds_app`.

---

### Unnecessary Complexity Found

#### 1. `getAllMenuItems()` is not needed — use client-side filtering on the existing stream

**Plan location:** Phase 1 / Phase 3 / Critical Finding section.

The plan proposes adding a new `getAllMenuItems()` method to `MenuRepository` and subscribing to it via `Rx.combineLatest2(getMenuGroups(), getAllMenuItems(), ...)`.

`MenuRepository` already exposes `getMenuGroups()`, which returns a stream of all `MenuGroup` objects. Looking at `menu_repository.dart`, the `_MenuCache` internal class holds both `groups` and `items`. `getMenuItems(groupId)` calls `_menuSubject!.stream.map((cache) => cache.itemsForGroup(groupId))`.

`getMenuGroups()` already triggers `_initMenuIfNeeded()` and increments the listener count, so the WS subscription is already alive. Rather than adding `getAllMenuItems()` as a second stream, the `MenuBloc` can simply subscribe once to `getMenuGroups()` — which gives every group — and then derive items by calling `getMenuItems(groupId)` for each visible group, **or**, more simply, keep a single subscription and receive all items via a `getAllMenuItems()` stream.

However, the `combineLatest2` approach creates two separate listener-count increments from the same repository, which means two `doOnCancel` teardowns are needed. The simpler alternative is to add a single `getMenuGroupsWithItems()` stream that emits `_MenuCache` directly (or a thin wrapper), giving both groups and all items from one subscription and one stream. The `MenuBloc` can then do all its filtering locally.

Even simpler: since the plan says `MenuBloc` holds `allItems` and computes `visibleItems` as a computed getter filtering by `selectedGroupId`, the bloc can work from a single stream of all items. Adding `getAllMenuItems()` to the repository is fine, but the `combineLatest2` subscription pattern in the bloc creates two concurrent subscriptions from the same subject and doubles the ref-count management complexity. Replace this with a single subscription method.

**Suggested simplification:** Add one method `getMenuGroupsAndItems()` returning `Stream<({List<MenuGroup> groups, List<MenuItem> items})>` (or keep `getAllMenuItems()` + separate `getMenuGroups()` but subscribe to only one of them; the categories can be derived from items via `item.groupId`). Alternatively: subscribe only to `getAllMenuItems()` and derive group names from the already-loaded `MenuGroup` list obtained via a single initial `getMenuGroups()` call. Either approach eliminates the `combineLatest2`.

**Impact:** Removes `Rx.combineLatest2` dependency in the bloc; reduces the number of active stream subscriptions from 2 to 1; simplifies `MenuBloc._onSubscriptionRequested`.

---

#### 2. `navigateToOrderId` in `OrderTicketState` is a side-effect flag, not real state

**Plan location:** Phase 4 — `OrderTicketState`.

```dart
class OrderTicketState {
  final OrderTicketStatus status;
  final Order? order;
  final String? navigateToOrderId; // non-null triggers navigation
}
```

The plan uses a nullable `navigateToOrderId` field to signal navigation. This is the "flag field" anti-pattern for state management: the page has to check the field, act on it, and then the flag must be cleared or ignored on subsequent rebuilds. The `CheckoutBloc` in `mobile_app` uses `CheckoutStatus.success` to trigger navigation without a separate ID field — the `orderId` needed for the route is captured locally before calling `submitCurrentOrder()`. The `PosOrderPage` listener can capture and use the same local variable.

The same pattern works here: after `submitCurrentOrder()`, the bloc emits `status: success`. The `BlocListener` in `PosOrderPage` captures `orderRepository.currentOrderId` (captured *before* calling submit, stored as a local variable in the event handler) and performs `context.go('/pos-order-complete/$capturedId')`. No field on the state is needed.

**Suggested simplification:** Remove `navigateToOrderId` from `OrderTicketState`. Use `OrderTicketStatus.success` as the trigger, and have the page listener use the order ID that was previously captured. This matches exactly how `CheckoutBloc`/`CheckoutPage` handles it in the mobile app.

**Impact:** Removes one field from state; eliminates the need to clear/reset the flag after navigation; aligns with the established pattern.

---

#### 3. `navigateToNewOrder` in `PosOrderCompleteState` is a second instance of the same flag anti-pattern

**Plan location:** Phase 5 — `PosOrderCompleteState`.

```dart
class PosOrderCompleteState {
  final PosOrderCompleteStatus status;
  final Order? order;
  final bool navigateToNewOrder; // flag
}
```

`PosOrderCompleteNewOrderPressed` sets `navigateToNewOrder: true`. The page listener watches this bool and calls `context.go('/pos-order')`. Instead, use a dedicated status value: `PosOrderCompleteStatus.navigating` (or simply `PosOrderCompleteStatus.done`). The listener fires once on status change and navigates. No bool field, no reset concern.

**Impact:** Removes one field from state; same pattern as issue #2 above.

---

#### 4. `OrderTicketStatus.charging` is a redundant intermediate status

**Plan location:** Phase 4 — `OrderTicketBloc`.

The `_onCharged` handler emits `charging`, then immediately emits `success` (synchronously, no `await` between them). Because `submitCurrentOrder()` is not async, no UI will actually render the `charging` state — the bloc emits two states before the widget tree rebuilds. This mirrors the existing `CheckoutBloc`, which emits `submitting` then `success` in the same pattern. Either keep it for consistency with `CheckoutBloc` (which is a valid reason), or drop it. If kept for parity, document the reason explicitly. If dropped, the status enum shrinks to `loading | idle | success | failure`.

**Recommendation:** Keep it for consistency with `CheckoutBloc` but acknowledge it is cosmetic. This is a minor point, not a required change.

---

#### 5. `PosOrdersBloc` can be inlined into `PosOrdersPage` or collapsed to a very thin bloc

**Plan location:** Phase 6 — `PosOrdersPage`.

The `PosOrdersBloc` has one event (`PosOrdersSubscriptionRequested`) and one meaningful handler that subscribes to `ordersStream` and filters into two lists. The filter logic — separating active from terminal orders — is a pure function of the order list. This is a legitimate use of a bloc (stream subscription + state management), and it follows the KDS pattern exactly (`KdsBloc` does the same thing). No simplification needed here; the design is appropriate.

---

#### 6. `rxdart` is listed as a direct `pubspec.yaml` dependency for `pos_app`

**Plan location:** Phase 1 — `pubspec.yaml`.

`rxdart` is needed inside `menu_repository` and `order_repository`, but the POS app itself only calls repository methods — it does not use any `rxdart` operators directly. The `MenuBloc` will use `combineLatest2` (see issue #1 above) or a single-stream approach. If issue #1 is resolved and the app uses a single stream, `rxdart` should be removed from `pos_app/pubspec.yaml` unless it is directly used in app code.

**Impact:** Cleaner dependency graph; `rxdart` is an implementation detail of the shared packages, not the app layer.

---

#### 7. `quantity stepper` in `OrderTicket` via `updateItemQuantity` adds scope not required by acceptance criteria

**Plan location:** Phase 7 — `OrderTicket` widget description.

The acceptance criteria state: "Order ticket shows all added items with name, price, and quantity." The `OrderTicketLineItem` plan shows "Remove icon → `OrderTicketItemRemoved(lineItemId)`" as the only interaction. But the `OrderTicket` description says "quantity stepper via `updateItemQuantity`".

A quantity stepper (increment/decrement control) is a separate widget and significantly more UI work than a remove icon. The acceptance criteria do not require a stepper — they only require that items can be removed. A stepper would be a YAGNI addition at this stage.

**Suggested simplification:** Implement only the remove icon (which calls `updateItemQuantity(lineItemId, 0)` or `removeItemFromOrder`). Drop the stepper. This aligns the widget plan with the acceptance criteria.

**Impact:** Removes one interactive widget component; simplifies `OrderTicketLineItem`.

---

#### 8. The "Clear" flow is over-specified given the existing `cancelOrder` API

**Plan location:** Phase 4 — `OrderTicketCleared` handler, `clearCurrentOrder()` discussion.

The plan correctly identifies that `cancelOrder(orderId)` exists but does not clear `_currentOrderId`, and proposes adding `clearCurrentOrder()` to `OrderRepository`. This is the right call. However, the plan also contains this comment:

```dart
_orderRepository._currentOrderId = null; // not directly accessible — see note
```

This comment describes accessing a private field, which is not valid Dart. It is only in the plan as a note, not as actual code, but it creates confusion. The implementation path is already clearly stated: add `clearCurrentOrder()`. The "not directly accessible" note and the alternative comment should be removed from the final plan to avoid confusion for implementers.

**Impact:** Clarity only; no code change needed.

---

### Code to Remove / Not Add

| Item | Reason | Estimated Saving |
|---|---|---|
| `navigateToOrderId` field in `OrderTicketState` | Side-effect flag anti-pattern; `success` status is sufficient | ~5 LOC in state + listener reset logic |
| `navigateToNewOrder` field in `PosOrderCompleteState` | Same anti-pattern | ~5 LOC |
| `Rx.combineLatest2` subscription in `MenuBloc` | Replace with single-stream subscription | ~10 LOC |
| `rxdart` in `pos_app/pubspec.yaml` | Not used directly in app layer | 1 line |
| Quantity stepper in `OrderTicketLineItem` | Not in acceptance criteria; YAGNI | ~30-50 LOC (widget + event + handler) |
| Confusing private-field-access comment in plan | Already flagged as invalid | Clarity |

---

### Simplification Recommendations

#### 1. Replace `combineLatest2` with a single-stream `MenuRepository` method

**Current:** `MenuBloc` subscribes to `getMenuGroups()` and `getAllMenuItems()` in parallel via `Rx.combineLatest2`.

**Proposed:** Add one method to `MenuRepository` that emits `_MenuCache` (or a public equivalent) directly:

```dart
Stream<({List<MenuGroup> groups, List<MenuItem> items})> getMenuGroupsAndItems() =>
    Rx.defer(() {
      _initMenuIfNeeded();
      _menuListenerCount += 1;
      return _menuSubject!.stream
          .map((cache) => (groups: cache.groups, items: cache.items))
          .doOnCancel(_decrementMenuCount);
    });
```

`MenuBloc` subscribes once; `MenuState` holds `groups` and `allItems`; category filtering stays a computed getter. This replaces `getAllMenuItems()` + `getMenuGroups()` + `combineLatest2` with a single stream and a single listener-count lifecycle.

**Impact:** ~10 LOC saved in bloc; simpler `MenuBloc._onSubscriptionRequested`; single subscription teardown.

---

#### 2. Use status enum for navigation signals instead of flag fields

**Current:** `OrderTicketState.navigateToOrderId` (nullable String) and `PosOrderCompleteState.navigateToNewOrder` (bool).

**Proposed:** Add `success` / `done` status values; remove the flag fields. The page listener:

```dart
BlocListener<OrderTicketBloc, OrderTicketState>(
  listenWhen: (prev, curr) => curr.status == OrderTicketStatus.success,
  listener: (context, state) {
    // orderId was captured in the bloc event handler before submit cleared it
    // The bloc stores it temporarily, or the listener reads it from the order
    context.go('/pos-order-complete/${state.submittedOrderId}');
  },
)
```

If the order ID must survive the emit, add one field `submittedOrderId` that is set once and never cleared — distinct from a mutable "navigate now" flag. Or store the ID in the listener's local variable when the status transitions. This is the pattern the mobile app's `CheckoutPage` uses: it navigates on `success` status without a flag.

**Impact:** Removes 2 flag fields across 2 state classes; eliminates reset/clear concern on rebuild.

---

#### 3. Remove quantity stepper from Phase 7 scope

**Current:** `OrderTicket` description mentions "quantity stepper via `updateItemQuantity`".

**Proposed:** `OrderTicketLineItem` shows item name, price, and a remove icon (trash/X). Removal calls `updateItemQuantity(lineItemId, 0)` or the existing `removeItemFromOrder` action if the server supports it. Quantity is displayed as a static count (or omitted if the server does not yet track per-line quantities in the POS flow).

**Impact:** Removes a widget; acceptance criteria are fully met with just the remove icon; stepper can be added in a follow-on ticket if cashiers need it.

---

### YAGNI Violations

| Item | Why it violates YAGNI | What to do instead |
|---|---|---|
| Quantity stepper in `OrderTicketLineItem` | Not required by any acceptance criterion; adds UI complexity and a new event | Ship with remove-only; add stepper when a user story requires it |
| `Rx.combineLatest2` dual-stream subscription | Adds `rxdart` operator complexity to app layer; single-stream method achieves the same | Add `getMenuGroupsAndItems()` to `MenuRepository` |
| `rxdart` as a direct `pos_app` dependency | The app layer never calls `rxdart` APIs directly | Remove it from `pubspec.yaml`; keep it in the shared packages |

---

### What the Plan Gets Right

The following design decisions are sound and should not be changed:

- **Two blocs on `PosOrderPage`** (`MenuBloc` + `OrderTicketBloc`): The menu panel and the order ticket have genuinely independent lifecycles and data sources. Two blocs is correct.
- **`clearCurrentOrder()` as a new `OrderRepository` method**: The existing API does not provide this; adding it is the right way to extend the contract cleanly.
- **`submitCurrentOrder()` for the Charge action**: The Critical Finding section is accurate and well-reasoned. Using `submitCurrentOrder()` is correct.
- **No `chargeOrder` backend action**: Alternative A and B are correctly rejected.
- **`PosOrdersBloc` filtering on the client**: The server already returns all orders; client-side filtering is the right approach and avoids a new backend endpoint.
- **`ConnectingPage` copied from `kds_app`**: This is not duplication in the harmful sense — it is a small, stable widget. Copying is simpler than promoting it to the UI package (which would require the UI package to depend on l10n or accept a string param).
- **Bloc-per-screen structure**: Matches the KDS and mobile app patterns precisely.
- **Four-phase implementation sequence**: Logical dependencies are respected. No phase requires something from a later phase.

---

### Final Assessment

Total potential LOC reduction: ~5-8% of planned implementation (primarily removing the quantity stepper and flag fields)

Complexity score: **Low** — the plan is well-grounded in existing patterns. Most complexity is inherent to the feature, not introduced artificially.

Recommended action: **Proceed with simplifications** — address issues #1 (single-stream subscription), #2 (remove `navigateToOrderId` flag), #3 (remove `navigateToNewOrder` flag), and #7 (drop the quantity stepper from initial scope). These four changes reduce implementation risk without removing any required capability. The remaining issues are either minor (rxdart dep, clarity comment) or optional (the `charging` status).

The plan is well-scoped and the architecture is appropriate. It correctly leverages the established `kds_app` patterns and avoids backend changes. The issues identified are refinements, not fundamental flaws.
