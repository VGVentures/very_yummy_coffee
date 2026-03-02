---
date: 2026-02-24
topic: checkout-flow
---

# Checkout Flow (Mobile App)

## What We're Building

A two-screen checkout flow that lets users review and confirm their cart, then track their order in real-time after placing it. The flow is: **Cart → Checkout → Order Complete**.

The **Checkout screen** (`/menu/cart/checkout`) shows a static "Fake Payment" badge (no real payment processing), the order summary (subtotal, tax, total), and a prominent "Place Order — $XX.XX" CTA. The **Order Complete screen** (`/menu/cart/checkout/confirmation/:orderId`) shows a celebratory hero section, a live 4-step status tracker that updates in real-time via WebSocket, the order number, total, and itemized list, and a "Back to Menu" button.

## Why This Approach

We considered: (a) adding a Place Order button directly to CartPage, (b) a single checkout screen, and (c) the current two-screen approach with a dedicated confirmation. The two-screen approach was chosen because it creates clear intent separation — the cart is an editable workspace, checkout is a commitment point, and the confirmation gives live order tracking. The design in `design.pen` already specifies both screens in detail, confirming this direction.

For state management, the user preferred **separate BLoCs per screen** to keep concerns isolated:
- `CheckoutBloc` — drives the checkout screen (idle → submitting → success | failure)
- `OrderCompleteBloc` — subscribes to `order:<id>` WS topic for real-time status updates on the confirmation screen

## Key Decisions

- **Route structure**: New nested routes under `/menu/cart`:
  - `/menu/cart/checkout` → `CheckoutPage`
  - `/menu/cart/checkout/confirmation/:orderId` → `OrderCompletePage`

- **CheckoutBloc**: Handles one event (`CheckoutConfirmed`). Captures the current order ID, calls `orderRepository.completeCurrentOrder()`, and emits `submitting → success` (or `failure` on error). On `success`, `CheckoutView` uses `BlocConsumer` to navigate to `/menu/cart/checkout/confirmation/$orderId`.

- **OrderCompleteBloc**: On init, subscribes to `order:<id>` topic for real-time status updates. Emits the full `Order` object as state updates arrive — this drives the 4-step status tracker. Receives the order ID from the route path parameter. `OrderRepository` exposes a new `subscribeToOrder(String orderId)` method that delegates to `WsRpcClient.subscribe('order:$orderId')` and unsubscribes on dispose.

- **4-step status tracker**: The tracker maps `OrderStatus` to step index as follows:
  - Step 1 "Placed" — always complete once on this screen
  - Step 2 "In Progress" — active when status is `submitted`
  - Step 3 "Ready" — active when status is `completed`
  - Step 4 "Picked Up" — visual-only terminal step; not driven by a server status. The user leaves this screen by tapping "Back to Menu", which acts as the implicit "Picked Up" confirmation.

- **Order number display**: The Order Complete screen shows a short order number (`#XXXX`). This is derived from the last 4 characters of the order UUID — no model changes required.

- **Fake Payment card**: Purely cosmetic on the Checkout screen. Renders a static "Fake Payment / No real charge will be made" card with a checkmark. No user interaction, no bloc event.

- **Error handling**: Checkout failure shows an inline error state beneath the "Place Order" button. The button re-enables for retry. No navigation away from the screen.

- **Navigation**: `context.go('/menu/cart/checkout/confirmation/$orderId')` from Checkout on success; `context.go('/menu')` from Order Complete via "Back to Menu". Hardcoded path strings per CLAUDE.md.

## Open Questions

- Should the Order Complete screen show a distinct error/cancelled state if `OrderStatus` becomes `cancelled`? The design doesn't show this path. Simplest default: treat `cancelled` the same as an unknown status (no step highlighted).
- Does the "Back to Menu" button on Order Complete need to also send a `cancelOrder` action if the order is still `submitted` (i.e., the user leaves before the barista marks it ready)? Likely no — the backend manages order lifecycle independently.
