import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/order_history/bloc/order_history_bloc.dart';
import 'package:very_yummy_coffee_pos_app/ordering/ordering.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

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
                        Opacity(
                          opacity: 0.6,
                          child: _ActiveOrderCard(
                            order: state.pendingOrders[i],
                          ),
                        ),
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
                Text(
                  l10n.ordersEmpty,
                  style: TextStyle(color: colors.mutedForeground),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < state.activeOrders.length; i++) ...[
                        if (i > 0) SizedBox(width: spacing.lg),
                        _ActiveOrderCard(order: state.activeOrders[i]),
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: spacing.xs),
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

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final submittedAt = order.submittedAt;
    final elapsed = submittedAt != null
        ? _formatElapsed(DateTime.now().difference(submittedAt))
        : '';
    final itemSummary = _buildItemSummary(order.items);

    return Container(
      width: 290,
      padding: EdgeInsets.all(spacing.xl),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(radius.small),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber,
                style: typography.pageTitle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              if (elapsed.isNotEmpty)
                Text(
                  elapsed,
                  style: typography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.mutedForeground,
                  ),
                ),
            ],
          ),
          if (order.customerName case final name? when name.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: spacing.xs),
              child: Text(
                name,
                style: typography.body.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ),
          SizedBox(height: spacing.md),
          Text(
            itemSummary,
            style: typography.caption.copyWith(color: colors.mutedForeground),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${(order.total / 100).toStringAsFixed(2)}',
                style: typography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              _StatusChip(status: order.status, l10n: l10n),
            ],
          ),
        ],
      ),
    );
  }

  String _buildItemSummary(List<LineItem> items) {
    if (items.isEmpty) return '';
    const maxVisible = 2;
    final names = items.take(maxVisible).map((i) => i.name).toList();
    final extra = items.length - maxVisible;
    final base = names.join(', ');
    return extra > 0 ? '$base, +$extra' : base;
  }

  String _formatElapsed(Duration d) {
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes >= 1) return '${d.inMinutes} min';
    return '<1 min';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l10n});

  final OrderStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final (bg, fg) = _chipColors(colors);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.card),
      ),
      child: Text(
        _label(),
        style: typography.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  (Color, Color) _chipColors(AppColors colors) => switch (status) {
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

  String _label() => switch (status) {
    OrderStatus.submitted => l10n.orderStatusSubmitted,
    OrderStatus.inProgress => l10n.orderStatusInProgress,
    OrderStatus.ready => l10n.orderStatusReady,
    OrderStatus.completed => l10n.orderStatusCompleted,
    OrderStatus.cancelled => l10n.orderStatusCancelled,
    OrderStatus.pending => l10n.orderStatusPending,
  };
}

class _HistoryTable extends StatelessWidget {
  const _HistoryTable({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final radius = context.radius;

    if (orders.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: Text(
          l10n.ordersEmpty,
          style: TextStyle(color: colors.mutedForeground),
        ),
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
      height: 44,
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
    final itemNames = order.items.map((i) => i.name).join(', ');
    final submittedAt = order.submittedAt;
    final timeStr = submittedAt != null
        ? DateFormat('h:mm a').format(submittedAt)
        : '—';

    return Container(
      height: 52,
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
            child: _StatusChip(status: order.status, l10n: l10n),
          ),
        ],
      ),
    );
  }
}
