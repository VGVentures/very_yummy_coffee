---
title: "feat: add POS app for iPad cashier workflow"
type: feat
date: 2026-03-03
---

# feat: add POS app for iPad cashier workflow — Extensive

> **Review status:** Updated after simplicity review, VGV standards review, and user flow analysis (2026-03-03).

## Overview

Create `applications/pos_app` — a Flutter iPad application giving café staff a Point-of-Sale interface to build customer orders, submit them to the kitchen, and view order history. The app reuses all existing shared packages (`menu_repository`, `order_repository`, `connection_repository`, `very_yummy_coffee_ui`) and the WebSocket RPC infrastructure. Two new methods are added to shared packages to support POS-specific needs.

---

## Problem Statement

The monorepo currently has:
- `mobile_app` — customer self-service kiosk (menu → cart → submit)
- `kds_app` — kitchen display (submitted orders → in-progress → ready → complete)

There is no staff-facing tool to take orders at the counter.

---

## Proposed Solution

A new `applications/pos_app` Flutter package targeting iOS (iPad). Four screens behind a WS connection guard:

| Route | Screen | Purpose |
|---|---|---|
| `/connecting` | `ConnectingPage` | Standard WS indicator; redirects when connected |
| `/pos-order` | `PosOrderPage` | Split-panel: menu grid (left) + order ticket (right) |
| `/pos-order-complete/:orderId` | `PosOrderCompletePage` | Charge receipt for submitted order |
| `/pos-orders` | `PosOrdersPage` | In-progress cards + order history table |

---

## Key Findings from Research

### Finding 1: `completeOrder` Requires `ready` Status

> **Brainstorm assumption was incorrect.** `api/lib/src/server_state.dart:184` only transitions orders when `status == 'ready'`. A new POS order is `pending`, so calling `completeOrder` silently no-ops.

**Resolution:** The POS "Charge" button calls `orderRepository.submitCurrentOrder()` (pending → submitted). This sends the order to the KDS for fulfillment. No new backend action needed.

### Finding 2: `MenuRepository.getMenuGroupsAndItems()` Must Be Added

The `MenuBloc` needs both groups (for category tabs) and all items (for the grid). The existing `getMenuGroups()` and `getMenuItems(groupId)` are separate streams; using `combineLatest2` on them creates two ref-counted subscriptions for the same underlying WS channel.

**Resolution:** Add a single `getMenuGroupsAndItems()` method that returns `Stream<({List<MenuGroup> groups, List<MenuItem> items})>` — one subscription, one stream. Simpler at the call site and avoids the double ref-count.

### Finding 3: Order History Confirmed Available

`ServerState.snapshotForTopic('orders')` at `api/lib/src/server_state.dart:78` returns `_orders.values.toList()` — ALL orders regardless of status. No backend change needed for order history.

### Finding 4: `clearCurrentOrder()` Must Be Added to `OrderRepository`

`cancelOrder(orderId)` sends the cancel WS action but does NOT clear `_currentOrderId`. The POS "Clear" flow needs a new method that cancels and clears in one call.

---

## Shared Package Changes

### `shared/menu_repository/lib/src/menu_repository.dart`

Add `getMenuGroupsAndItems()`:

```dart
/// Returns a live stream of all menu groups and items together.
///
/// Uses the same underlying WebSocket subscription as [getMenuGroups].
/// Preferred for screens that need both groups and items simultaneously,
/// as it avoids creating two separate ref-counted subscriptions.
Stream<({List<MenuGroup> groups, List<MenuItem> items})>
    getMenuGroupsAndItems() => Rx.defer(() {
  _initMenuIfNeeded();
  _menuListenerCount += 1;
  return _menuSubject!.stream
      .map((cache) => (groups: cache.groups, items: cache.items))
      .doOnCancel(_decrementMenuCount);
});
```

### `shared/order_repository/lib/src/order_repository.dart`

Add `clearCurrentOrder()`:

```dart
/// Cancels the current order and clears the tracked order ID.
///
/// Use on the POS "Clear" action. Unlike [cancelOrder], this also
/// sets [currentOrderId] to null so [currentOrderStream] stops emitting.
void clearCurrentOrder() {
  final orderId = _currentOrderId;
  if (orderId == null) return;
  _wsRpcClient.sendAction('cancelOrder', {'orderId': orderId});
  _currentOrderId = null;
}
```

---

## Technical Approach

### Architecture

`menu` and `order_ticket` are first-class top-level features with their own bloc + view layers. `pos_order` is a pure composition screen — no bloc — that provides both feature blocs and lays them out side-by-side.

```
applications/pos_app/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── app_router/
│   │   │   └── app_router.dart
│   │   ├── bloc/
│   │   │   ├── app_bloc.dart
│   │   │   ├── app_bloc.mapper.dart
│   │   │   ├── app_event.dart
│   │   │   └── app_state.dart
│   │   └── view/
│   │       ├── app.dart
│   │       ├── connecting_page.dart
│   │       └── view.dart
│   ├── menu/                          ← standalone feature
│   │   ├── bloc/
│   │   │   ├── menu_bloc.dart
│   │   │   ├── menu_bloc.mapper.dart
│   │   │   ├── menu_event.dart
│   │   │   └── menu_state.dart
│   │   ├── view/
│   │   │   └── widgets/
│   │   │       ├── menu_category_tabs.dart
│   │   │       ├── menu_item_card.dart
│   │   │       └── menu_item_grid.dart
│   │   └── menu.dart
│   ├── order_ticket/                  ← standalone feature
│   │   ├── bloc/
│   │   │   ├── order_ticket_bloc.dart
│   │   │   ├── order_ticket_bloc.mapper.dart
│   │   │   ├── order_ticket_event.dart
│   │   │   └── order_ticket_state.dart
│   │   ├── view/
│   │   │   └── widgets/
│   │   │       ├── order_ticket.dart
│   │   │       └── order_ticket_line_item.dart
│   │   └── order_ticket.dart
│   ├── pos_order/                     ← composition screen, no bloc
│   │   ├── view/
│   │   │   ├── pos_order_page.dart    ← BlocProviders + BlocListener for navigation
│   │   │   ├── pos_order_view.dart    ← split Row composing menu + ticket panels
│   │   │   ├── view.dart
│   │   │   └── widgets/
│   │   │       └── pos_top_bar.dart
│   │   └── pos_order.dart
│   ├── pos_order_complete/
│   │   ├── bloc/
│   │   │   ├── pos_order_complete_bloc.dart
│   │   │   ├── pos_order_complete_bloc.mapper.dart
│   │   │   ├── pos_order_complete_event.dart
│   │   │   └── pos_order_complete_state.dart
│   │   ├── view/
│   │   │   ├── pos_order_complete_page.dart
│   │   │   ├── pos_order_complete_view.dart
│   │   │   └── view.dart
│   │   └── pos_order_complete.dart
│   ├── pos_orders/
│   │   ├── bloc/
│   │   │   ├── pos_orders_bloc.dart
│   │   │   ├── pos_orders_bloc.mapper.dart
│   │   │   ├── pos_orders_event.dart
│   │   │   └── pos_orders_state.dart
│   │   ├── view/
│   │   │   ├── pos_orders_page.dart
│   │   │   ├── pos_orders_view.dart
│   │   │   └── view.dart
│   │   └── pos_orders.dart
│   └── l10n/
│       ├── l10n.dart
│       └── arb/
│           └── app_en.arb
├── test/
│   ├── app/
│   │   └── bloc/
│   │       └── app_bloc_test.dart
│   ├── menu/
│   │   └── bloc/
│   │       └── menu_bloc_test.dart
│   ├── order_ticket/
│   │   └── bloc/
│   │       └── order_ticket_bloc_test.dart
│   ├── pos_order_complete/
│   │   └── bloc/
│   │       └── pos_order_complete_bloc_test.dart
│   ├── pos_orders/
│   │   └── bloc/
│   │       └── pos_orders_bloc_test.dart
│   └── helpers/
│       └── pump_app.dart
└── pubspec.yaml
```

**Feature boundaries:**

| Feature | Owns | Imports |
|---|---|---|
| `menu` | `MenuBloc`, menu grid UI | `MenuRepository`, `OrderRepository` |
| `order_ticket` | `OrderTicketBloc`, ticket UI | `OrderRepository` |
| `pos_order` | `PosOrderPage` + `PosOrderView` + `PosTopBar` | `menu`, `order_ticket` |
| `pos_order_complete` | `PosOrderCompleteBloc`, receipt UI | `OrderRepository` |
| `pos_orders` | `PosOrdersBloc`, history UI | `OrderRepository` |

---

### Implementation Phases

#### Phase 1: Package Scaffold

- [ ] Create `applications/pos_app/` directory structure
- [ ] Write `pubspec.yaml` (mirror `kds_app` + add `menu_repository`; add `bloc_lint` + `nested` to dev_dependencies)
- [ ] Write `main.dart` (lock orientation to landscape; `MultiRepositoryProvider` with `ConnectionRepository`, `MenuRepository`, `OrderRepository`)
- [ ] Add `getMenuGroupsAndItems()` to `shared/menu_repository/lib/src/menu_repository.dart`
- [ ] Add `clearCurrentOrder()` to `shared/order_repository/lib/src/order_repository.dart`
- [ ] Run `.github/update_github_actions.sh` and commit regenerated workflow file
- [ ] Write `l10n/arb/app_en.arb` with all POS strings

**Key `pubspec.yaml` dependencies:**
```yaml
dependencies:
  api_client:
    path: ../../shared/api_client
  bloc: ^9.0.0
  connection_repository:
    path: ../../shared/connection_repository
  dart_mappable: ^4.6.1
  flutter:
    sdk: flutter
  flutter_bloc: ^9.1.1
  flutter_localizations:
    sdk: flutter
  go_router: ^14.6.2
  intl: ^0.20.2
  menu_repository:
    path: ../../shared/menu_repository
  meta: ^1.16.0
  order_repository:
    path: ../../shared/order_repository
  rxdart: ^0.28.0          # verify against workspace before pinning
  very_yummy_coffee_ui:
    path: ../../shared/very_yummy_coffee_ui

dev_dependencies:
  bloc_lint: ^0.3.6
  bloc_test: ^10.0.0
  build_runner: ^2.11.1
  dart_mappable_builder: ^4.6.4
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  nested: ^1.0.0
  very_good_analysis: ^10.0.0
```

**iPad orientation lock in `main.dart`:**
```dart
WidgetsFlutterBinding.ensureInitialized();
await SystemChrome.setPreferredOrientations([
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
]);
```

#### Phase 2: App Shell (AppBloc + Router)

`AppBloc` — identical to `kds_app/lib/app/bloc/app_bloc.dart`.

`AppRouter` redirect logic:

```dart
redirect: (context, state) {
  final status = context.read<AppBloc>().state.status;
  final path = state.uri.path;
  final onConnecting = path == ConnectingPage.routeName;
  final onComplete = path.startsWith('/pos-order-complete/');

  if (status != AppStatus.connected && !onConnecting) {
    // Don't eject cashier from receipt mid-read — preserve complete screen
    if (onComplete) return null;
    return ConnectingPage.routeName;
  }
  if (status == AppStatus.connected && onConnecting) {
    return PosOrderPage.routeName;
  }
  return null;
},
```

> **Flow analysis fix:** `/pos-order-complete/:orderId` is excluded from the disconnect redirect so a cashier reading the receipt is not ejected mid-read if the WS momentarily drops.

Routes:
- `/connecting` → `ConnectingPage`
- `/pos-order` → `PosOrderPage`
- `/pos-order-complete/:orderId` → `PosOrderCompletePage`
- `/pos-orders` → `PosOrdersPage`

#### Phase 3: `MenuBloc` (`lib/menu/`)

Standalone feature. Owns the left panel content of `PosOrderPage`.

> **VGV fix:** `MenuBloc` receives BOTH `MenuRepository` AND `OrderRepository` (needed for `addItemToCurrentOrder`).

**Events:**
```dart
@immutable
sealed class MenuEvent { const MenuEvent(); }

class MenuSubscriptionRequested extends MenuEvent {
  const MenuSubscriptionRequested();
}

class MenuCategorySelected extends MenuEvent {
  const MenuCategorySelected(this.groupId);
  final String? groupId; // null = "All"
}

class MenuItemAdded extends MenuEvent {
  const MenuItemAdded(this.item);
  final MenuItem item;
}
```

> **VGV note:** Command events use past-tense noun-verb for user actions (`MenuItemAdded`, `MenuCategorySelected`) — not the `Requested` suffix, which is reserved for subscription/data-loading initiators.

**State** (all state classes require `@MappableClass()` + `with XxxStateMappable` mixin):
```dart
@MappableClass()
class MenuState with MenuStateMappable {
  const MenuState({
    this.status = MenuStatus.loading,
    this.groups = const [],
    this.allItems = const [],
    this.selectedGroupId,
  });

  final MenuStatus status;
  final List<MenuGroup> groups;
  final List<MenuItem> allItems;
  final String? selectedGroupId; // null = "All"

  List<MenuItem> get visibleItems => selectedGroupId == null
      ? allItems
      : allItems.where((i) => i.groupId == selectedGroupId).toList();
}
```

**Subscription** — uses `getMenuGroupsAndItems()` (single subscription, no `combineLatest2`):
```dart
Future<void> _onSubscriptionRequested(...) async {
  emit(state.copyWith(status: MenuStatus.loading));
  await emit.forEach(
    _menuRepository.getMenuGroupsAndItems(),
    onData: (data) => state.copyWith(
      status: MenuStatus.success,
      groups: data.groups,
      allItems: data.items,
    ),
    onError: (_, _) => state.copyWith(status: MenuStatus.failure),
  );
}
```

**`MenuItemAdded` handler:**
```dart
void _onItemAdded(MenuItemAdded event, Emitter<MenuState> emit) {
  if (!event.item.available) return;
  _orderRepository.addItemToCurrentOrder(
    itemName: event.item.name,
    itemPrice: event.item.price,
    options: '',   // POS has no options UI
    quantity: 1,
  );
}
```

#### Phase 4: `OrderTicketBloc` (`lib/order_ticket/`)

Standalone feature. Owns the right panel content of `PosOrderPage`.

**Events:**
```dart
@immutable
sealed class OrderTicketEvent { const OrderTicketEvent(); }

class OrderTicketSubscriptionRequested extends OrderTicketEvent {
  const OrderTicketSubscriptionRequested();
}
class OrderTicketCreateOrderRequested extends OrderTicketEvent {
  const OrderTicketCreateOrderRequested();
}
class OrderTicketChargeRequested extends OrderTicketEvent {
  const OrderTicketChargeRequested();
}
class OrderTicketClearRequested extends OrderTicketEvent {
  const OrderTicketClearRequested();
}
class OrderTicketItemRemoved extends OrderTicketEvent {
  const OrderTicketItemRemoved(this.lineItemId);
  final String lineItemId;
}
```

**State:**
```dart
@MappableClass()
class OrderTicketState with OrderTicketStateMappable {
  const OrderTicketState({
    this.status = OrderTicketStatus.loading,
    this.order,
    this.submittedOrderId,
  });

  final OrderTicketStatus status; // loading | idle | charging | submitted | failure
  final Order? order;
  final String? submittedOrderId; // set only when status == submitted
}
```

> **VGV fix:** Navigation is triggered by `status == OrderTicketStatus.submitted` (not a separate flag field). The `BlocListener` in `PosOrderPage` reads `state.submittedOrderId` when that status is reached. The status naturally resets to `loading` on the next `OrderTicketCreateOrderRequested` cycle, clearing the navigation trigger automatically.

**`OrderTicketCreateOrderRequested` handler:**
```dart
Future<void> _onCreateOrderRequested(...) async {
  // Guard: only create if no current order is tracked
  if (_orderRepository.currentOrderId != null) return;
  emit(state.copyWith(status: OrderTicketStatus.loading, order: null));
  await _orderRepository.createOrder();
}
```

**`OrderTicketChargeRequested` handler** (critical — capture orderId before submit):
```dart
Future<void> _onChargeRequested(...) async {
  if (state.status == OrderTicketStatus.charging) return; // duplicate-tap guard
  final orderId = _orderRepository.currentOrderId;
  if (orderId == null || state.order == null || state.order!.items.isEmpty) return;
  emit(state.copyWith(status: OrderTicketStatus.charging));
  _orderRepository.submitCurrentOrder(); // clears currentOrderId
  emit(state.copyWith(
    status: OrderTicketStatus.submitted,
    submittedOrderId: orderId,
  ));
}
```

**`OrderTicketClearRequested` handler:**
```dart
void _onClearRequested(...) {
  _orderRepository.clearCurrentOrder(); // cancels + clears currentOrderId
  emit(state.copyWith(status: OrderTicketStatus.idle, order: null));
}
```

**Navigation listener placement** — at the `PosOrderPage` scaffold level wrapping both panels:
```dart
// In pos_order_page.dart:
BlocListener<OrderTicketBloc, OrderTicketState>(
  listenWhen: (prev, curr) => curr.status == OrderTicketStatus.submitted,
  listener: (context, state) {
    final orderId = state.submittedOrderId!;
    context.go('/pos-order-complete/$orderId');
  },
  child: _PosOrderView(), // contains the Row with both panels
)
```

> **"Clear" state machine (Option B):** "Clear" cancels the current order and shows an empty ticket (`order == null`, status `idle`). The cashier sees a "New Order" button. Tapping it fires `OrderTicketCreateOrderRequested`. Items added before tapping "New Order" are silently dropped because `currentOrderId` is null — `addItemToCurrentOrder` already no-ops when `currentOrderId == null`.

#### Phase 5: `PosOrderCompletePage`

`PosOrderCompleteBloc`:

**Events:**
```dart
@immutable
sealed class PosOrderCompleteEvent { const PosOrderCompleteEvent(); }

class PosOrderCompleteSubscriptionRequested extends PosOrderCompleteEvent {
  const PosOrderCompleteSubscriptionRequested(this.orderId);
  final String orderId;
}
class PosOrderCompleteNewOrderRequested extends PosOrderCompleteEvent {
  const PosOrderCompleteNewOrderRequested();
}
```

**State:**
```dart
@MappableClass()
class PosOrderCompleteState with PosOrderCompleteStateMappable {
  const PosOrderCompleteState({
    this.status = PosOrderCompleteStatus.loading,
    this.order,
  });

  final PosOrderCompleteStatus status; // loading | success | failure | navigatingAway
  final Order? order;
}
```

**Subscription handler:**
```dart
Future<void> _onSubscriptionRequested(...) async {
  emit(const PosOrderCompleteState()); // loading
  await emit.forEach(
    _orderRepository.orderStream(event.orderId),
    onData: (order) {
      // VGV fix: treat null as loading until first non-null value arrives.
      // The ordersStream is seeded with an empty list; the server broadcast
      // arrives shortly after. Emitting failure on the first null would flash
      // an error on every charge operation.
      if (order == null) {
        return state.status == PosOrderCompleteStatus.success
            ? state.copyWith(status: PosOrderCompleteStatus.failure)
            : state; // still loading — keep waiting
      }
      return state.copyWith(status: PosOrderCompleteStatus.success, order: order);
    },
    onError: (_, _) => state.copyWith(status: PosOrderCompleteStatus.failure),
  );
}
```

**`PosOrderCompleteNewOrderRequested` handler:**
```dart
void _onNewOrderRequested(...) {
  emit(state.copyWith(status: PosOrderCompleteStatus.navigatingAway));
}
```

**Navigation listener in `PosOrderCompletePage`:**
```dart
BlocListener<PosOrderCompleteBloc, PosOrderCompleteState>(
  listenWhen: (_, curr) => curr.status == PosOrderCompleteStatus.navigatingAway,
  listener: (context, _) => context.go('/pos-order'),
  child: ...,
)
```

**Route parameter extraction** (with null safety):
```dart
// In PosOrderCompletePage.pageBuilder:
final orderId = state.pathParameters['orderId'];
if (orderId == null) return const SizedBox.shrink(); // or error widget
```

#### Phase 6: `PosOrdersPage`

`PosOrdersBloc`:

**Active vs history status split:**
- **Active cards** — `submitted`, `inProgress`, `ready` (orders in KDS queue)
- **History table** — `completed`, `cancelled` (terminal states)
- `pending` orders (created but not yet charged) are excluded from both (they appear in the order ticket, not the orders list)

**State:**
```dart
@MappableClass()
class PosOrdersState with PosOrdersStateMappable {
  const PosOrdersState({
    this.status = PosOrdersStatus.loading,
    this.activeOrders = const [],
    this.historyOrders = const [],
  });

  final PosOrdersStatus status;
  final List<Order> activeOrders;   // submitted, inProgress, ready
  final List<Order> historyOrders;  // completed, cancelled
}
```

**Navigation back to `/pos-order`** via a "Back" button in the top bar: `context.go('/pos-order')`. (Not `context.pop()` — the router stack was replaced by `context.go('/pos-orders')`.)

#### Phase 7: UI Widgets

All widgets are POS-specific (not promoted to `very_yummy_coffee_ui` unless reused by another app). Widget ownership follows feature boundaries.

**`lib/menu/view/widgets/`**

- **`MenuCategoryTabs`**: "All" tab prepended; labels from `MenuBloc.state.groups`; tapping fires `MenuCategorySelected`
- **`MenuItemGrid`**: `GridView.builder` of `MenuBloc.state.visibleItems`; loading (`CircularProgressIndicator`) / empty ("No items in this category") / error ("Unable to load menu") states
- **`MenuItemCard`**: item name + price; greyed out + "Unavailable" overlay when `item.available == false`; `onTap` fires `MenuItemAdded` (bloc guards availability)

**`lib/order_ticket/view/widgets/`**

- **`OrderTicket`**: list of `OrderTicketLineItem` rows; subtotal/total line; "New Order" button (visible when `order == null`); "Clear" button (visible when items present, fires `OrderTicketClearRequested`); "Charge \$X.XX" button (disabled when empty, fires `OrderTicketChargeRequested`); loading indicator when `status == charging`; empty state ("No items — tap menu to add")
- **`OrderTicketLineItem`**: item name + price; remove icon → `OrderTicketItemRemoved(lineItemId)` (no quantity stepper — YAGNI)

**`lib/pos_order/view/`**

- **`PosOrderPage`**: `MultiBlocProvider` providing `MenuBloc` + `OrderTicketBloc`; wraps body in `BlocListener<OrderTicketBloc, ...>` for charge navigation
- **`PosOrderView`**: `Column(PosTopBar, Expanded(Row(menu panel, ticket panel)))`
- **`PosTopBar`**: connection dot (`AppBloc`); app title; live clock (`Stream.periodic` — see `kds_top_bar.dart`); "View Orders" → `context.go('/pos-orders')`

---

## User Flow Edge Cases

| Scenario | Handling |
|---|---|
| Tap "Charge" with empty ticket | Button is disabled; `_onChargeRequested` also guards `items.isEmpty` |
| Tap "Charge" twice rapidly | Duplicate-tap guard: returns early if `status == charging` |
| Tap menu item before "New Order" after "Clear" | `addItemToCurrentOrder` no-ops when `currentOrderId == null` |
| WS disconnect on `/pos-order` | Redirect to `/connecting`; order survives in server state; `currentOrderId` survives in `OrderRepository` (app-scoped) |
| WS disconnect on `/pos-order-complete` | Redirect guard excluded for this route — cashier stays on receipt |
| WS reconnect after disconnect | Redirect to `/pos-order`; `OrderTicketBloc.createOrder` guards `currentOrderId != null` — no orphan created |
| Menu item becomes unavailable | `MenuBloc` re-emits; `MenuItemCard` shows unavailable overlay; `_onItemAdded` guards `available` |
| "Clear" on empty ticket | Button is hidden when `order == null || order.items.isEmpty` |
| Back from `/pos-orders` | "Back" button in top bar calls `context.go('/pos-order')` |
| Back from `/pos-order-complete` | Only "New Order" button (no back gesture needed for POS kiosk) |
| iPad portrait orientation | Locked to landscape in `main.dart` via `SystemChrome.setPreferredOrientations` |
| `orderId` path param is missing | Null-checked in `pageBuilder`; shows error widget if null |

---

## Acceptance Criteria

### Functional Requirements

- [ ] App starts on `/connecting` and redirects to `/pos-order` when WS connects
- [ ] WS disconnect from any screen (except receipt) redirects to `/connecting`
- [ ] WS disconnect while on receipt screen preserves the receipt view
- [ ] iPad locked to landscape orientation at startup
- [ ] Category tabs show all `MenuGroup` names with an "All" tab prepended
- [ ] Tapping a category tab filters the menu item grid
- [ ] Tapping an available menu item adds it to the order ticket
- [ ] Tapping an unavailable menu item does nothing
- [ ] "Charge" button is disabled when the ticket is empty
- [ ] Tapping "Charge" twice rapidly does not submit the order twice
- [ ] "Charge" calls `submitCurrentOrder()` and navigates to `/pos-order-complete/:orderId`
- [ ] Receipt screen shows submitted order details (items, total)
- [ ] "New Order" on receipt navigates to a fresh `/pos-order`
- [ ] "Clear" cancels the current order and shows an empty ticket with a "New Order" button
- [ ] Items tapped after "Clear" (before "New Order") are silently discarded
- [ ] `/pos-orders` active section: orders with status `submitted`, `inProgress`, `ready`
- [ ] `/pos-orders` history section: orders with status `completed`, `cancelled`
- [ ] "View Orders" in top bar navigates to `/pos-orders`
- [ ] "Back" in `/pos-orders` top bar returns to `/pos-order` via `context.go`

### Non-Functional Requirements

- [ ] iPad landscape layout only; no portrait breakpoint
- [ ] All Blocs use explicit event classes (no `Cubit`)
- [ ] Navigation uses `context.go(hardcodedPath)` exclusively — no `push`, `goNamed`, `extra`
- [ ] No dependency from `very_yummy_coffee_ui` on any repository package
- [ ] All state classes annotated with `@MappableClass()` and `with XxxStateMappable`

### Quality Gates

- [ ] All Blocs have `blocTest` unit tests covering success, failure, and edge cases
- [ ] All widget tests use the `pumpApp` helper
- [ ] `dart analyze` passes with zero issues
- [ ] GitHub Actions workflows regenerated and committed

---

## Dependencies & Prerequisites

| Item | Status | Action |
|---|---|---|
| `shared/menu_repository` — `getMenuGroupsAndItems()` | ❌ Missing | Add in Phase 1 |
| `shared/order_repository` — `clearCurrentOrder()` | ❌ Missing | Add in Phase 1 |
| `applications/pos_app/pubspec.yaml` | ❌ New | Create in Phase 1 |
| `.github/update_github_actions.sh` | ✅ Exists | Run after pubspec change |
| `api/lib/src/server_state.dart` | ✅ No change needed | Orders snapshot includes all statuses |
| `very_yummy_coffee_ui` | ✅ Shared theme tokens | `CoffeeTheme.light`, design tokens |

---

## Risk Analysis

| Risk | Severity | Status |
|---|---|---|
| `completeOrder` silently no-ops on pending orders | High | **Resolved** — use `submitCurrentOrder()` |
| Receipt screen ejected on WS disconnect | Medium | **Resolved** — excluded from redirect guard |
| `createOrder()` orphaning orders on reconnect | Medium | **Resolved** — bloc guards `currentOrderId != null` |
| `OrderRepository._currentOrderId` not cleared by `cancelOrder` | Medium | **Resolved** — add `clearCurrentOrder()` |
| Double-tap "Charge" submits twice | Medium | **Resolved** — `status == charging` guard in handler |
| `PosOrderCompleteBloc` flashes failure on null from seeded stream | Medium | **Resolved** — treat null as loading until success received |
| iPad orientation not locked | Low | **Resolved** — `SystemChrome.setPreferredOrientations` in `main.dart` |
| GitHub Actions not regenerated after `pubspec.yaml` change | Medium | Mitigated — in Phase 1 checklist |

---

## Alternative Approaches Considered

### Alt A: Use `Rx.combineLatest2(getMenuGroups(), getAllMenuItems(), ...)`

Two separate subscriptions for the same WS topic, doubling the ref-count lifecycle. Rejected in favour of a single `getMenuGroupsAndItems()` method.

### Alt B: Add `chargeOrder` backend action

Transitions order directly to `completed` bypassing KDS. Rejected — `submitCurrentOrder()` is the correct action; the KDS should process the order.

### Alt C: POS calls `submitOrder → startOrder → markOrderReady → completeOrder` in sequence

Marks orders as done immediately without KDS involvement. Rejected — same reason as Alt B.

### Alt D: Orders list as primary screen (hub-and-spoke navigation)

Adds friction to the most common cashier workflow. Rejected — `/pos-order` as root is optimal.

### Alt E: `OrderTicket` quantity stepper

Adding +/− quantity controls for each line item. Rejected (YAGNI) — remove icon is sufficient for the current feature set. A stepper can be added in a follow-on ticket.

---

## Implementation Checklist

### Phase 1 — Package Scaffold & Shared Changes

- [ ] Create `applications/pos_app/` directory structure
- [ ] Write `pubspec.yaml` (with `bloc_lint` + `nested` in dev deps)
- [ ] Add `getMenuGroupsAndItems()` to `shared/menu_repository/lib/src/menu_repository.dart`
- [ ] Add `clearCurrentOrder()` to `shared/order_repository/lib/src/order_repository.dart`
- [ ] Run `.github/update_github_actions.sh`, commit changes
- [ ] Write `main.dart` (orientation lock + `MultiRepositoryProvider`)
- [ ] Write `l10n/arb/app_en.arb`

### Phase 2 — App Shell

- [ ] `app/bloc/app_bloc.dart` + events + state (mirrors `kds_app`)
- [ ] `app/view/connecting_page.dart` (mirrors `kds_app`)
- [ ] `app/view/app.dart`
- [ ] `app/app_router/app_router.dart` (4 routes + redirect guard with receipt exemption)
- [ ] Test: `app/bloc/app_bloc_test.dart`

### Phase 3 — `MenuBloc` (`lib/menu/`)

- [ ] `menu/bloc/menu_bloc.dart` + events + state (receives `MenuRepository` + `OrderRepository`)
- [ ] `dart pub run build_runner build` for `.mapper.dart`
- [ ] `menu/view/widgets/menu_category_tabs.dart`
- [ ] `menu/view/widgets/menu_item_grid.dart`
- [ ] `menu/view/widgets/menu_item_card.dart`
- [ ] `menu/menu.dart` (barrel export)
- [ ] Test: `menu/bloc/menu_bloc_test.dart`

### Phase 4 — `OrderTicketBloc` (`lib/order_ticket/`)

- [ ] `order_ticket/bloc/order_ticket_bloc.dart` + events + state
- [ ] `dart pub run build_runner build` for `.mapper.dart`
- [ ] `order_ticket/view/widgets/order_ticket.dart`
- [ ] `order_ticket/view/widgets/order_ticket_line_item.dart` (remove icon; no quantity stepper)
- [ ] `order_ticket/order_ticket.dart` (barrel export)
- [ ] Test: `order_ticket/bloc/order_ticket_bloc_test.dart`

### Phase 5 — `PosOrderPage` (`lib/pos_order/`, no bloc)

- [ ] `pos_order/view/pos_order_page.dart` (`MultiBlocProvider` + `BlocListener` for navigation)
- [ ] `pos_order/view/pos_order_view.dart` (split `Row`: menu left, ticket right)
- [ ] `pos_order/view/widgets/pos_top_bar.dart`
- [ ] `pos_order/pos_order.dart` (barrel export)

### Phase 6 — `PosOrderCompletePage`

- [ ] `pos_order_complete/bloc/pos_order_complete_bloc.dart` + events + state
- [ ] `pos_order_complete/view/pos_order_complete_page.dart`
- [ ] `pos_order_complete/view/pos_order_complete_view.dart`
- [ ] Test: `pos_order_complete/bloc/pos_order_complete_bloc_test.dart`

### Phase 7 — `PosOrdersPage`

- [ ] `pos_orders/bloc/pos_orders_bloc.dart` + events + state
- [ ] `pos_orders/view/pos_orders_page.dart`
- [ ] `pos_orders/view/pos_orders_view.dart` (active cards + history table + Back button)
- [ ] Test: `pos_orders/bloc/pos_orders_bloc_test.dart`

### Phase 8 — Polish & CI

- [ ] Widget tests for key pages using `pumpApp` helper
- [ ] `dart analyze` — zero issues
- [ ] Verify GitHub Actions pass

---

## Internal References

- Server state (order status transitions): [api/lib/src/server_state.dart](api/lib/src/server_state.dart)
- `OrderRepository` (mutations + streams): [shared/order_repository/lib/src/order_repository.dart](shared/order_repository/lib/src/order_repository.dart)
- `MenuRepository` (WS subscription pattern): [shared/menu_repository/lib/src/menu_repository.dart](shared/menu_repository/lib/src/menu_repository.dart)
- `KdsBloc` (reference Bloc): [applications/kds_app/lib/kds/bloc/kds_bloc.dart](applications/kds_app/lib/kds/bloc/kds_bloc.dart)
- `KdsTopBar` (clock + status dot): [applications/kds_app/lib/kds/view/widgets/kds_top_bar.dart](applications/kds_app/lib/kds/view/widgets/kds_top_bar.dart)
- `AppRouter` (redirect guard pattern): [applications/kds_app/lib/app/app_router/app_router.dart](applications/kds_app/lib/app/app_router/app_router.dart)
- `CheckoutBloc` (`submitCurrentOrder` + `BlocConsumer` navigation): [applications/mobile_app/lib/checkout/bloc/checkout_bloc.dart](applications/mobile_app/lib/checkout/bloc/checkout_bloc.dart)
- Brainstorm: [docs/ideate/2026-03-03-pos-app-brainstorm-doc.md](docs/ideate/2026-03-03-pos-app-brainstorm-doc.md)
- Simplicity review: [docs/plan/2026-03-03-feat-pos-app-plan-review.md](docs/plan/2026-03-03-feat-pos-app-plan-review.md)
- VGV standards review: [docs/plan/2026-03-03-feat-pos-app-plan-vgv-review.md](docs/plan/2026-03-03-feat-pos-app-plan-vgv-review.md)
