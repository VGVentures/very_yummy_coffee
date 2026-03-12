---
title: "feat: add shared order list and detail widgets"
type: feat
date: 2026-03-10
---

## feat: add shared order list and detail widgets

## Overview

Add three reusable widgets to `very_yummy_coffee_ui` for order display and migrate POS (order ticket + order history), menu board (order status panel), and KDS to use them. The UI package remains domain-agnostic: widgets accept only primitive parameters (strings, numbers, colors, callbacks); each app maps `Order` / `LineItem` / `OrderStatus` in the view layer.

**Brainstorm:** `docs/ideate/2026-03-10-shared-order-list-detail-widgets-brainstorm-doc.md`

## Background and motivation

Order-related UI is duplicated across POS (order history cards and table, order ticket line items, status chip), menu board (order status cards), and KDS (order cards with line items). Unifying presentational building blocks reduces duplication and keeps the design system the single source for order display. The chosen approach (primitives only, no shared mapping package) keeps the change minimal and aligns with the existing constraint that `very_yummy_coffee_ui` must not depend on `order_repository` or domain packages.

## Success criteria

- [ ] Three shared widgets exist in `very_yummy_coffee_ui`: **OrderCard**, **OrderLineItemRow**, **StatusBadge** (see naming in Phase 1).
- [ ] Each widget accepts only primitive parameters; no `Order`, `LineItem`, `OrderStatus`, or `very_yummy_coffee_models` in the UI package.
- [ ] POS order history (pending/active cards and table), POS order ticket (line items), and KDS order cards are refactored to use the new widgets with app-level mapping.
- [ ] Menu board continues to use `OrderStatusCard` as-is; no required change unless we add line summaries later.
- [ ] Existing behavior and layouts are preserved; tests pass and manual flows (resume pending, progress/cancel, ticket remove, KDS actions) work unchanged.
- [ ] All existing tests pass; manual flows verified.

## Technical considerations

### Shared UI constraint

`very_yummy_coffee_ui` must **not** depend on `order_repository`, `menu_repository`, `api_client`, or `very_yummy_coffee_models`. All three widgets take only primitives (e.g. `String`, `int`, `Color`, `VoidCallback?`). Apps perform mapping and l10n in the view layer.

### Design token usage

- Use `context.spacing`, `context.radius`, `context.typography`, `context.colors` for all layout and styling. No raw numeric literals for padding/radius; no `Color(0xFF...)` or `Colors.xxx`.
- **StatusBadge** must match **OrderStatusCard** pill styling: `context.radius.pill`, same padding and typography as the status chip in `order_status_card.dart` (use `context.typography.caption` without `fontWeight.w600` unless POS is intentionally styled differently from menu board). So POS and menu board stay consistent.

### Key decisions (from brainstorm)

| Decision | Choice |
|----------|--------|
| Widget location | All three in `very_yummy_coffee_ui` |
| API shape | Primitives only; apps map domain → display params |
| StatusBadge | Generic: `label`, `backgroundColor`, `foregroundColor` |
| OrderCard | Single flexible widget with optional sections (elapsed, trailing, lineSummaries) |
| OrderStatusCard | Stays as-is; no replacement in this feature |
| Mapping helpers | None (Approach A); add shared mapping later if duplication grows |

### Edge behavior (from flow analysis)

- **OrderCard:** When `lineSummaries` is empty, hide the line section (do not show empty text). When `customerName` is null or empty, omit the customer line. When `elapsed` is null or empty, omit the elapsed section. Order number and customer name: `maxLines: 1`, `overflow: TextOverflow.ellipsis`. Total: use app-supplied `totalDisplayText` so the app owns locale/currency formatting (no formatting inside the widget).
- **OrderLineItemRow:** When `modifierLabels` is empty, do not show modifier chips. When `quantity == 1`, omit explicit “Qty: 1”; when `quantity > 1`, show “Qty: N” (or equivalent). When `onRemove` is null, do not show remove control. When `totalCents` is null, do not show price (supports KDS read-only lines). When out-of-stock: optional `outOfStockLabel` (or bool + app supplies label); use muted text and existing `OutOfStockBadge`-style treatment. Item name: ellipsis, `maxLines: 1` (or 2 if specified).
- **StatusBadge:** Empty `label` is allowed; render the pill with empty text. Document in the API that apps should pass non-empty labels for accessibility.
- **OrderCard actions:** Use a single `Widget? trailing` slot so POS and KDS can pass their own button rows (Cancel + Progress, or Cancel + primary) without the UI package depending on action semantics.
- **OrderCard width:** Parent-constrained (no fixed width in the shared widget). POS preserves width 290 for order cards in horizontal scroll; KDS uses column layout.

## Implementation plan

### Phase 1: Shared widgets in `very_yummy_coffee_ui`

- **Widget tests** in `very_yummy_coffee_ui` use `MaterialApp` + `CoffeeTheme.light` + `pumpWidget` (same as existing widgets). Use `pumpApp` only in app-level tests (POS, KDS, etc.).
- **Documentation:** Add `{@template}` docs for the new widgets to match existing widgets (e.g. `OrderStatusCard`, `OutOfStockBadge`).

#### 1.1 — StatusBadge

- [ ] **New file:** `shared/very_yummy_coffee_ui/lib/src/widgets/status_badge.dart`
- [ ] **API:** `label` (`String`), `backgroundColor` (`Color`), `foregroundColor` (`Color`). All required for simplicity; empty string allowed (render pill with empty text).
- [ ] **Styling:** Match `OrderStatusCard` inner chip: `BorderRadius.circular(context.radius.pill)`, padding `EdgeInsets.symmetric(horizontal: context.spacing.sm, vertical: context.spacing.xs)`, `context.typography.caption` for label (no `fontWeight.w600` so it matches OrderStatusCard). No border; background and text color from params.
- [ ] Export from `shared/very_yummy_coffee_ui/lib/src/widgets/widgets.dart`.
- [ ] **Tests:** `shared/very_yummy_coffee_ui/test/src/widgets/status_badge_test.dart` — renders label, applies background/foreground colors, uses design tokens; optional test for empty label.

**Naming:** Use **StatusBadge** in the public API (brainstorm preferred “StatusBadge” as more neutral than “StatusChip”).

#### 1.2 — OrderLineItemRow

- [ ] **New file:** `shared/very_yummy_coffee_ui/lib/src/widgets/order_line_item_row.dart`
- [ ] **API (primitives only):**
  - `itemName` (`String`)
  - `quantity` (`int`, must be ≥ 1 for display; 0/negative can be handled by app or hide row)
  - `modifierLabels` (`List<String>`, optional; default `const []` — hide modifier row when empty)
  - `totalCents` (`int?`, optional — null = do not show price)
  - `outOfStockLabel` (`String?`, optional — when non-null show muted name and badge with this label)
  - `onRemove` (`VoidCallback?`, optional — when null do not show remove control)
- [ ] **Layout:** Name (and optional modifier chips, optional out-of-stock badge, optional “Qty: N” when quantity > 1) on the left; price on the right when `totalCents != null`; remove icon when `onRemove != null`. Use `ModifierSummaryChips(labels: modifierLabels)` when non-empty; use `OutOfStockBadge(label: outOfStockLabel!)` when out-of-stock. Typography and spacing from theme.
- [ ] Export and add tests in `shared/very_yummy_coffee_ui/test/src/widgets/order_line_item_row_test.dart`: required fields, optional price/remove/out-of-stock, modifier list empty vs non-empty, quantity 1 vs > 1.

#### 1.3 — OrderCard

- [ ] **New file:** `shared/very_yummy_coffee_ui/lib/src/widgets/order_card.dart`
- [ ] **API (primitives only):**
  - `orderNumber` (`String`)
  - `customerName` (`String?` — null or empty = omit customer line)
  - `lineSummaries` (`List<String>` — e.g. `["2× Espresso", "1× Latte"]`; empty = hide line section)
  - `totalDisplayText` (`String` — app formats from totalCents so app owns locale/currency)
  - `statusLabel` (`String`)
  - `statusBackgroundColor` (`Color`)
  - `statusForegroundColor` (`Color`)
  - `elapsed` (`String?` — null or empty = omit elapsed)
  - `trailing` (`Widget?` — optional action row, e.g. Cancel + Progress buttons)
- [ ] **Layout:** Card container (same card/radius/border as current _ActiveOrderCard). Top row: order number (left), elapsed (right) if present. Optional customer name line. Optional line section (only when `lineSummaries.isNotEmpty`) with summaries in caption style, single line ellipsis. Row: total (left) using `totalDisplayText`, status pill (right) — use **StatusBadge** for the pill. Optional `trailing` below. Use design tokens throughout; width not fixed (parent constrains).
- [ ] Export and add tests: required content, optional customer/elapsed/trailing, empty lineSummaries (section hidden), long text overflow.

### Phase 2: POS migration

#### 2.1 — Order history: StatusBadge and OrderCard

- [ ] **Files:** `applications/pos_app/lib/order_history/view/order_history_view.dart`
- [ ] **Mapping:** Add app-level helpers or inline mapping: `Order` + `AppLocalizations` → `StatusBadge` params (status → l10n label, status → theme colors; reuse same logic as current `_StatusChip._chipColors` and `_label()`). `Order` → `OrderCard` params (orderNumber, customerName, lineSummaries from items e.g. `item.quantity× item.name`, totalDisplayText from order.total formatted with l10n/currency, status label/colors, elapsed from submittedAt, trailing = existing button row).
- [ ] Replace **\_StatusChip** with **StatusBadge** (mapping in view). Remove private class `_StatusChip`.
- [ ] Replace **\_ActiveOrderCard** (and **\_PendingOrderCard** wrapper if it only forwards to _ActiveOrderCard) with **OrderCard**: build params from `Order` + l10n in the view; pass `trailing` as the existing progress/cancel row. Preserve `width: 290` on the parent (e.g. `SizedBox` or container) for horizontal scroll.
- [ ] **Table:** Replace `_StatusChip` in `_TableDataRow` with **StatusBadge** (same mapping).
- [ ] Run existing tests: `applications/pos_app/test/order_history/view/order_history_view_test.dart`; fix any snapshot or structure expectations. Add or adjust tests so that StatusBadge and OrderCard are used with primitives (no dependency on order_repository in assertions that only check structure).

#### 2.2 — Order ticket: OrderLineItemRow

- [ ] **Files:** `applications/pos_app/lib/order_ticket/view/widgets/order_ticket.dart`, `order_ticket_line_item.dart`
- [ ] **Mapping:** In the view (or in a small mapper in the app layer), map each `LineItem` to OrderLineItemRow params: itemName, quantity, modifierLabels from lineItem.modifierOptionNames, totalCents = lineItem.unitPriceWithModifiers * lineItem.quantity, outOfStockLabel = context.l10n.cartItemUnavailable when isUnavailable else null, onRemove = callback that dispatches OrderTicketItemRemoved(lineItem.id).
- [ ] Replace **OrderTicketLineItem** usage in `OrderTicket` with **OrderLineItemRow** (from very_yummy_coffee_ui), passing mapped params. Keep Bloc dependency in the parent (onRemove callback).
- [ ] Remove or deprecate `order_ticket_line_item.dart` if it is no longer used; otherwise keep for any app-specific wrapper. Prefer deleting and using only OrderLineItemRow.
- [ ] Run `applications/pos_app/test/order_ticket/view/widgets/order_ticket_test.dart` and fix any breakage.

### Phase 3: KDS migration

- [ ] **Files:** `applications/kds_app/lib/kds/view/widgets/kds_order_card.dart`
- [ ] **Chosen approach:** Use **OrderCard** with `lineSummaries` only: build summaries from `order.items` (e.g. `order.items.map((i) => '${i.quantity}× ${i.name}')`). Pass orderNumber, customerName, totalDisplayText (app-formatted), no status on card (or add StatusBadge if product wants it), elapsed from KdsElapsedWidget, trailing = existing Cancel + primary action row. Keep current KDS card header/footer and existing elapsed + trailing. Do not add OrderLineItemRow per line in this feature unless needed.
- [ ] Implement; ensure accent color and actions still work. Run `applications/kds_app/test/kds/view/widgets/kds_order_card_test.dart`.

### Phase 4: Regressions and cleanup

- [ ] **Menu board:** No change (OrderStatusCard as-is). Optionally add a short note that future enhancement could use OrderCard with lineSummaries.
- [ ] Run full test suite (`dart test` or package tests) for `very_yummy_coffee_ui`, `pos_app`, `kds_app`, `menu_board_app`.
- [ ] Manually verify: POS order history (pending resume, active progress/cancel), order ticket (add/remove, charge → order complete), KDS column (Start/Ready/Complete, Cancel), menu board (Preparing/Ready).
- [ ] Run `.github/update_github_actions.sh` if any new dependency or package structure changed; commit workflow changes if needed.
- [ ] Update **CLAUDE.md** or docs if new widgets are the recommended building blocks for order UI.

## Dependencies and risks

| Dependency | Notes |
|------------|--------|
| Existing design tokens | AppColors (status*), spacing, radius, typography must support StatusBadge and OrderCard. Already present. |
| ModifierSummaryChips, OutOfStockBadge | OrderLineItemRow will use these; already in very_yummy_coffee_ui. |
| OrderStatusCard | Unchanged; StatusBadge should match its pill styling. |

| Risk | Mitigation |
|------|------------|
| POS/KDS behavior change | Use primitive APIs and same layout; keep Bloc events and navigation in app. |
| Snapshot tests | Update expectations for widget type (StatusBadge, OrderCard, OrderLineItemRow) and structure. |
| Receipt panel | POS order complete receipt (_ReceiptPanel) uses similar line-item layout; **out of scope** for this feature. Add follow-up task to migrate receipt to OrderLineItemRow (read-only, no remove) if desired. |

## Out of scope / follow-up

- **POS order complete receipt:** _ReceiptPanel line items are not migrated in this plan. A follow-up can switch them to OrderLineItemRow (read-only, no remove, no out-of-stock) for consistency.
- **Shared mapping package:** Approach A (no shared Order → display params helper). Revisit if mapping duplication grows.
- **Kiosk/mobile cart:** Not in scope; same line-item pattern could reuse OrderLineItemRow later.
