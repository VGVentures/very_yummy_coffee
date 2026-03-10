---
date: 2026-03-10
topic: edit-pending-orders
issue: https://github.com/VGVentures/very-yummy-coffee/issues/42
---

# Edit Pending Orders from POS Orders Page

## What We're Building

Allow baristas to tap a pending order on the POS "Orders" page, load it as the current order on the ordering screen, modify it (add/remove items, change customer name), and re-submit it. This closes the gap where pending orders (created but not yet submitted) are currently visible but not actionable on the Orders page.

## Why This Approach

We considered two approaches:

1. **Add `setCurrentOrderId(orderId)` to OrderRepository** — set the existing order as the current order and navigate to `/ordering`. The `OrderTicketBloc` already guards against creating a duplicate order when `_currentOrderId` is set.

2. **Pass `editOrderId` as a route parameter** to `/ordering` and handle it in `OrderTicketBloc`. This makes the "editing" intent explicit in the URL but requires the same repository method plus additional routing complexity.

**We chose Approach 1** because it's simpler, requires no navigation changes, and follows the existing pattern where `_currentOrderId` drives all current-order behavior. The `currentOrderStream` automatically emits the correct order once the ID is set.

## Key Decisions

- **Conflict resolution (current order exists):** Always call `clearCurrentOrder()` before loading the tapped pending order. This cancels any in-progress order on the server and clears `_currentOrderId`. The barista explicitly chose to switch, so cancelling the previous order is the correct behavior even if it had items.
- **Re-submit flow:** Re-submitting a modified order uses the same `submitOrder` action and navigates to `/order-complete/:orderId`. No new server logic needed.
- **UI entry point:** Tap the whole pending order card to edit. Add a subtle visual cue (e.g. edit icon or "Tap to edit" hint) to make it discoverable.
- **Non-pending orders stay read-only:** Only orders with `status == pending` are tappable for editing.

## Implementation Sketch

### OrderRepository changes
- Add `setCurrentOrderId(String orderId)` — a simple setter that assigns `_currentOrderId` without sending any RPC action. No validation (the caller is responsible for passing a valid pending order ID). The `currentOrderStream` (derived from `ordersStream`) will automatically start emitting that order.

### OrderHistoryBloc changes
- Add `OrderHistoryEditOrderRequested(orderId)` event.
- Handler: call `orderRepository.clearCurrentOrder()` (if needed), then `orderRepository.setCurrentOrderId(orderId)`.
- Emit a state that signals navigation to `/ordering`.

### OrderHistoryView changes
- Wrap pending order cards in `GestureDetector` / `InkWell`.
- On tap, dispatch `OrderHistoryEditOrderRequested(order.id)`.
- Listen for the navigation state and call `context.go('/ordering')`.
- Add visual affordance to pending cards (edit icon or subtle hint text).

### OrderTicketBloc — no changes needed
- `_onCreateOrderRequested` already guards: `if (currentOrderId != null) return;`
- Since `setCurrentOrderId` sets the ID before navigation, the guard prevents creating a new order.
- `currentOrderStream` will emit the loaded order, and the UI renders it normally.

### OrderTicketView — minor adjustment
- The `OrderTicket` widget tracks `_controllerOrderId` to reset the `TextEditingController` when the order changes. When loading an existing order that already has a `customerName`, the controller must initialize with that name. The existing reset logic (comparing `_controllerOrderId` to the new order ID) should handle this naturally, but verify during implementation.

### Server — no changes needed
- All existing RPC actions (addItem, updateQuantity, updateName, submit) work on any order by ID.
- The server already validates status transitions.

## Open Questions

- Should the pending order cards have a distinct visual treatment (beyond the existing gray styling) to indicate they're tappable? Or is the tap-to-edit behavior self-evident in context?
