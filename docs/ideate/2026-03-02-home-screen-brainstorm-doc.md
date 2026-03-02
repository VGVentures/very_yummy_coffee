---
date: 2026-03-02
topic: home-screen
---

# Home Screen

## What We're Building

A new `/home` route that serves as the post-connection landing page for the mobile app. The screen shows a user's active (non-completed, non-cancelled) orders in a card-based list with a step-progress tracker, and a prominent "Start New Order" CTA that navigates to the menu.

The Home screen replaces `/menu` as the default destination after the WebSocket connection is established. Users who have no active orders see a friendly empty state and can tap "Start New Order" to browse the menu.

## Design Reference

The screen design was created in `design.pen` (canvas position x=-500, y=0):

- **Header**: Primary-colored bar with coffee icon, app title, and time-based greeting
- **Body**: "Your Orders" section with "N active" badge; order cards showing order #, item count + total, status pill, and 4-step progress tracker (Placed → Brewing → Ready → Picked Up)
- **Bottom bar**: Fixed `+ Start New Order` primary CTA button

## Why This Approach

**Navigation**: Home replaces `/menu` as the landing page (not a bottom tab bar). The design has no tab bar, and the existing `BottomTabBar` widget adds routing complexity (shell routes) without being needed yet. A single `/home` route with `context.go('/menu')` for the CTA keeps routing simple.

**Order filtering**: Only active orders (pending, submitted, ready) are shown. Completed/cancelled orders are hidden. This keeps the screen focused and avoids building an order history view.

**Status mapping**: A `ready` status is added to the backend so all four visual steps have a real backend state. This is better than fudging the mapping and gives baristas a proper "mark as ready" action.

**Step tracker widget**: The progress tracker is used on both the Home screen and the existing Order Complete screen. Per the CLAUDE.md shared-widget guidance, it belongs in `shared/very_yummy_coffee_ui`.

## Key Decisions

- **Replace /menu as landing**: Update the router redirect so connected users go to `/home` instead of `/menu`. Existing `/menu` route is unchanged.
- **Add `ready` to `OrderStatus`**: Extend the enum in `very_yummy_coffee_models` and add a `markOrderReady` WS action in `server_state.dart`. Status step mapping: `pending` → Placed, `submitted` → Brewing, `ready` → Ready, `completed` → Picked Up.
- **Filter in HomeBloc**: HomeBloc subscribes to `ordersStream` and filters to active orders in the state mapping (`onData`), consistent with how CartBloc filters via `currentOrderStream`.
- **Extract OrderStepTracker to shared UI**: Create `OrderStepTracker` widget in `very_yummy_coffee_ui` and update `OrderCompleteView` to use it.
- **Time-based greeting**: "Good morning/afternoon/evening" computed from `DateTime.now().hour` in the view — no Bloc involvement needed.
- **"Start New Order" navigates to /menu**: `context.go('/menu')` — order creation still happens when the first item is added (no change to existing flow).

## Implementation Scope

### 1. Backend + Models (`api`, `very_yummy_coffee_models`, `order_repository`)

- Add `ready` to `OrderStatus` enum in `very_yummy_coffee_models`
- Add `markOrderReady` action to WS protocol in `server_state.dart` (backend-only; no mobile UI trigger in this ticket)
- Regenerate `dart_mappable` code in `very_yummy_coffee_models` and `order_repository`

### 2. Shared UI (`very_yummy_coffee_ui`)

- Extract `OrderStepTracker` widget (4-step progress indicator) from `OrderCompleteView` into the shared package
- Update `OrderCompleteView` to use the extracted widget

### 3. Mobile App (`mobile_app`)

- New `lib/home/` feature directory:
  - `HomeBloc` / `HomeEvent` (sealed, `HomeSubscriptionRequested`) / `HomeState` (`orders: List<Order>`, `HomeStatus`)
  - `HomePage` (BlocProvider + fires initial event) + `HomeView` (renders header, order list, bottom bar)
- Update `AppRouter`:
  - Add `/home` as a top-level `GoRoute`
  - Change redirect for connected users from `MenuGroupsPage.routeName` → `HomePage.routeName`
- Widget tests with `pumpApp` helper

## Open Questions

- **Order ID display format** _(resolved)_: Show `#XXXX` using the last 4 characters of the UUID uppercased — `order.id.substring(order.id.length - 4).toUpperCase()`. No backend change needed.
- Should tapping an order card on Home navigate somewhere (e.g., `/menu/cart`)? The design doesn't show tap behavior — assume no navigation for now, revisit when order-detail screen is designed.
- Who calls `markOrderReady`? Presumably a barista admin screen (not yet designed). The `ready` status is added to the model and backend now so the enum is stable when that screen is built; `markOrderReady` will be untested from the mobile side until then.
