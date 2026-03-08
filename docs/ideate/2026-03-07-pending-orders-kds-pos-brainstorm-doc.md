---
date: 2026-03-07
topic: pending-orders-kds-pos
issue: https://github.com/VGVentures/very-yummy-coffee/issues/31
---

# Show Pending Orders on KDS and POS

## What We're Building

Display orders that are still being built by customers (`OrderStatus.pending`) on the KDS and POS apps, giving baristas visibility into incoming orders before they are submitted. Pending order cards are read-only (no actions) and visually dimmed to distinguish them from submitted/active orders.

The existing order lifecycle (`pending -> submitted -> inProgress -> ready -> completed`) is unchanged. No new server actions, WS topics, or repository methods are needed.

## Why This Approach

Three approaches were considered:

1. **Individual `order:<id>` subscriptions per pending order** — Real-time per-item updates but complex subscription management and many WS connections. Over-engineered for this use case.
2. **Extend existing `orders` topic filtering (chosen)** — The `orders` WS topic already broadcasts all orders including pending ones. KDS/POS blocs simply need to stop filtering them out and render a new UI section. Minimal changes, near-real-time updates (fires on every `addItemToOrder`, `updateNameOnOrder`, etc.).
3. **Separate `pending-orders` WS topic** — Clean separation but unnecessary since the data already flows through `orders`.

Approach 2 was chosen because it requires the fewest changes and leverages existing infrastructure.

## Key Decisions

- **Read-only**: Baristas cannot act on pending orders (no Start/Cancel buttons). Actions are only available once an order is submitted.
- **KDS: New 4th column (leftmost)**: A "PENDING" column is added to the left of the existing NEW / IN PROGRESS / READY columns. Pending orders flow left-to-right as they progress through the lifecycle.
- **KDS: Separate read-only column widget**: The existing `KdsColumn` requires `onAction`/`onCancel` callbacks. Rather than making those optional, build a simpler `KdsPendingColumn` that renders order cards without action buttons.
- **POS: Separate section above active orders**: A "Pending" row appears above the existing "Active Orders" horizontal scroll in the order history view.
- **Card content**: Pending cards show order number, items, customer name, and a "Pending" status chip. **No elapsed time** — `submittedAt` is null for pending orders and there is no `createdAt` field on the model. Adding a server-side `createdAt` was considered but rejected to keep this change UI-only.
- **Dimmed styling**: Wrap pending cards with reduced `Opacity` (e.g. 0.6) to visually distinguish them from active orders. Reuse `statusNeutralBackground/Foreground` tokens for the "Pending" status chip.
- **No server changes**: The `orders` topic already includes pending orders. Only UI-layer filtering changes are needed in KDS and POS blocs.
- **No new shared widgets**: The `KdsPendingColumn` is KDS-specific, not shared. POS pending cards reuse the existing `_ActiveOrderCard` structure with an opacity wrapper.

## Scope by Layer

| Layer | Changes |
|---|---|
| `api` (server) | None |
| `very_yummy_coffee_models` | None (`OrderStatus.pending` already exists) |
| `order_repository` | None (`startOrder` already exists) |
| KDS bloc | Add `pendingOrders` filtered list to state |
| KDS view | Add PENDING column (leftmost) using new `KdsPendingColumn` widget, render read-only dimmed cards |
| POS bloc | Add `pendingOrders` filtered list to state |
| POS view | Add "Pending" section above active orders, render read-only dimmed cards |
| `very_yummy_coffee_ui` | None (reuse existing tokens) |
| `CLAUDE.md` | No WS action changes needed |

## Open Questions

- Should there be a maximum number of pending orders shown (e.g., most recent 10) to avoid overwhelming the display when many customers are ordering simultaneously?
- Should pending orders that have been idle for a long time (e.g., abandoned carts) be hidden or visually deprioritized?
- Should we add a `createdAt` field to the server in a follow-up to enable elapsed time on pending cards?
