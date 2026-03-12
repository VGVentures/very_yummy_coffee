import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/order_history/bloc/order_history_bloc.dart';
import 'package:very_yummy_coffee_pos_app/ordering/ordering.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// Maps [OrderStatus] to StatusBadge colors (backgroundColor, foregroundColor).
(Color, Color) _statusChipColors(AppColors colors, OrderStatus status) =>
    switch (status) {
      OrderStatus.submitted || OrderStatus.inProgress => (
        colors.statusWarningBackground,
        colors.statusWarningForeground,
      ),
      OrderStatus.ready || OrderStatus.completed => (
        colors.statusSuccessBackground,
        colors.statusSuccessForeground,
      ),
      OrderStatus.cancelled => (
        colors.statusDestructiveBackground,
        colors.statusDestructiveForeground,
      ),
      OrderStatus.pending => (
        colors.statusNeutralBackground,
        colors.statusNeutralForeground,
      ),
    };

String _statusLabel(OrderStatus status, AppLocalizations l10n) =>
    switch (status) {
      OrderStatus.submitted => l10n.orderStatusSubmitted,
      OrderStatus.inProgress => l10n.orderStatusInProgress,
      OrderStatus.ready => l10n.orderStatusReady,
      OrderStatus.completed => l10n.orderStatusCompleted,
      OrderStatus.cancelled => l10n.orderStatusCancelled,
      OrderStatus.pending => l10n.orderStatusPending,
    };

String _progressLabel(OrderStatus status, AppLocalizations l10n) =>
    switch (status) {
      OrderStatus.submitted => l10n.actionStart,
      OrderStatus.inProgress => l10n.actionMarkReady,
      OrderStatus.ready => l10n.actionComplete,
      _ => '',
    };

String _formatElapsed(Duration d) {
  if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  if (d.inMinutes >= 1) return '${d.inMinutes} min';
  return '<1 min';
}

List<String> _orderLineSummaries(List<LineItem> items) =>
    items.map((i) => '${i.quantity}× ${i.name}').toList();

const double _tableHeaderRowHeight = 44;
const double _tableDataRowHeight = 52;

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PosTopBar(showBackButton: true),
        Expanded(
          child: BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
            builder: (context, state) {
              if (state.status == OrderHistoryStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == OrderHistoryStatus.failure) {
                return Center(child: Text(context.l10n.menuError));
              }
              return _OrdersBody(state: state);
            },
          ),
        ),
      ],
    );
  }
}

class _OrdersBody extends StatelessWidget {
  const _OrdersBody({required this.state});

  final OrderHistoryState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.ordersPendingTitle,
                    style: typography.label.copyWith(color: colors.foreground),
                  ),
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
                        _PendingOrderCard(order: state.pendingOrders[i]),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: colors.border),
        Padding(
          padding: EdgeInsets.all(spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.ordersActiveTitle,
                    style: typography.label.copyWith(color: colors.foreground),
                  ),
                  if (state.activeOrders.isNotEmpty) ...[
                    SizedBox(width: spacing.md),
                    _CountBadge(count: state.activeOrders.length),
                  ],
                ],
              ),
              SizedBox(height: spacing.lg),
              if (state.activeOrders.isEmpty)
                Text(l10n.ordersEmpty, style: typography.muted)
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < state.activeOrders.length; i++) ...[
                        if (i > 0) SizedBox(width: spacing.lg),
                        _ActiveOrderCard(
                          order: state.activeOrders[i],
                          onProgressTapped: () => _dispatchProgress(
                            context,
                            state.activeOrders[i],
                          ),
                          onCancelTapped:
                              state.activeOrders[i].status ==
                                      OrderStatus.submitted ||
                                  state.activeOrders[i].status ==
                                      OrderStatus.inProgress
                              ? () => _showCancelDialog(
                                  context,
                                  state.activeOrders[i],
                                )
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: colors.border),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(spacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ordersHistoryTitle,
                  style: typography.label.copyWith(color: colors.foreground),
                ),
                SizedBox(height: spacing.lg),
                Expanded(
                  child: _HistoryTable(orders: state.historyOrders),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _dispatchProgress(BuildContext context, Order order) {
    final bloc = context.read<OrderHistoryBloc>();
    switch (order.status) {
      case OrderStatus.submitted:
        bloc.add(OrderHistoryOrderStarted(order.id));
      case OrderStatus.inProgress:
        bloc.add(OrderHistoryOrderMarkedReady(order.id));
      case OrderStatus.ready:
        bloc.add(OrderHistoryOrderCompleted(order.id));
      case OrderStatus.pending:
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        break;
    }
  }

  Future<void> _showCancelDialog(BuildContext context, Order order) async {
    final l10n = context.l10n;
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cancelOrderDialogTitle),
        content: Text(
          l10n.cancelOrderDialogMessage(order.orderNumber),
        ),
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
      context.read<OrderHistoryBloc>().add(
        OrderHistoryOrderCancelled(order.id),
      );
    }
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(radius.card),
      ),
      child: Text(
        '$count',
        style: typography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.primaryForeground,
        ),
      ),
    );
  }
}

class _PendingOrderCard extends StatelessWidget {
  const _PendingOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;
    final (statusBg, statusFg) = _statusChipColors(
      context.colors,
      order.status,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(context.radius.small),
      onTap: () {
        context.read<OrderHistoryBloc>().add(
          OrderHistoryPendingOrderResumeRequested(order.id),
        );
        context.go('/ordering');
      },
      child: Stack(
        children: [
          SizedBox(
            width: 290,
            child: OrderCard(
              orderNumber: order.orderNumber,
              customerName: order.customerName,
              lineSummaries: _orderLineSummaries(order.items),
              totalDisplayText: '\$${(order.total / 100).toStringAsFixed(2)}',
              statusLabel: _statusLabel(order.status, l10n),
              statusBackgroundColor: statusBg,
              statusForegroundColor: statusFg,
              elapsed: order.submittedAt != null
                  ? _formatElapsed(
                      DateTime.now().difference(order.submittedAt!),
                    )
                  : null,
            ),
          ),
          Positioned(
            right: spacing.sm,
            top: spacing.sm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: context.iconSize.medium,
                  color: colors.mutedForeground,
                ),
                SizedBox(width: spacing.xs),
                Text(
                  l10n.ordersPendingEditHint,
                  style: typography.caption.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({
    required this.order,
    this.onProgressTapped,
    this.onCancelTapped,
  });

  final Order order;
  final VoidCallback? onProgressTapped;
  final VoidCallback? onCancelTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;
    final (statusBg, statusFg) = _statusChipColors(
      context.colors,
      order.status,
    );

    Widget? trailing;
    if (onProgressTapped != null) {
      trailing = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onCancelTapped != null)
            TextButton(
              onPressed: onCancelTapped,
              style: TextButton.styleFrom(
                foregroundColor: colors.mutedForeground,
                padding: EdgeInsets.symmetric(horizontal: spacing.xs),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.actionCancel),
            )
          else
            const SizedBox.shrink(),
          Flexible(
            child: FilledButton(
              onPressed: onProgressTapped,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.primaryForeground,
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.sm,
                ),
              ),
              child: Text(
                _progressLabel(order.status, l10n),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: 290,
      child: OrderCard(
        orderNumber: order.orderNumber,
        customerName: order.customerName,
        lineSummaries: _orderLineSummaries(order.items),
        totalDisplayText: '\$${(order.total / 100).toStringAsFixed(2)}',
        statusLabel: _statusLabel(order.status, l10n),
        statusBackgroundColor: statusBg,
        statusForegroundColor: statusFg,
        elapsed: order.submittedAt != null
            ? _formatElapsed(
                DateTime.now().difference(order.submittedAt!),
              )
            : null,
        trailing: trailing,
      ),
    );
  }
}

class _HistoryTable extends StatelessWidget {
  const _HistoryTable({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;

    if (orders.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: Text(l10n.ordersEmpty, style: typography.muted),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(radius.small),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TableHeaderRow(l10n: l10n),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) =>
                  _TableDataRow(order: orders[index], l10n: l10n),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    return Container(
      height: _tableHeaderRowHeight,
      color: colors.secondary,
      padding: EdgeInsets.symmetric(horizontal: spacing.xl),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: _HeaderCell(text: l10n.ordersColumnOrder),
          ),
          SizedBox(
            width: 140,
            child: _HeaderCell(text: l10n.ordersColumnCustomer),
          ),
          Expanded(child: _HeaderCell(text: l10n.ordersColumnItems)),
          SizedBox(
            width: 110,
            child: _HeaderCell(text: l10n.orderTicketTotal),
          ),
          SizedBox(
            width: 140,
            child: _HeaderCell(text: l10n.ordersColumnCompleted),
          ),
          SizedBox(
            width: 120,
            child: _HeaderCell(text: l10n.orderStatus),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    return Text(
      text,
      style: typography.caption.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _TableDataRow extends StatelessWidget {
  const _TableDataRow({required this.order, required this.l10n});

  final Order order;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final (statusBg, statusFg) = _statusChipColors(colors, order.status);
    final itemNames = order.items.map((i) => i.name).join(', ');
    final submittedAt = order.submittedAt;
    final timeStr = submittedAt != null
        ? DateFormat('h:mm a').format(submittedAt)
        : '—';

    return Container(
      height: _tableDataRowHeight,
      padding: EdgeInsets.symmetric(horizontal: spacing.xl),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              order.orderNumber,
              style: typography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              order.customerName ?? '---',
              style: typography.muted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              itemNames,
              style: typography.muted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              '\$${(order.total / 100).toStringAsFixed(2)}',
              style: typography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(timeStr, style: typography.muted),
          ),
          SizedBox(
            width: 120,
            child: StatusBadge(
              label: _statusLabel(order.status, l10n),
              backgroundColor: statusBg,
              foregroundColor: statusFg,
            ),
          ),
        ],
      ),
    );
  }
}
