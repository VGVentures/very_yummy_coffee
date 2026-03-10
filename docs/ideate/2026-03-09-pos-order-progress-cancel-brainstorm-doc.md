---
date: 2026-03-09
topic: pos-order-progress-cancel
issue: https://github.com/VGVentures/very-yummy-coffee/issues/43
---

# Progress and Cancel Orders from POS App

## What We're Building

Adding order progression (submitted -> in-progress -> ready -> completed) and cancellation actions to the POS app's order history screen. Baristas will be able to manage order lifecycle directly from the POS, matching the capabilities already available in the KDS app. All actions use existing WebSocket RPC methods — no backend or shared package changes needed.

## Why This Approach

### Approaches Considered

1. **Inline buttons on active order cards (chosen)** — Add a primary action button (Start / Mark Ready / Complete) and a Cancel text button directly to the existing `_ActiveOrderCard` in the order history view. Mirrors the KDS `KdsOrderCard` pattern. No new screens, routes, or navigation flows.

2. **Tap card -> side detail panel** — Tapping an active order card opens a detail panel alongside the card list. Provides more room for order details but adds layout complexity, a new widget, and selection state management for minimal benefit (cards already show key info).

3. **Tap card -> modal dialog** — Tapping an active order card opens a dialog with full details and actions. Keeps the main layout untouched but adds a tap-then-act flow that slows baristas down during rush periods.

**Decision:** Inline buttons are the simplest change, require no new navigation, and match the proven KDS pattern. The POS active cards already display enough context (order number, customer name, items summary, total, status) for a barista to confidently act.

### Cancel Confirmation

The issue requires a confirmation step before cancelling. The KDS currently has no confirmation dialog. For the POS, we'll use a standard `AlertDialog` with "Cancel Order #XXXX?" title, a brief warning message, and No / Yes action buttons. This is simple, familiar, and prevents accidental cancellations.

## Key Decisions

- **Inline on cards**: Action buttons added directly to `_ActiveOrderCard`, no new screens or navigation
- **AlertDialog for cancel confirmation**: Standard dialog, meets acceptance criteria with minimal custom UI
- **Extend `OrderHistoryBloc`**: Add progression and cancellation events to the existing bloc (follows KDS pattern of having order management events in the same bloc that subscribes to orders)
- **No shared package changes**: All needed repository methods (`startOrder`, `markOrderReady`, `markOrderCompleted`, `cancelOrder`) already exist
- **Button label maps to next status**: submitted -> "Start", inProgress -> "Mark Ready", ready -> "Complete"
- **Progress button on all active orders**: submitted ("Start"), inProgress ("Mark Ready"), ready ("Complete")
- **Cancel button on submitted and inProgress only**: Ready orders can only be completed, not cancelled. Pending/completed/cancelled orders have no actions.
- **No loading states on action buttons**: Actions fire-and-forget over WS; the server broadcasts the updated state back. The card will update reactively when the new status arrives. No spinner needed.

## Open Questions

- Should the KDS also get a cancel confirmation dialog for consistency? (Out of scope for this issue, but worth noting the inconsistency.)
