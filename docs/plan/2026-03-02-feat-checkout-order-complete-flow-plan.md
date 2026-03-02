---
title: "feat: add checkout and order-complete flow"
type: feat
date: 2026-03-02
brainstorm: wingspan/brainstorms/2026-02-24-checkout-flow-brainstorm-doc.md
---

# ✨ feat: add checkout and order-complete flow

## Overview

Implement the final two screens of the coffee ordering journey: a **Checkout screen** where the user reviews their order and places it, and an **Order Complete screen** that displays a real-time 4-step status tracker as the barista prepares the order. The full navigation chain is: **Cart → Checkout → Order Complete → Menu**.

This also requires a small server-side addition (a new `submitOrder` WS action to produce the `submitted` intermediate state) and a "Proceed to Checkout" CTA on the existing Cart screen.

## Problem Statement

The app currently allows users to browse the menu, configure items, and manage a cart — but there is no path to actually placing and tracking an order. The Cart screen has no "Proceed to Checkout" button, and no Checkout or Order Complete screens exist.

Additionally, the flow analysis revealed a critical gap: the `OrderStatus.submitted` value (which drives the "In Progress" step in the tracker) is never reachable through the current server protocol. The existing `completeOrder` WS action jumps `pending → completed` with no intermediate state. A new `submitOrder` action must be introduced.

## Proposed Solution

1. **Server**: Add a `submitOrder` WS action that transitions order status `pending → submitted`. The existing `completeOrder` action (for barista use) transitions `submitted → completed`.
2. **`OrderRepository`**: Add `submitCurrentOrder()` that sends `submitOrder` and clears `_currentOrderId`.
3. **Router**: Nest `CheckoutPage` and `OrderCompletePage` as children of the `cart` route.
4. **CartView**: Add a sticky "Proceed to Checkout" CTA visible only when the cart is non-empty.
5. **Checkout feature**: `CheckoutBloc` + `CheckoutPage` + `CheckoutView` at `/menu/cart/checkout`.
6. **Order Complete feature**: `OrderCompleteBloc` + `OrderCompletePage` + `OrderCompleteView` at `/menu/cart/checkout/confirmation/:orderId`.

## Technical Approach

### Architecture

#### Route Structure (updated)

```
/connecting                         → ConnectingPage
/menu                               → MenuGroupsPage
  /menu/cart                        → CartPage
    /menu/cart/checkout             → CheckoutPage         ← NEW
    /menu/cart/checkout/confirmation/:orderId → OrderCompletePage ← NEW
  /menu/:groupId                    → MenuItemsPage
    /menu/:groupId/:itemId          → ItemDetailPage
```

`CartPage` gets `routes: [...]` children added in `app_router.dart`.

#### OrderStatus State Machine (updated)

```
pending ──submitOrder──► submitted ──completeOrder──► completed
   └─────cancelOrder──────────────────────────────► cancelled
```

#### CheckoutBloc

```
Events:
  - CheckoutSubscriptionRequested  // subscribes to currentOrderStream for display
  - CheckoutConfirmed              // places the order

States (single CheckoutStatus enum):
  - loading     (awaiting order data from stream)
  - idle        (order loaded, form ready, button enabled)
  - submitting  (Place Order tapped, button disabled)
  - success     (order submitted — carries orderId for navigation)
  - failure     (null order guard or stream error — inline error shown)
```

**Handler logic for `CheckoutConfirmed`:**
1. Read `final orderId = state.order?.id` from already-loaded state (never from the repository directly)
2. If `orderId == null`, emit `failure` (guard for missing order in state)
3. Emit `submitting`
4. Call `orderRepository.submitCurrentOrder()`
5. Emit `success(orderId: orderId)`

`CheckoutView` uses `BlocConsumer`: listener navigates on `success`, builder renders the form.

> **No duplicate WS subscription**: `CheckoutBloc` subscribes to `currentOrderStream`, which maps over `ordersStream`. The `ordersStream` subscription was already opened by `CartBloc` — `_initOrdersIfNeeded` guards against a second WebSocket message.

#### OrderCompleteBloc

```
Events:
  - OrderCompleteSubscriptionRequested(orderId: String)

States:
  - OrderCompleteInitial    (loading)
  - OrderCompleteSuccess    (carries order: Order)
  - OrderCompleteFailure    (order not found / stream error)
```

Subscribes to `orderRepository.orderStream(orderId)` via `emit.forEach`. Uses the existing `ordersStream` subscription (already active from `CartBloc` — no duplicate WS messages).

**4-step tracker mapping:**

| `OrderStatus` | Active step |
|---|---|
| `pending` | Step 1 — "Placed" |
| `submitted` | Step 2 — "In Progress" |
| `completed` | Step 3 — "Ready" |
| `cancelled` | No step active (show neutral state) |

Step 4 ("Picked Up") is always rendered but never set active by the server — it is a visual terminal state.

#### Order Number Display

`#${order.id.substring(order.id.length - 4).toUpperCase()}` — no model changes required.

#### Navigation Decisions

- **Checkout → Order Complete**: `context.go('/menu/cart/checkout/confirmation/$orderId')` (from `BlocConsumer` listener on `CheckoutSuccess`)
- **Order Complete → Menu**: `context.go('/menu')` (from "Back to Menu" button)
- **Order Complete back button**: Disabled via `PopScope(canPop: false)` to prevent landing back on the Checkout screen with stale state after `_currentOrderId` has been cleared.

---

### Implementation Phases

#### Phase 1: Server + Repository Changes (Foundation)

> **Goal**: Enable the `submitted` status to be reached through the WS protocol.

**Server (`api/`)**

- [ ] In `api/lib/src/server_state.dart`: add `submitOrder` action handler that transitions order status `pending → submitted` and broadcasts to `orders` topic subscribers.
- [ ] Verify `completeOrder` already exists and transitions `submitted → completed` (or update it to accept `submitted` as the incoming status).

Files to modify:
- `api/lib/src/server_state.dart`

**OrderRepository (`shared/order_repository/`)**

- [ ] Add `submitCurrentOrder()` method to `OrderRepository`:
  - Captures `currentOrderId` to a local variable
  - Guards if `currentOrderId == null` (returns without sending)
  - Sends `_wsRpcClient.sendAction('submitOrder', {'orderId': currentOrderId})`
  - Sets `_currentOrderId = null`
- [ ] Keep `completeCurrentOrder()` as-is (out of scope for this feature)

Files to modify:
- `shared/order_repository/lib/src/order_repository.dart`

**Tests**
- [ ] `shared/order_repository/test/src/order_repository_test.dart`: add tests for `submitCurrentOrder()` — verifies correct WS action sent, verifies `currentOrderId` cleared, verifies no-op when `currentOrderId == null`

---

#### Phase 2: Router + Cart CTA (Routing & Navigation)

> **Goal**: Wire the new routes and add the entry point from Cart.

**Router (`applications/mobile_app/lib/app/app_router/app_router.dart`)**

- [ ] Import `checkout/checkout.dart` and `order_complete/order_complete.dart` barrel files (created in Phase 3/4)
- [ ] Add `routes` list to the `CartPage` `GoRoute`:

```dart
GoRoute(
  name: CartPage.routeName,
  path: CartPage.routePath,
  pageBuilder: ...,
  routes: [
    GoRoute(
      name: CheckoutPage.routeName,
      path: CheckoutPage.routePath, // 'checkout'
      pageBuilder: (context, state) => MaterialPage(
        name: CheckoutPage.routeName,
        child: CheckoutPage.pageBuilder(context, state),
      ),
      routes: [
        GoRoute(
          name: OrderCompletePage.routeName,
          path: OrderCompletePage.routePathTemplate, // 'confirmation/:orderId'
          pageBuilder: (context, state) => MaterialPage(
            name: OrderCompletePage.routeName,
            child: OrderCompletePage.pageBuilder(context, state),
          ),
        ),
      ],
    ),
  ],
),
```

**Cart CTA (`applications/mobile_app/lib/cart/view/cart_view.dart`)**

- [ ] Add a sticky "Proceed to Checkout" `_CheckoutButton` widget below the scroll area
- [ ] Only rendered when `state.order != null && state.order!.items.isNotEmpty`
- [ ] Tapping calls `context.go('/menu/cart/checkout')`
- [ ] Full-width, `context.colors.primary` background, `context.typography.button` style
- [ ] Displays total: "Proceed to Checkout — \$XX.XX"

**L10n additions**
- [ ] `cartProceedToCheckout` — `"Proceed to Checkout — {total}"`

**Tests**
- [ ] `test/cart/view/cart_view_test.dart`: add tests for "Proceed to Checkout" button — visible with items, hidden without items, navigates to `/menu/cart/checkout` on tap

---

#### Phase 3: Checkout Feature

> **Goal**: Implement `CheckoutBloc`, `CheckoutPage`, and `CheckoutView`.

**Directory structure:**
```
lib/checkout/
  bloc/
    checkout_bloc.dart      (CheckoutBloc, CheckoutEvent, CheckoutState)
    checkout_bloc.mapper.dart
  view/
    checkout_page.dart
    checkout_view.dart
    view.dart
  checkout.dart             (barrel export)
```

**`checkout_bloc.dart`**

```dart
// Sealed event base class — matches cart_event.dart pattern
@MappableClass()
sealed class CheckoutEvent with CheckoutEventMappable {
  const CheckoutEvent();
}

@MappableClass()
class CheckoutSubscriptionRequested extends CheckoutEvent
    with CheckoutSubscriptionRequestedMappable {
  const CheckoutSubscriptionRequested();
}

@MappableClass()
class CheckoutConfirmed extends CheckoutEvent with CheckoutConfirmedMappable {
  const CheckoutConfirmed();
}

// Single flat status enum — matches ItemDetailStatus pattern
@MappableEnum()
enum CheckoutStatus { loading, idle, submitting, success, failure }

@MappableClass()
class CheckoutState with CheckoutStateMappable {
  const CheckoutState({
    this.status = CheckoutStatus.loading,
    this.order,
    this.orderId,
    this.errorMessage,
  });
  final CheckoutStatus status;
  final Order? order;        // populated after stream emits
  final String? orderId;     // populated on success
  final String? errorMessage;
}
```

**Handler for `CheckoutSubscriptionRequested`** — mirrors `CartBloc._onSubscriptionRequested`:
```dart
await emit.forEach(
  _orderRepository.currentOrderStream,
  onData: (order) => order == null
      ? state.copyWith(status: CheckoutStatus.failure)
      : state.copyWith(order: order, status: CheckoutStatus.idle),
  onError: (_, _) => state.copyWith(status: CheckoutStatus.failure),
);
```

**Handler for `CheckoutConfirmed`:**
```dart
// Step 1: read orderId from already-loaded state — never call orderRepository.currentOrderId directly
final orderId = state.order?.id;
if (orderId == null) {
  emit(state.copyWith(status: CheckoutStatus.failure, errorMessage: '...'));
  return;
}
// Step 2: disable button and clear error
emit(state.copyWith(status: CheckoutStatus.submitting, errorMessage: null));
// Step 3: fire-and-forget WS action
_orderRepository.submitCurrentOrder();
// Step 4: optimistic success — navigate
emit(state.copyWith(status: CheckoutStatus.success, orderId: orderId));
```

**`checkout_page.dart`**

```dart
class CheckoutPage extends StatelessWidget {
  // routeName = 'checkout', routePath = 'checkout'
  // pageBuilder factory
  // BlocProvider(create: (_) => CheckoutBloc(orderRepository: context.read())
  //   ..add(const CheckoutSubscriptionRequested()))
}
```

**`checkout_view.dart`**

- `BlocConsumer<CheckoutBloc, CheckoutState>`
- **Listener**: on `CheckoutStatus.success` where `state.orderId != null`, navigate `context.go('/menu/cart/checkout/confirmation/${state.orderId}')`
- **Builder** renders:
  - `_CheckoutHeader` (back arrow → `context.go('/menu/cart')`)
    > Uses `context.go` (not `context.pop`) intentionally — replaces the route stack so the stale `CheckoutBloc` is disposed. `item_detail_view.dart` uses `context.pop()` for its back button, but Checkout requires full stack replacement to clean up after `_currentOrderId` has been cleared.
  - `_FakePaymentCard` — static cosmetic card, "Fake Payment · No real charge will be made" with checkmark icon; no user interaction
  - `_OrderSummarySection` — subtotal, tax, total read from `state.order` (populated by `CheckoutSubscriptionRequested`)
  - `_PlaceOrderButton` — displays "Place Order — \$XX.XX" using `state.order.grandTotal`; disabled when `status == submitting`, shows `CircularProgressIndicator` overlay; enabled when `status == idle | failure`
  - `_ErrorMessage` — shown below button when `status == failure`
- Shows `CircularProgressIndicator` full-screen when `status == loading`
- Shows error UI when `status == failure` and `state.order == null` (stream error on load)

**L10n additions**
- [ ] `checkoutTitle` — `"Checkout"`
- [ ] `checkoutFakePaymentLabel` — `"Fake Payment"`
- [ ] `checkoutFakePaymentSubtitle` — `"No real charge will be made"`
- [ ] `checkoutPlaceOrder` — `"Place Order — {total}"` (takes formatted total as param)
- [ ] `checkoutErrorRetry` — `"Something went wrong. Please try again."`

**Tests**

- [ ] `test/checkout/bloc/checkout_bloc_test.dart`:
  - Initial state is `CheckoutState(status: CheckoutStatus.loading)`
  - `CheckoutSubscriptionRequested` → emits `idle` with order when stream emits non-null order
  - `CheckoutSubscriptionRequested` → emits `failure` when stream emits `null` (no active order)
  - `CheckoutSubscriptionRequested` → emits `failure` on stream error
  - `CheckoutConfirmed` when `state.order` is null → emits `failure` (guard)
  - `CheckoutConfirmed` when order is loaded → emits `submitting` then `success` with captured `orderId`; verifies `submitCurrentOrder` called once
- [ ] `test/checkout/view/checkout_page_test.dart`: provides `CheckoutBloc`, renders `CheckoutView`
- [ ] `test/checkout/view/checkout_view_test.dart`:
  - Shows `CircularProgressIndicator` full-screen when `status == loading`
  - Shows error UI when `status == failure` and `order == null` (stream load error)
  - Shows order summary (subtotal, tax, total) when `status == idle`
  - Tapping "Place Order" dispatches `CheckoutConfirmed`
  - Button is disabled when `status == submitting`
  - Shows inline error message below button when `status == failure` and `order != null`
  - Navigates to `/menu/cart/checkout/confirmation/$orderId` when `status == success`
  - Back arrow navigates to `/menu/cart`

---

#### Phase 4: Order Complete Feature

> **Goal**: Implement `OrderCompleteBloc`, `OrderCompletePage`, and `OrderCompleteView` with real-time 4-step tracker.

**Directory structure:**
```
lib/order_complete/
  bloc/
    order_complete_bloc.dart
    order_complete_bloc.mapper.dart
  view/
    order_complete_page.dart
    order_complete_view.dart
    view.dart
  order_complete.dart        (barrel export)
```

**`order_complete_bloc.dart`**

```dart
// Events
@MappableClass()
class OrderCompleteSubscriptionRequested extends OrderCompleteEvent {
  const OrderCompleteSubscriptionRequested({required this.orderId});
  final String orderId;
}

// States
@MappableEnum()
enum OrderCompleteStatus { loading, success, failure }

@MappableClass()
class OrderCompleteState with OrderCompleteStateMappable {
  const OrderCompleteState({
    this.status = OrderCompleteStatus.loading,
    this.order,
  });
  final OrderCompleteStatus status;
  final Order? order;
}
```

Handler for `OrderCompleteSubscriptionRequested`:
- `emit.forEach(orderRepository.orderStream(event.orderId), ...)`
- `onData`: if `order == null`, emit `failure`; else emit `success(order: order)`
- `onError`: emit `failure`

**`order_complete_page.dart`**

```dart
class OrderCompletePage extends StatelessWidget {
  // routeName = 'order_complete'
  // routePathTemplate = 'confirmation/:orderId'
  // pageBuilder extracts orderId from state.pathParameters['orderId']
  // BlocProvider(create: (_) => OrderCompleteBloc(orderRepository: context.read())
  //   ..add(OrderCompleteSubscriptionRequested(orderId: orderId)))
}
```

**`order_complete_view.dart`**

- `PopScope(canPop: false, ...)` — prevents OS back navigation
- `BlocBuilder<OrderCompleteBloc, OrderCompleteState>`
- Shows `CircularProgressIndicator` when `status == loading`
- Shows error + "Back to Menu" when `status == failure`
- On `success`:
  - `_CelebratoryHero` — large icon + "Your order is confirmed!" headline + order number `#XXXX`
  - `_StatusTracker` — 4 steps with connectors (see tracker spec below)
  - `_OrderDetails` — total, itemized list of `LineItem`
  - `_BackToMenuButton` → `context.go('/menu')`

**`_StatusTracker` widget:**

```dart
class _StatusTracker extends StatelessWidget {
  // Accepts: OrderStatus status
  // Renders 4 step nodes with step labels:
  //   [1] Placed   [2] In Progress   [3] Ready   [4] Picked Up
  // Active step = activeStepIndex:
  //   pending   → 0 (step 1)
  //   submitted → 1 (step 2)
  //   completed → 2 (step 3)
  //   cancelled → -1 (no step — render all neutral)
  // Steps with index <= activeStepIndex are rendered as completed/filled
  // Step at activeStepIndex is pulsing / highlighted
  // Steps > activeStepIndex are unfilled
  // Step 4 (Picked Up) is always unfilled
}
```

**L10n additions**
- [ ] `orderCompleteTitle` — `"Order Confirmed!"`
- [ ] `orderCompleteOrderNumber` — `"Order #{number}"`
- [ ] `orderCompleteStep1` — `"Placed"`
- [ ] `orderCompleteStep2` — `"In Progress"`
- [ ] `orderCompleteStep3` — `"Ready"`
- [ ] `orderCompleteStep4` — `"Picked Up"`
- [ ] `orderCompleteOrderDetailsLabel` — `"Your Order"`
- [ ] `orderCompleteBackToMenu` — `"Back to Menu"`
- [ ] `orderCompleteCancelledLabel` — `"Order Cancelled"` (for `cancelled` status neutral display)

**Tests**

- [ ] `test/order_complete/bloc/order_complete_bloc_test.dart`:
  - Initial state is `OrderCompleteInitial`
  - `OrderCompleteSubscriptionRequested` → emits `success` with order when stream emits order
  - `OrderCompleteSubscriptionRequested` → emits `failure` when stream emits `null`
  - `OrderCompleteSubscriptionRequested` → emits `failure` on stream error
  - Multiple stream emissions update the order state
- [ ] `test/order_complete/view/order_complete_page_test.dart`
- [ ] `test/order_complete/view/order_complete_view_test.dart`:
  - Shows loading indicator when `status == loading`
  - Shows error UI + "Back to Menu" when `status == failure`
  - Shows order number `#` + last 4 uppercase chars of id when `status == success`
  - Shows correct grand total
  - Step 1 is filled when order status is `pending`, `submitted`, or `completed`
  - Step 2 is active when order status is `submitted`
  - Step 3 is active when order status is `completed`
  - All steps are neutral (unfilled) when order status is `cancelled`
  - Tapping "Back to Menu" navigates to `/menu`
  - OS back is blocked (`PopScope(canPop: false)`)

---

## Alternative Approaches Considered

### OrderCompleteBloc: `order:<id>` WS topic vs `ordersStream` filter

The brainstorm doc proposed a new `subscribeToOrder(String orderId)` method on `OrderRepository` that subscribes to the `order:<id>` WS topic directly. The existing `orderStream(orderId)` instead maps over the `orders` topic (which is already subscribed).

**Decision**: Use `orderStream(orderId)`. No new repository method is needed, no additional WS subscription is opened, and the `CartBloc` has already started the `ordersStream` subscription by the time `OrderCompleteBloc` initializes. The `order:<id>` topic approach would be preferable in a high-volume production system where subscribing to all orders is expensive, but for this app's scale it is unnecessary.

### CheckoutBloc: optimistic success vs. server acknowledgement

Because `sendAction` is fire-and-forget (no server acknowledgement), `CheckoutBloc` cannot truly know if the order was submitted. Two options:
1. Optimistic: emit `success` after calling `submitCurrentOrder()` (chosen approach)
2. Confirmatory: wait for `orderStream(orderId)` to emit status `submitted` before emitting `success`

**Decision**: Optimistic success. The confirmatory approach adds latency and complexity for a demo app with reliable local server. The failure case covers only the null `currentOrderId` guard. This decision should be revisited if a network-unreliable production environment is targeted.

### CartView CTA placement: sticky footer vs. in-scroll

**Decision**: Sticky footer (outside the `SingleChildScrollView`), consistent with the "Place Order" CTA pattern on CheckoutView. This matches the design file and ensures the button is always reachable without scrolling.

---

## Acceptance Criteria

### Functional Requirements

**Cart screen**
- [ ] "Proceed to Checkout — \$XX.XX" button is visible when cart has at least one item
- [ ] Button is hidden when cart is empty
- [ ] Tapping the button navigates to `/menu/cart/checkout`
- [ ] Displayed total reflects `order.grandTotal` in dollars

**Checkout screen**
- [ ] Back arrow navigates to `/menu/cart`
- [ ] Fake Payment card is rendered (purely cosmetic, no tappable action)
- [ ] Order summary shows subtotal, tax (8%), and total matching `Order` model values
- [ ] "Place Order — \$XX.XX" button is visible and enabled when `status == idle | failure`
- [ ] "Place Order" button is disabled and shows a loading indicator when `status == submitting`
- [ ] Tapping "Place Order" dispatches `CheckoutConfirmed`
- [ ] On success, app navigates to `/menu/cart/checkout/confirmation/$orderId`
- [ ] On failure, inline error message appears beneath the button
- [ ] OS back gesture / hardware back button returns to `/menu/cart`

**Order Complete screen**
- [ ] Screen displays order number `#` followed by the last 4 uppercase characters of the order UUID
- [ ] 4-step tracker is rendered with labels: Placed, In Progress, Ready, Picked Up
- [ ] Step 1 is filled/active when `OrderStatus` is `pending`, `submitted`, or `completed`
- [ ] Step 2 is active when `OrderStatus == submitted`
- [ ] Step 3 is active when `OrderStatus == completed`
- [ ] No step is active when `OrderStatus == cancelled` (all steps neutral)
- [ ] Status tracker updates in real time as WS updates arrive
- [ ] Itemized line items are displayed (name, options, quantity, price)
- [ ] Grand total is displayed
- [ ] "Back to Menu" button navigates to `/menu`
- [ ] OS back gesture and Android hardware back are blocked (`PopScope(canPop: false)`)

**Server (demo)**
- [ ] `submitOrder` WS action transitions order from `pending → submitted`
- [ ] `completeOrder` WS action continues to work (transitions `submitted → completed` or `pending → completed`)
- [ ] Both actions broadcast updates to `orders` topic subscribers

**OrderRepository**
- [ ] `submitCurrentOrder()` sends `submitOrder` action with `currentOrderId`
- [ ] `submitCurrentOrder()` sets `_currentOrderId = null` after sending
- [ ] `submitCurrentOrder()` is a no-op when `currentOrderId == null`

### Non-Functional Requirements

- [ ] All new Bloc classes use `@MappableClass` / `@MappableEnum` and generate `.mapper.dart` files
- [ ] All navigation uses `context.go('/hardcoded/path')` — no `pushNamed`, `goNamed`, `push`, or `extra`
- [ ] All new user-facing strings are in `app_en.arb` (no hardcoded strings in widgets)
- [ ] New widgets use `context.colors`, `context.typography`, `context.spacing` from the design system

### Quality Gates

- [ ] All new Bloc classes have bloc unit tests (using `bloc_test`, `mocktail`)
- [ ] All new view/page classes have widget tests (using `pumpApp`, `MockBloc`)
- [ ] All existing tests continue to pass
- [ ] `flutter analyze` reports zero issues

---

## Success Metrics

The feature is successful when a user can:
1. Add items to the cart
2. Tap "Proceed to Checkout" and see their order summary
3. Tap "Place Order" and land on the Order Complete screen with order number and tracker
4. Watch the tracker update in real time (step 1 → step 2 → step 3) as the server progresses the order
5. Tap "Back to Menu" to start a new order

---

## Dependencies & Prerequisites

| Dependency | Status | Notes |
|---|---|---|
| CartPage / CartBloc | ✅ Exists | `lib/cart/` — needs CTA addition |
| `OrderRepository.ordersStream` | ✅ Exists | Used by `OrderCompleteBloc` |
| `OrderRepository.orderStream(id)` | ✅ Exists | Used by `OrderCompleteBloc` |
| `OrderRepository.completeCurrentOrder()` | ✅ Exists | Stays for barista use |
| `OrderRepository.submitCurrentOrder()` | ❌ Missing | **Phase 1 deliverable** |
| `submitOrder` server action | ❌ Missing | **Phase 1 deliverable** |
| `OrderStatus.submitted` | ✅ Exists | Enum value already in model |
| `pumpApp` test helper | ✅ Exists | `test/helpers/pump_app.dart` |
| `MockGoRouter` test helper | ✅ Exists | `test/helpers/go_router.dart` |

---

## Risk Analysis & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `submitted` status never reached if server change is skipped | High | High | Phase 1 is a prerequisite; tracker devolves to 2 states otherwise |
| `_currentOrderId` cleared before `CheckoutBloc` uses it | Low | High | `CheckoutConfirmed` reads `state.order?.id` — never touches `orderRepository.currentOrderId` directly |
| OS back from Order Complete lands on stale Checkout | Medium | Medium | `PopScope(canPop: false)` prevents back navigation entirely |
| `orderStream(orderId)` emits `null` (server restart) | Low | Low | `OrderCompleteBloc` emits `failure` state with fallback UI |
| Cart CTA shows stale total on slow WS | Low | Low | `CheckoutBloc` subscribes live to `currentOrderStream` — always fresh |

---

## References & Research

### Internal References

- Brainstorm: [wingspan/brainstorms/2026-02-24-checkout-flow-brainstorm-doc.md](wingspan/brainstorms/2026-02-24-checkout-flow-brainstorm-doc.md)
- Router: [applications/mobile_app/lib/app/app_router/app_router.dart](applications/mobile_app/lib/app/app_router/app_router.dart)
- CartBloc pattern: [applications/mobile_app/lib/cart/bloc/cart_bloc.dart](applications/mobile_app/lib/cart/bloc/cart_bloc.dart)
- CartPage pattern: [applications/mobile_app/lib/cart/view/cart_page.dart](applications/mobile_app/lib/cart/view/cart_page.dart)
- ItemDetailBloc (async mutation pattern): [applications/mobile_app/lib/item_detail/bloc/item_detail_bloc.dart:87](applications/mobile_app/lib/item_detail/bloc/item_detail_bloc.dart#L87)
- OrderRepository: [shared/order_repository/lib/src/order_repository.dart](shared/order_repository/lib/src/order_repository.dart)
- Order model + OrderStatus enum: [shared/order_repository/lib/src/models/order.dart](shared/order_repository/lib/src/models/order.dart)
- L10n (English): [applications/mobile_app/lib/l10n/arb/app_localizations_en.dart](applications/mobile_app/lib/l10n/arb/app_localizations_en.dart)
- Test helpers: [applications/mobile_app/test/helpers/pump_app.dart](applications/mobile_app/test/helpers/pump_app.dart)
- Cart view test (pattern reference): [applications/mobile_app/test/cart/view/cart_view_test.dart](applications/mobile_app/test/cart/view/cart_view_test.dart)

### Related Work

- PR: cart page implementation — #22
- PR: item detail / add-to-cart — #21
