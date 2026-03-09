---
date: 2026-03-09
topic: order-status-board
---

# Live Order Status Board on Menu Board App

## What We're Building

A real-time order status panel on the menu board app that shows customers whether their order is being prepared or is ready for pickup. The panel replaces the right featured panel (320px) in the existing menu display layout, subscribing to the `orders` WebSocket topic and filtering to `inProgress` and `ready` statuses.

Customers can see their name (or order number if no name) without checking their phone or asking a barista. Orders update live via WebSocket with animated transitions.

## Why This Approach

### Layout: Replace right featured panel

Three approaches were considered:

1. **Replace right featured panel (chosen)** — Swaps the existing 320px right featured panel with the order status panel. Menu content (left featured panel + two menu columns) remains untouched and fully readable. Simple change to the existing `Row` layout.

2. **Dedicated right column** — Adds a new ~30% column, keeping both featured panels. This shrinks menu columns and adds visual density without clear benefit.

3. **Bottom ticker strip** — Keeps menu layout unchanged but limits order display to a single scrolling row with less detail per order. Harder to read from a distance.

The right-panel approach wins because it requires the smallest layout change, maintains readability of menu content, and provides enough vertical space to show both sections clearly.

### Widget placement: Shared UI package

The `OrderStatusCard` widget will live in `very_yummy_coffee_ui` rather than local to the menu board app. While only the menu board uses it today, order status display is a reusable concept that could appear in future apps (e.g., a customer-facing display). The card will accept primitive parameters (name string, status indicator) per the shared UI package constraint — no domain type dependencies.

### Empty state: Hide sections

When no orders exist in a given status, the section is simply not rendered rather than showing a placeholder message. This keeps the panel clean and avoids visual noise on a wall-mounted display where "All caught up!" would be meaningless to customers glancing at the board.

## Key Decisions

- **Layout**: Replace right featured panel (320px) with order status panel; left featured panel and two menu columns unchanged
- **OrderStatusCard**: Shared widget in `very_yummy_coffee_ui`, accepting primitive params (display name, status color tokens) — no domain dependencies
- **Bloc pattern**: New `OrderStatusBloc` in `lib/order_status/` following `KdsBloc`/`OrderHistoryBloc` pattern — `emit.forEach` on `ordersStream`, filter to `inProgress` + `ready`, sort by `submittedAt`
- **Empty state**: Hide sections when no orders match; no placeholder messages
- **Design tokens**: `statusWarningBackground/Foreground` for Preparing, `statusSuccessBackground/Foreground` for Ready
- **No backend changes**: Client-side filtering of existing `ordersStream`
- **Animations (v1)**: `AnimatedSwitcher` for appear/disappear only. No cross-section transitions — orders simply appear in their new section. Keeps scope manageable; can enhance later.
- **Overflow**: Cap visible count per section (oldest first). Show a "+X more" indicator when orders exceed the visible limit. No scrolling — wall-mounted display has no touch input.
- **Section headers**: "Preparing" and "Ready for Pickup" labels above each group. No panel-level title.

## Open Questions

- Exact cap per section (e.g., 4 preparing + 4 ready, or dynamic split based on available height?) — resolve during planning/implementation
