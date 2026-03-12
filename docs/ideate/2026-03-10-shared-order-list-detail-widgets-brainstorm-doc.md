---
date: 2026-03-10
topic: shared-order-list-detail-widgets
---

# Shared Order List / Detail Widgets (Todo #3)

## What We're Building

Add three reusable building blocks for order display and migrate POS, menu board, and KDS to use them:

1. **Order card** — A card that shows order identifier, customer name (optional), a list of line summaries (e.g. `List<String>` such as "2× Espresso", "1× Latte"), total, and a status indicator. Used in POS order ticket/history, menu board order status panel, and KDS columns.
2. **Line item row** — A row for a single order line: item name, quantity, modifier labels (optional), price, optional “out of stock” state, optional remove action. Used in POS order ticket and KDS order cards.
3. **Status badge** — A small chip showing a status label with background/foreground colors. Used wherever we show `OrderStatus` (POS history/ticket, KDS if we add per-card status). Today POS has a private `_StatusChip` that depends on `OrderStatus` and l10n; we want a primitive version in the UI package so all apps can use it.

**Success criterion (chosen):** Reduce duplication — the same three widget concepts implemented once in shared UI; POS, menu_board, and KDS refactor to use them. Layout or copy can still differ slightly per app (e.g. KDS keeps column layout and actions; POS keeps its ticket layout).

**Constraint:** `very_yummy_coffee_ui` must not depend on `order_repository` or any domain packages. All three widgets accept only primitive parameters (strings, numbers, colors, callbacks). Each app maps `Order` / `LineItem` / `OrderStatus` to these primitives in the view layer.

---

## Why This Approach

Two options were considered:

**Approach A: All three widgets in `very_yummy_coffee_ui`, primitives only** ← **Chosen**

- Add `OrderCard`, `OrderLineItemRow`, and `StatusBadge` (or `StatusChip`) to the existing UI package. Each takes only primitives (e.g. `OrderCard`: `orderNumber`, `customerName?`, `lineSummaries`, `totalCents`, `statusLabel`, `statusBackgroundColor`, `statusForegroundColor`, optional `elapsed`, optional trailing/actions). Apps keep mapping `Order`/`LineItem`/`OrderStatus` to these parameters in their view layer.
- **Pros:** No new package; UI package stays pure and consistent with `OrderStatusCard` and `CoffeeCard`; design system owns all presentational primitives; maximum duplication removed from widget implementations.
- **Cons:** Mapping from domain types to primitives is repeated in each app (simple one-liners or small helpers per screen).
- **Best when:** Goal is to remove duplicated *widget* code first; mapping duplication is acceptable and can be revisited later if it grows.

**Approach B: Same widgets + shared mapping helpers**

- Same three widgets in `very_yummy_coffee_ui`. In addition, add a shared helper (e.g. in a small shared package or alongside an existing one that already depends on `order_repository`) such as `orderToOrderCardParams(Order order, String Function(OrderStatus) statusLabel)` so apps don’t copy-paste mapping logic.
- **Pros:** Single place for “Order → display params” if we want consistency and less boilerplate.
- **Cons:** Extra package or dependency; mapping is simple enough that YAGNI may apply for now.
- **Best when:** We see repeated mapping code across many screens and want to centralize it.

We chose **A** to keep the change minimal and aligned with the report. Shared mapping (B) can be added later if mapping duplication becomes a problem.

---

## Key Decisions

- **Widgets live in `very_yummy_coffee_ui`:** Keeps the design system as the single source for order-related presentational building blocks and respects the existing “no repository dependency” rule.
- **Primitives only:** `OrderCard`, `OrderLineItemRow`, and `StatusBadge` take strings, ints, colors, and callbacks — no `Order`, `LineItem`, or `OrderStatus` in the UI package. Apps perform mapping (and l10n for status labels).
- **StatusBadge is generic:** Accepts `label`, `backgroundColor`, and `foregroundColor`. Apps map `OrderStatus` to l10n label and theme colors (e.g. statusWarningBackground/statusSuccessBackground), then pass them in. POS’s current `_StatusChip(OrderStatus, l10n)` is replaced by that mapping plus the shared widget.
- **OrderCard is one flexible widget:** One shared card that can be used in list (POS history, menu board) and detail-like (KDS card) contexts, parameterized by optional fields (elapsed, actions, etc.). It displays only summary data: orderNumber, customerName, `List<String> lineSummaries`, total, status. Apps that need per-line UI (e.g. POS ticket with remove, KDS with modifier chips) compose the card with a list of `OrderLineItemRow` in their own layout; the card does not embed line rows. We avoid multiple card variants unless we discover a clear need.
- **OrderStatusCard stays as-is:** Menu board already uses `OrderStatusCard` (displayName, statusLabel, colors). Reuse the same status-pill styling in `StatusBadge` for consistency; no need to replace `OrderStatusCard` unless we unify later.
- **Migrate POS, menu_board, KDS:** Refactor order_ticket/order_history (POS), order_status (menu_board), and KDS order views to use the new widgets plus app-level mapping. Layout and app-specific behavior (e.g. KDS column actions) stay in the app.

---

## Open Questions

- **Naming:** Prefer `StatusBadge` or `StatusChip` in the public API? (Chip is more Material; Badge is more neutral.)
- **OrderCard vs list vs detail:** Keep one widget with optional sections (elapsed, actions, lineSummaries); apps pass empty or conditional content. Revisit splitting into compact/expanded only if the single widget becomes unwieldy.
- **Line item row:** Should `OrderLineItemRow` live in the same file as order-related widgets or in a separate “list row” file? (Affects discoverability and future reuse for non-order lines.)
