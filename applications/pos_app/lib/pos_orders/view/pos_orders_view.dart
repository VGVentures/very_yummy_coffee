import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/pos_order/view/widgets/pos_top_bar.dart';
import 'package:very_yummy_coffee_pos_app/pos_orders/bloc/pos_orders_bloc.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class PosOrdersView extends StatelessWidget {
  const PosOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PosTopBar(),
        Expanded(
          child: BlocBuilder<PosOrdersBloc, PosOrdersState>(
            builder: (context, state) {
              if (state.status == PosOrdersStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == PosOrdersStatus.failure) {
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

  final PosOrdersState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
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
                    l10n.ordersActiveTitle,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colors.foreground,
                    ),
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
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.foreground,
                  ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontFamily: 'IBM Plex Sans',
          fontSize: 13,
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
    final spacing = context.spacing;

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
        borderRadius: BorderRadius.circular(12),
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
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              if (elapsed.isNotEmpty)
                Text(
                  elapsed,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.mutedForeground,
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text(
            itemSummary,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans',
              fontSize: 13,
              color: colors.mutedForeground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${(order.total / 100).toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans',
                  fontSize: 15,
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
    final (bg, fg) = _chipColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(),
        style: TextStyle(
          fontFamily: 'IBM Plex Sans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  (Color, Color) _chipColors() => switch (status) {
    OrderStatus.submitted || OrderStatus.inProgress => (
      const Color(0xFFFEF9C3),
      const Color(0xFF854D0E),
    ),
    OrderStatus.ready || OrderStatus.completed => (
      const Color(0xFFDCFCE7),
      const Color(0xFF166534),
    ),
    OrderStatus.cancelled => (
      const Color(0xFFFEE2E2),
      const Color(0xFF991B1B),
    ),
    OrderStatus.pending => (
      const Color(0xFFF1F5F9),
      const Color(0xFF475569),
    ),
  };

  String _label() => switch (status) {
    OrderStatus.submitted => l10n.orderStatusSubmitted,
    OrderStatus.inProgress => l10n.orderStatusInProgress,
    OrderStatus.ready => l10n.orderStatusReady,
    OrderStatus.completed => l10n.orderStatusCompleted,
    OrderStatus.cancelled => l10n.orderStatusCancelled,
    OrderStatus.pending => status.name,
  };
}

class _HistoryTable extends StatelessWidget {
  const _HistoryTable({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

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
        borderRadius: BorderRadius.circular(12),
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
    return Container(
      height: 44,
      color: colors.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: _HeaderCell(text: l10n.ordersColumnOrder),
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
    final colors = context.colors;
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: colors.mutedForeground,
      ),
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
    final itemNames = order.items.map((i) => i.name).join(', ');
    final submittedAt = order.submittedAt;
    final timeStr = submittedAt != null
        ? DateFormat('h:mm a').format(submittedAt)
        : '—';

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              order.orderNumber,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              itemNames,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans',
                fontSize: 14,
                color: colors.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              '\$${(order.total / 100).toStringAsFixed(2)}',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              timeStr,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans',
                fontSize: 14,
                color: colors.mutedForeground,
              ),
            ),
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
