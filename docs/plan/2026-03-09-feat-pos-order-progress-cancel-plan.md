---
title: "feat: progress and cancel submitted orders from POS app"
type: feat
date: 2026-03-09
issue: https://github.com/VGVentures/very-yummy-coffee/issues/43
brainstorm: docs/ideate/2026-03-09-pos-order-progress-cancel-brainstorm-doc.md
---

## feat: progress and cancel submitted orders from POS app

## Overview

Add order progression and cancellation actions to the POS app's order history screen. Baristas will be able to move orders through the lifecycle (submitted -> in-progress -> ready -> completed) and cancel submitted/in-progress orders, directly from inline buttons on the active order cards. All actions use existing WebSocket RPC methods — no backend or shared package changes needed.

## Problem Statement / Motivation

The POS order history screen is currently read-only. Baristas must switch to the KDS app to progress or cancel orders. This adds friction during busy periods. Since the POS already displays active orders with full context (order number, customer name, items, total, status), adding action buttons is a natural extension.

## Proposed Solution

### Phase 1: Bloc events (order_history_bloc)

Add four new events to `OrderHistoryBloc`, mirroring the KDS pattern:

**File:** `applications/pos_app/lib/order_history/bloc/order_history_event.dart`

```dart
class OrderHistoryOrderStarted extends OrderHistoryEvent {
  const OrderHistoryOrderStarted(this.orderId);
  final String orderId;
  // manual == / hashCode (same pattern as KdsOrderStarted)
}

class OrderHistoryOrderMarkedReady extends OrderHistoryEvent { ... }
class OrderHistoryOrderCompleted extends OrderHistoryEvent { ... }
class OrderHistoryOrderCancelled extends OrderHistoryEvent { ... }
```

**File:** `applications/pos_app/lib/order_history/bloc/order_history_bloc.dart`

Register four handlers that delegate to `OrderRepository`:

```dart
on<OrderHistoryOrderStarted>((event, _) => _orderRepository.startOrder(event.orderId));
on<OrderHistoryOrderMarkedReady>((event, _) => _orderRepository.markOrderReady(event.orderId));
on<OrderHistoryOrderCompleted>((event, _) => _orderRepository.markOrderCompleted(event.orderId));
on<OrderHistoryOrderCancelled>((event, _) => _orderRepository.cancelOrder(event.orderId));
```

No state changes in the handlers — the server broadcasts the updated order via WS, which the existing `_onSubscriptionRequested` handler already processes.

### Phase 2: l10n strings

**File:** `applications/pos_app/lib/l10n/arb/app_en.arb`

Add these keys (mirror KDS labels):

| Key | Value | Purpose |
|-----|-------|---------|
| `actionStart` | `"Start"` | Progress button for submitted orders |
| `actionMarkReady` | `"Mark Ready"` | Progress button for in-progress orders |
| `actionComplete` | `"Complete"` | Progress button for ready orders |
| `actionCancel` | `"Cancel"` | Cancel text button |
| `cancelOrderDialogTitle` | `"Cancel Order?"` | AlertDialog title |
| `cancelOrderDialogMessage` | `"Are you sure you want to cancel order {orderNumber}? This cannot be undone."` | AlertDialog body (parameterized) |
| `cancelOrderDialogConfirm` | `"Yes, Cancel"` | Destructive confirm button |
| `cancelOrderDialogDismiss` | `"No"` | Dismiss button |

Run `flutter gen-l10n` after adding.

### Phase 3: Update `_ActiveOrderCard` UI

**File:** `applications/pos_app/lib/order_history/view/order_history_view.dart`

Add two optional callbacks to `_ActiveOrderCard`:

```dart
class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({
    required this.order,
    this.onProgressTapped,
    this.onCancelTapped,
  });

  final Order order;
  final VoidCallback? onProgressTapped;
  final VoidCallback? onCancelTapped;
  // ...
}
```

Add a new row at the bottom of the card's `Column` (below the total/status row), matching the KDS card pattern:

```dart
if (onProgressTapped != null) ...[
  SizedBox(height: spacing.md),
  Row(
    children: [
      if (onCancelTapped != null)
        TextButton(
          onPressed: onCancelTapped,
          style: TextButton.styleFrom(foregroundColor: colors.mutedForeground),
          child: Text(l10n.actionCancel),
        ),
      const Spacer(),
      FilledButton(
        onPressed: onProgressTapped,
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.primaryForeground,
        ),
        child: Text(_progressLabel(order.status, l10n)),
      ),
    ],
  ),
],
```

Helper to map status to button label:

```dart
String _progressLabel(OrderStatus status, AppLocalizations l10n) => switch (status) {
  OrderStatus.submitted => l10n.actionStart,
  OrderStatus.inProgress => l10n.actionMarkReady,
  OrderStatus.ready => l10n.actionComplete,
  _ => '',
};
```

### Phase 4: Wire callbacks in `_OrdersBody`

In the Active orders section of `_OrdersBody`, pass callbacks to `_ActiveOrderCard`:

```dart
_ActiveOrderCard(
  order: state.activeOrders[i],
  onProgressTapped: () => _dispatchProgress(context, state.activeOrders[i]),
  onCancelTapped: state.activeOrders[i].status == OrderStatus.submitted ||
                  state.activeOrders[i].status == OrderStatus.inProgress
      ? () => _showCancelDialog(context, state.activeOrders[i])
      : null,
),
```

`_dispatchProgress` maps status to the correct bloc event:

```dart
void _dispatchProgress(BuildContext context, Order order) {
  final bloc = context.read<OrderHistoryBloc>();
  switch (order.status) {
    case OrderStatus.submitted:
      bloc.add(OrderHistoryOrderStarted(order.id));
    case OrderStatus.inProgress:
      bloc.add(OrderHistoryOrderMarkedReady(order.id));
    case OrderStatus.ready:
      bloc.add(OrderHistoryOrderCompleted(order.id));
    default:
      break;
  }
}
```

### Phase 5: Cancel confirmation dialog

A standalone async function:

```dart
Future<void> _showCancelDialog(BuildContext context, Order order) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.cancelOrderDialogTitle),
      content: Text(l10n.cancelOrderDialogMessage(order.orderNumber)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancelOrderDialogDismiss),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: colors.statusDestructiveBackground,
            foregroundColor: colors.statusDestructiveForeground,
          ),
          child: Text(l10n.cancelOrderDialogConfirm),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    context.read<OrderHistoryBloc>().add(OrderHistoryOrderCancelled(order.id));
  }
}
```

### Phase 6: Tests

#### Bloc tests

**File:** `applications/pos_app/test/order_history/bloc/order_history_bloc_test.dart`

Add test groups for each new event:

- `OrderHistoryOrderStarted` calls `orderRepository.startOrder(orderId)`
- `OrderHistoryOrderMarkedReady` calls `orderRepository.markOrderReady(orderId)`
- `OrderHistoryOrderCompleted` calls `orderRepository.markOrderCompleted(orderId)`
- `OrderHistoryOrderCancelled` calls `orderRepository.cancelOrder(orderId)`

Use `mocktail` to verify repository calls. No state assertions needed (handlers don't emit).

#### Widget tests

**File:** `applications/pos_app/test/order_history/view/order_history_view_test.dart`

Test matrix:

| Test | Assertion |
|------|-----------|
| Submitted order card shows "Start" + "Cancel" buttons | `find.text('Start')`, `find.text('Cancel')` |
| In-progress order card shows "Mark Ready" + "Cancel" buttons | `find.text('Mark Ready')`, `find.text('Cancel')` |
| Ready order card shows "Complete" button, no "Cancel" | `find.text('Complete')`, `findsNothing` for Cancel |
| Pending order card shows no action buttons | `findsNothing` for all action buttons |
| Tap "Start" dispatches `OrderHistoryOrderStarted` | Verify bloc event |
| Tap "Cancel" opens confirmation dialog | `find.text('Cancel Order?')` |
| Confirm cancel dispatches `OrderHistoryOrderCancelled` | Verify bloc event after dialog tap |
| Dismiss cancel dialog does not dispatch event | Verify no bloc event |

### Phase 7: CI

Run `.github/update_github_actions.sh` if any `pubspec.yaml` changes are made (unlikely — no new deps expected).

## Technical Considerations

- **No loading states**: Actions are fire-and-forget over WS. The server broadcasts state changes back. Cards update reactively. This matches the KDS pattern.
- **Race conditions**: If the cancel dialog is open and another client changes the order status, the cancel may succeed or be silently rejected by the server. This is acceptable — the window is narrow and the KDS has the same behavior without any dialog at all.
- **Server allows cancel on ready orders**: The server's `cancelOrder` handler permits cancelling `ready` orders. The POS hides the cancel button for ready orders per spec. The KDS shows cancel on all active columns. This is an intentional divergence — not a bug to fix in this issue.
- **Card width**: 290px cards with 20px padding leave 250px usable. "Cancel" (~55px) + "Mark Ready" (~90px) + spacer fits comfortably.
- **No new shared package changes**: All repository methods already exist. No `very_yummy_coffee_ui` changes needed.

## Acceptance Criteria

- [ ] Baristas can progress orders: submitted -> in-progress -> ready -> completed from POS order history
- [ ] Baristas can cancel submitted/in-progress orders from POS order history
- [ ] Cancel shows AlertDialog confirmation before dispatching
- [ ] Progress/cancel actions not available on pending, completed, or cancelled orders
- [ ] Cancel button not shown on ready orders (only progress "Complete" button)
- [ ] Uses existing WS RPC actions (same as KDS)
- [ ] Order status updates in real-time across all connected clients
- [ ] Bloc tests verify each new event calls the correct repository method
- [ ] Widget tests verify correct buttons per status, dialog flow, and event dispatch

## Dependencies & Risks

- **No blockers**: All shared infrastructure exists. This is purely a POS app change.
- **Low risk**: Pattern is proven in the KDS app. The only new element is the cancel confirmation dialog.
- **No pubspec.yaml changes expected** — all dependencies already available.

## References & Research

- KDS bloc events: `applications/kds_app/lib/kds/bloc/kds_event.dart`
- KDS order card with action buttons: `applications/kds_app/lib/kds/view/widgets/kds_order_card.dart:110-133`
- KDS view wiring callbacks: `applications/kds_app/lib/kds/view/kds_view.dart`
- POS order history bloc (to extend): `applications/pos_app/lib/order_history/bloc/order_history_bloc.dart`
- POS active order card (to modify): `applications/pos_app/lib/order_history/view/order_history_view.dart:183-283`
- Order repository methods: `shared/order_repository/lib/src/order_repository.dart`
- Brainstorm: `docs/ideate/2026-03-09-pos-order-progress-cancel-brainstorm-doc.md`
- Issue: https://github.com/VGVentures/very-yummy-coffee/issues/43
