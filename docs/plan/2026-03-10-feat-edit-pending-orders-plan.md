---
title: "feat: edit pending orders from POS Orders page"
type: feat
date: 2026-03-10
issue: https://github.com/VGVentures/very-yummy-coffee/issues/42
brainstorm: docs/ideate/2026-03-10-edit-pending-orders-brainstorm-doc.md
---

## feat: edit pending orders from POS Orders page

## Overview

Allow baristas to tap a pending order on the POS "Orders" page, load it as the current order on the ordering screen, modify it (add/remove items, change customer name), and re-submit it. This closes the gap where pending orders are visible but not actionable.

## Problem Statement / Motivation

Pending orders accumulate when baristas start an order but navigate away before submitting. Currently these orders are visible on the Orders page at reduced opacity but cannot be resumed — the barista must start a fresh order and re-enter everything. This wastes time during busy shifts and leaves orphaned pending orders on the server.

## Proposed Solution

Add `setCurrentOrderId(orderId)` to `OrderRepository` — a simple setter that makes an existing order the "current order" without any RPC action. The `currentOrderStream` (derived from `ordersStream`) automatically starts emitting that order. On the Orders page, wrap pending order cards in a tap handler that clears any existing current order, sets the tapped order as current, and navigates to `/ordering`.

The existing `OrderTicketBloc` already guards against creating a new order when `currentOrderId` is set, and the `OrderTicket` widget already resets its `TextEditingController` when the order ID changes. No new server logic is required — all existing RPC actions work on any order by ID.

## Technical Considerations

### Same-order identity guard

If the barista taps the pending order that is already the current order, `clearCurrentOrder()` would cancel it on the server before `setCurrentOrderId` re-assigns the (now cancelled) ID. **Guard**: if `tappedOrderId == orderRepository.currentOrderId`, skip `clearCurrentOrder()` and navigate directly. This is a single `if` check in the bloc handler.

### Server-side mutation guards (out of scope)

`addItemToOrder` and `updateItemQuantity` have no status guards on the server — items can be added to submitted/cancelled orders. `updateNameOnOrder` correctly guards for `pending` status. Adding server guards is desirable but out of scope for this PR. Document as a follow-up.

### Navigation approach

Navigation is handled directly in the view's `onTap` callback — dispatch the bloc event (which calls the synchronous repository methods), then call `context.go('/ordering')`. No navigation state field in the bloc. Both `clearCurrentOrder()` and `setCurrentOrderId()` are synchronous `void` methods, so the repository state is updated before navigation occurs.

## Implementation Phases

### Phase 1: OrderRepository — add `setCurrentOrderId`

**File:** `shared/order_repository/lib/src/order_repository.dart`

- [ ] Add `void setCurrentOrderId(String orderId)` — sets `_currentOrderId = orderId`. No RPC action. Include a debug assertion that the caller should only pass pending order IDs: `assert(orderId.isNotEmpty)`.

**Test file:** `shared/order_repository/test/src/order_repository_test.dart`

- [ ] Test that `setCurrentOrderId` updates `currentOrderId` getter.
- [ ] Test that `currentOrderStream` emits the matching order on the next `ordersStream` update (not immediately — the stream derives from `ordersStream.map()`).
- [ ] Test that `setCurrentOrderId` does not send any WS action (verify no interactions on the mock `WsRpcClient`).

### Phase 2: OrderHistory feature — bloc event, view tap handler, visual treatment

**File:** `applications/pos_app/lib/order_history/bloc/order_history_event.dart`

- [ ] Add `OrderHistoryPendingOrderResumeRequested` event with `orderId` field (follows existing naming pattern: events describe user intent).

**File:** `applications/pos_app/lib/order_history/bloc/order_history_bloc.dart`

- [ ] Register handler for `OrderHistoryPendingOrderResumeRequested`.
- [ ] Handler logic (synchronous — no `async` needed):
  1. If `event.orderId != _orderRepository.currentOrderId`, call `_orderRepository.clearCurrentOrder()`.
  2. Call `_orderRepository.setCurrentOrderId(event.orderId)`.
  - Note: No state emission needed — navigation is handled by the view.

**File:** `applications/pos_app/lib/order_history/view/order_history_view.dart`

- [ ] Remove `Opacity(opacity: 0.6)` wrapper on pending cards. Render at full opacity.
- [ ] Wrap pending cards in `InkWell` (not `GestureDetector` — provides visual tap feedback/ripple). Note: may need a `Material` ancestor for the ripple to render correctly over the decorated `Container`.
- [ ] `onTap` handler: dispatch `OrderHistoryPendingOrderResumeRequested(order.id)`, then call `context.go('/ordering')`.
- [ ] Add visual affordance to pending cards: add an edit icon or subtle hint text. If text is used, add l10n key `ordersPendingEditHint` to `applications/pos_app/lib/l10n/arb/app_en.arb`.

**Test file:** `applications/pos_app/test/order_history/bloc/order_history_bloc_test.dart`

- [ ] Test `OrderHistoryPendingOrderResumeRequested` calls `clearCurrentOrder()` then `setCurrentOrderId()`.
- [ ] Test identity guard: when `event.orderId == currentOrderId`, verify `clearCurrentOrder()` is NOT called but `setCurrentOrderId()` IS called.

**Test file:** `applications/pos_app/test/order_history/view/order_history_view_test.dart`

- [ ] Test that tapping a pending order card dispatches `OrderHistoryPendingOrderResumeRequested`.
- [ ] Test that non-pending order cards are NOT tappable for editing.
- [ ] Test pending cards render at full opacity (update existing `Opacity(0.6)` test).
- [ ] Test that tapping navigates to `/ordering`.

### Phase 3: Verify end-to-end flow

- [ ] Manually verify: tap pending order -> loads on ordering screen -> modify items -> submit -> order-complete.
- [ ] Verify `TextEditingController` seeds with existing `customerName`.
- [ ] Verify tapping the same order that's already current navigates without cancelling it.

## Acceptance Criteria

- [ ] Tapping a pending order on the POS Orders page navigates to the ordering screen with that order loaded as the current order.
- [ ] All existing order modification capabilities work on the loaded order (add/remove line items, update customer name).
- [ ] Submitting the modified order updates it on the backend via existing WebSocket RPC actions and navigates to order-complete.
- [ ] Non-pending orders (completed, cancelled, submitted, etc.) cannot be edited.
- [ ] Pending order cards show a visual affordance indicating they are tappable (full opacity + edit hint).
- [ ] Tapping a pending order that is already the current order does NOT cancel it — just navigates.
- [ ] All new code has corresponding unit/widget tests.

## Success Metrics

- Baristas can resume any pending order from the Orders page without re-entering items.
- No orphaned pending orders accumulate — baristas can pick up where they left off.

## Dependencies & Risks

| Risk | Mitigation |
|------|------------|
| Same-order cancel bug | Identity guard in bloc handler (Phase 2) |
| Server accepts mutations on non-pending orders | Out of scope — document as follow-up issue |
| Multiple POS terminals editing same pending order | Accept as known limitation — first to submit wins |

## Follow-up Issues (out of scope)

- Add server-side status guards to `addItemToOrder` and `updateItemQuantity` (only allow when `status == 'pending'`).
- Filter empty cancelled orders from history table (pre-existing cosmetic issue, separate PR).
- Add `createdAt` timestamp to orders so pending cards can show elapsed time.
- Consider locking/claiming mechanism for pending orders across multiple POS terminals.

## References

- Brainstorm: `docs/ideate/2026-03-10-edit-pending-orders-brainstorm-doc.md`
- OrderRepository: `shared/order_repository/lib/src/order_repository.dart`
- OrderHistoryBloc: `applications/pos_app/lib/order_history/bloc/order_history_bloc.dart`
- OrderHistoryView: `applications/pos_app/lib/order_history/view/order_history_view.dart`
- OrderTicketBloc: `applications/pos_app/lib/order_ticket/bloc/order_ticket_bloc.dart`
- OrderTicket widget: `applications/pos_app/lib/order_ticket/view/widgets/order_ticket.dart`
- Server state: `api/lib/src/server_state.dart`
- Existing tests that need updating:
  - `applications/pos_app/test/order_history/view/order_history_view_test.dart` (Opacity 0.6 test)
