---
title: "feat: show pending orders on KDS and POS"
type: feat
date: 2026-03-07
issue: https://github.com/VGVentures/very-yummy-coffee/issues/31
brainstorm: docs/ideate/2026-03-07-pending-orders-kds-pos-brainstorm-doc.md
---

## feat: show pending orders on KDS and POS

## Overview

Display orders with `OrderStatus.pending` (still being built by customers) on the KDS and POS apps. Pending cards are read-only (no barista actions), visually dimmed with `Opacity(0.6)`, and update in near-real-time as customers add items. When the customer submits, the order flows from the PENDING section into the existing NEW/Active section automatically via WebSocket.

No server, model, or repository changes are needed — the `orders` WS topic already broadcasts all orders including pending ones. This is purely a KDS and POS UI change.

## Problem Statement / Motivation

Baristas currently have no visibility into orders being built by customers. Orders only appear on KDS/POS after submission. Showing pending orders gives the kitchen a heads-up on incoming volume and lets baristas anticipate busy periods.

## Proposed Solution

Extend the existing KDS and POS blocs to stop filtering out `OrderStatus.pending` orders, and add new UI sections to display them.

### KDS Changes

1. **State**: Add `pendingOrders` field to `KdsState`
2. **Bloc**: Filter `OrderStatus.pending` orders in `_onSubscriptionRequested`
3. **Widgets**: Make `KdsColumn` and `KdsOrderCard` action callbacks optional. When null, hide the action row and elapsed time widget.
4. **View**: Add a PENDING column (leftmost, always visible) using `KdsColumn` with null callbacks
5. **Top bar**: Queue count excludes pending orders (unchanged)
6. **l10n**: Add `columnPending` key

### POS Changes

1. **State**: Add `pendingOrders` field to `OrderHistoryState`
2. **Bloc**: Filter `OrderStatus.pending` orders in `_onSubscriptionRequested`
3. **View**: Add "Pending" section above "In Progress" in `_OrdersBody`, always visible
4. **Cards**: Wrap existing `_ActiveOrderCard` in `Opacity(0.6)` for pending orders
5. **l10n**: Add `ordersPendingTitle` key

## Technical Considerations

### Widget Architecture

- **KDS**: Make `KdsColumn` and `KdsOrderCard` action callbacks (`onAction`, `onCancel`, `actionLabel`) optional (nullable). When null, the card hides the action row and the elapsed time widget. The PENDING column passes null for these callbacks and wraps each card in `Opacity(0.6)` inside the `itemBuilder`. This avoids creating two near-duplicate widget files (~120 LOC saved).
- **POS**: Reuse `_ActiveOrderCard` as-is, just wrap in `Opacity(0.6)`. The card already handles `submittedAt == null` gracefully (shows empty elapsed time).

### Sorting

Pending orders have no `submittedAt` timestamp. The current KDS bloc sorts by `submittedAt` (nulls last). Pending orders should be filtered *before* sorting into their own list, so the existing sort logic is unaffected. Within the pending list, server insertion order is used (effectively chronological for the in-memory server).

### Layout

The KDS goes from 3 to 4 equal `Expanded` columns (always visible). Each column drops from ~33% to ~25% width. On standard iPad landscape (1024pt) that is ~256pt per column — sufficient for card content, especially since pending cards have no action buttons.

### Dimming

Both KDS and POS wrap pending cards in `Opacity(0.6)`. This is a lightweight operation for the expected number of pending cards (typically < 10).

### Queue Count

The KDS top bar "in queue" count continues to sum `newOrders + inProgressOrders + readyOrders` only. Pending orders are excluded because they are not yet actionable.

### Known Limitation: Orphaned Pending Orders

If a customer disconnects without submitting or cancelling, their pending order remains on the server indefinitely (until server restart). These ghost orders will appear on KDS/POS. This is a pre-existing server behavior that becomes visible with this feature. Cleanup can be addressed in a follow-up (e.g., adding `createdAt` and a timeout).

## Acceptance Criteria

- [ ] `KdsState` has a `pendingOrders` field populated from `ordersStream`
- [ ] KDS view renders 4 columns: PENDING, NEW, IN PROGRESS, READY
- [ ] PENDING column is always visible (even when empty)
- [ ] PENDING column uses `statusNeutralForeground` as accent color
- [ ] KDS pending cards are wrapped in `Opacity(0.6)`
- [ ] KDS pending cards show order number, customer name, and line items — no action buttons, no elapsed time
- [ ] KDS "in queue" count excludes pending orders
- [ ] `OrderHistoryState` has a `pendingOrders` field populated from `ordersStream`
- [ ] POS order history renders a "Pending" section above "In Progress", always visible
- [ ] POS pending cards are wrapped in `Opacity(0.6)`
- [ ] Both apps update live via WebSocket when items are added to pending orders
- [ ] When a pending order is submitted, it moves from PENDING to NEW/Active in real time
- [ ] When a pending order is cancelled, it disappears from PENDING (KDS) or moves to history (POS)
- [ ] Existing order flow (submitted → inProgress → ready → completed) is unaffected
- [ ] KDS bloc test covers `pendingOrders` filtering
- [ ] KDS view test verifies 4 columns rendered and pending column label
- [ ] KDS `KdsOrderCard` widget test verifies no action buttons when callbacks are null
- [ ] POS bloc test covers `pendingOrders` filtering
- [ ] POS view test verifies pending section rendered with dimmed cards
- [ ] All existing tests remain green
- [ ] New l10n keys added to both apps

## Implementation Plan

### Phase 1: KDS Bloc + State

**Files to modify:**

- `applications/kds_app/lib/kds/bloc/kds_state.dart` — add `pendingOrders` field
- `applications/kds_app/lib/kds/bloc/kds_bloc.dart` — filter pending orders in `_onSubscriptionRequested`

```dart
// kds_state.dart — add field
final List<Order> pendingOrders; // defaults to const []

// kds_bloc.dart — add filter (before the submittedAt sort, since pending orders have no submittedAt)
pendingOrders: orders.orders
    .where((o) => o.status == OrderStatus.pending)
    .toList(),
```

**Tests:**

- `applications/kds_app/test/kds/bloc/kds_bloc_test.dart` — add test with pending order in stream, verify it appears in `pendingOrders` and not in other lists. Also add a multi-emission transition test: stream emits order as `pending`, then as `submitted` — verify it moves from `pendingOrders` to `newOrders`.

### Phase 2: KDS Widget Updates (Optional Callbacks)

**Files to modify:**

- `applications/kds_app/lib/kds/view/widgets/kds_column.dart` — make `actionLabel`, `onAction`, `onCancel` nullable. When `onAction` is null, skip rendering action buttons in each card. Add per-card `Opacity` wrapping when a new optional `cardOpacity` parameter is provided.
- `applications/kds_app/lib/kds/view/widgets/kds_order_card.dart` — make `actionLabel`, `onAction`, `onCancel` nullable. When null, hide the action row at the bottom. When `onAction` is null, also hide `KdsElapsedWidget` (pending orders have no `submittedAt`).

Existing callers (NEW, IN PROGRESS, READY columns) are unaffected — they already pass all callbacks.

**Tests:**

- `applications/kds_app/test/kds/view/widgets/kds_order_card_test.dart` — add test case: when `onAction`/`onCancel` are null, verify no action buttons rendered and no elapsed widget shown

### Phase 3: KDS View Integration

**Files to modify:**

- `applications/kds_app/lib/kds/view/kds_view.dart` — add PENDING column as first `Expanded` child in the `Row`

```dart
Row(
  children: [
    Expanded(
      child: KdsColumn(
        orders: state.pendingOrders,
        accentColor: colors.statusNeutralForeground,
        label: l10n.columnPending,
        cardOpacity: 0.6,
        // onAction, onCancel, actionLabel omitted (null) — read-only
      ),
    ),
    Expanded(child: KdsColumn(/* existing NEW */)),
    Expanded(child: KdsColumn(/* existing IN PROGRESS */)),
    Expanded(child: KdsColumn(/* existing READY */)),
  ],
)
```

**l10n:**

- `applications/kds_app/lib/l10n/arb/app_en.arb` — add `columnPending`: `"PENDING"`

**Tests:**

- `applications/kds_app/test/kds/view/kds_view_test.dart` — update test to expect 4 `KdsColumn` widgets (currently expects 3). Add test verifying PENDING column label is rendered.

### Phase 4: POS Bloc + State

**Files to modify:**

- `applications/pos_app/lib/order_history/bloc/order_history_state.dart` — add `pendingOrders` field
- `applications/pos_app/lib/order_history/bloc/order_history_bloc.dart` — filter pending orders in `_onSubscriptionRequested`

```dart
// order_history_state.dart — add field
final List<Order> pendingOrders; // defaults to const []

// order_history_bloc.dart — add filter
final pending = orders.orders
    .where((o) => o.status == OrderStatus.pending)
    .toList();
// ... in copyWith:
pendingOrders: pending,
```

**Tests:**

- `applications/pos_app/test/order_history/bloc/order_history_bloc_test.dart` — update existing test to verify `tPendingOrder` appears in `pendingOrders` (not in activeOrders or historyOrders). Note: the test already creates `tPendingOrder` but currently expects it to be excluded. Also add a multi-emission transition test: stream emits order as `pending`, then as `submitted` — verify it moves from `pendingOrders` to `activeOrders`.

**Codegen:** Run `dart run build_runner build` in `applications/pos_app/` after adding the `pendingOrders` field to regenerate the `.mapper.dart` file.

### Phase 5: POS View Integration

**Files to modify:**

- `applications/pos_app/lib/order_history/view/order_history_view.dart` — add "Pending" section in `_OrdersBody` above the existing "In Progress" section

```dart
// In _OrdersBody.build, before the existing "In Progress" section:
Padding(
  padding: EdgeInsets.all(spacing.xxl),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(l10n.ordersPendingTitle, style: typography.label.copyWith(color: colors.foreground)),
          if (state.pendingOrders.isNotEmpty) ...[
            SizedBox(width: spacing.md),
            _CountBadge(count: state.pendingOrders.length),
          ],
        ],
      ),
      SizedBox(height: spacing.lg),
      if (state.pendingOrders.isEmpty)
        Text(l10n.ordersEmpty, style: typography.muted)
      else
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < state.pendingOrders.length; i++) ...[
                if (i > 0) SizedBox(width: spacing.lg),
                Opacity(
                  opacity: 0.6,
                  child: _ActiveOrderCard(order: state.pendingOrders[i]),
                ),
              ],
            ],
          ),
        ),
    ],
  ),
),
Divider(height: 1, thickness: 1, color: colors.border),
```

**l10n:**

- `applications/pos_app/lib/l10n/arb/app_en.arb` — add `ordersPendingTitle`: `"Pending"`

**Tests:**

- `applications/pos_app/test/order_history/view/order_history_view_test.dart` — create test file verifying pending section renders with dimmed cards. Use `pumpApp` helper, `_MockOrderHistoryBloc`, and landscape viewport setup (matching the KDS view test pattern in `kds_view_test.dart`).

### Phase 6: Regenerate l10n + CI

- Run `flutter gen-l10n` in both `applications/kds_app/` and `applications/pos_app/`
- Run `.github/update_github_actions.sh` (only if pubspec.yaml changed — unlikely for this feature)
- Run `dart format .` and `dart fix --apply` across both apps

## Dependencies & Risks

| Risk | Mitigation |
|---|---|
| 4-column KDS layout too narrow on small tablets | Pending column has no action buttons so needs less width. Monitor during testing. |
| Orphaned pending orders accumulate | Known limitation; address in follow-up with `createdAt` + timeout |
| POS barista sees own pending order in Pending section | Acceptable — barista can recognize by order number |
| `dart_mappable` codegen for state changes | Run `dart run build_runner build` in both `kds_app/` and `pos_app/` after adding `pendingOrders` field |

## References & Research

- Brainstorm: `docs/ideate/2026-03-07-pending-orders-kds-pos-brainstorm-doc.md`
- KDS bloc: `applications/kds_app/lib/kds/bloc/kds_bloc.dart`
- KDS state: `applications/kds_app/lib/kds/bloc/kds_state.dart`
- KDS view: `applications/kds_app/lib/kds/view/kds_view.dart`
- KDS column widget: `applications/kds_app/lib/kds/view/widgets/kds_column.dart`
- KDS order card: `applications/kds_app/lib/kds/view/widgets/kds_order_card.dart`
- POS order history bloc: `applications/pos_app/lib/order_history/bloc/order_history_bloc.dart`
- POS order history state: `applications/pos_app/lib/order_history/bloc/order_history_state.dart`
- POS order history view: `applications/pos_app/lib/order_history/view/order_history_view.dart`
- Related issue: #31
