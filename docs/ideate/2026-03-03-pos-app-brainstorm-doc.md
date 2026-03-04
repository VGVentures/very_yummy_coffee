---
date: 2026-03-03
topic: pos-app
---

# POS App

## What We're Building

A new Flutter application (`applications/pos_app`) targeting iPads (iOS), providing a
Point-of-Sale interface for café staff. The app lets a cashier browse the menu, build a
customer's order, charge it, and review in-progress and historical orders — all over the
same WebSocket RPC infrastructure used by the kiosk and KDS apps.

The POS app follows every established pattern in the monorepo: `go_router` with redirect
guards, `Bloc` with explicit event classes, `dart_mappable` for state serialization,
`very_yummy_coffee_ui` for design tokens and shared widgets, and shared packages for all
data access.

## Screens

| Screen | Route | Description |
|---|---|---|
| Connecting | `/connecting` | Standard WS connecting indicator (shared pattern) |
| POS Order | `/pos-order` | Main screen — menu grid (left) + order ticket (right) |
| POS Order Complete | `/pos-order-complete/:orderId` | Charge success + receipt |
| POS Orders | `/pos-orders` | In-progress cards + order history table |

## Why This Approach

**Navigation: Order creation as primary screen.** The root route after connecting is
`/pos-order`. Cashiers spend most of their time here. The `/pos-orders` view is a
secondary destination reached via a button in the dark top bar (`context.go('/pos-orders')`).
After charging, the router navigates to `/pos-order-complete/:orderId`, and "New Order"
returns to a fresh `/pos-order`. This avoids an extra navigation hop on the most common
workflow.

**Rejected alternative — Orders list as hub:** Would make sense if cashiers frequently
consult order history between every order, but for a coffee counter this adds friction to
the primary "take an order" flow.

## Key Decisions

- **Platform**: iOS only (iPad). `pubspec.yaml` targets iOS. Design is 1440×900 for
  mockup purposes but the implementation adapts to iPad landscape.
- **No staff auth**: Staff name and login are out of scope. The top bar shows only the
  app title, status dot, and clock.
- **Reuse `completeOrder`**: The "Charge" button calls the existing `completeOrder` WS
  action. No new backend action is required.
- **New application package**: `applications/pos_app` with `name:
  very_yummy_coffee_pos_app`. Follows the same structure as `kds_app` and `mobile_app`.
- **Repositories needed**: `MenuRepository` (menu grid + category tabs) +
  `OrderRepository` (order ticket mutations) + `ConnectionRepository` (WS status guard).
- **Two blocs for the POS Order screen**:
  - `MenuBloc` — owns the left panel: subscribes to `MenuRepository`, manages category
    tab selection (local state), and calls `orderRepository.addItemToCurrentOrder(...)`
    when the cashier taps an item. No order ID needed — the repository tracks it.
  - `OrderTicketBloc` — owns the right panel: calls `orderRepository.createOrder()` on
    init and on "New Order" (UUID is generated inside the repository), subscribes to
    `orderRepository.currentOrderStream`, and calls `completeCurrentOrder()` /
    `cancelOrder(currentOrderId)`. **"Clear"** cancels the current order and shows an
    empty ticket; the cashier taps "New Order" to begin the next one. After
    `completeCurrentOrder()` the bloc emits a navigate event carrying the orderId (captured
    before clearing) so the router can push `/pos-order-complete/:orderId`.
  - Both blocs receive the same `OrderRepository` instance and coordinate through it —
    no UUID is passed between the Page and the blocs.
- **Blocs per screen**:
  - `/pos-order` → `MenuBloc` + `OrderTicketBloc` (two providers on `PosOrderPage`)
  - `/pos-order-complete/:orderId` → `PosOrderCompleteBloc`: receives orderId from the
    route path parameter and subscribes to `orderRepository.orderStream(orderId)` for
    the receipt. Uses orderId from the route, not `currentOrderId` (which is already
    cleared at this point).
  - `/pos-orders` → `PosOrdersBloc`: subscribes to `orderRepository.ordersStream`.
- **Category tabs are dynamic**: Tab labels are generated from `MenuGroup` names delivered
  by `MenuRepository`. An "All" tab is always prepended. Selected tab is local state
  inside `MenuBloc`, filtering the item grid client-side.
- **Order history scope**: The `/pos-orders` screen includes both in-progress order cards
  and an Order History table. The history table requires completed orders to be present in
  `ordersStream`. **Risk**: the server may currently only push active orders. This must be
  verified during planning; a backend change may be needed to include
  completed/cancelled orders in the orders snapshot.
- **UI is POS-specific**: The top bar (dark `$--foreground` background), menu item grid,
  order ticket, and receipt panel are new widgets. They live in `pos_app` unless reused
  across two or more apps, in which case they graduate to `very_yummy_coffee_ui`.
- **GitHub Actions**: After committing `pubspec.yaml`, run
  `.github/update_github_actions.sh` and commit the regenerated workflow file.

## Open Questions

- **Order history backend risk**: Does `ServerState.broadcastToSubscribers('orders', ...)`
  include completed/cancelled orders in the snapshot, or only active ones? Verify during
  planning. If not, the orders update payload needs to include all orders regardless of
  status.
- **iPad orientation**: Does the split-panel layout need to support portrait orientation,
  or is landscape-only acceptable for a fixed POS terminal?
- **Clock**: Static string set at widget build time is sufficient (YAGNI over a live
  ticker). Confirm during implementation.
