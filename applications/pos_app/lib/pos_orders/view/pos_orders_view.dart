import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/pos_orders/bloc/pos_orders_bloc.dart';

class PosOrdersView extends StatelessWidget {
  const PosOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return BlocBuilder<PosOrdersBloc, PosOrdersState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(l10n.ordersTitle),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/pos-order'),
              ),
              pinned: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.ordersActiveTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
            if (state.activeOrders.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.ordersEmpty),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final order = state.activeOrders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(order.orderNumber),
                      subtitle: Text('${order.items.length} item(s)'),
                      trailing: Text(_statusLabel(l10n, order.status)),
                    ),
                  );
                }, childCount: state.activeOrders.length),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  l10n.ordersHistoryTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
            if (state.historyOrders.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.ordersEmpty),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final order = state.historyOrders[index];
                  return ListTile(
                    title: Text(order.orderNumber),
                    subtitle: Text(
                      '\$${(order.total / 100).toStringAsFixed(2)}',
                    ),
                    trailing: Text(_statusLabel(l10n, order.status)),
                  );
                }, childCount: state.historyOrders.length),
              ),
          ],
        );
      },
    );
  }

  String _statusLabel(AppLocalizations l10n, OrderStatus status) {
    switch (status) {
      case OrderStatus.submitted:
        return l10n.orderStatusSubmitted;
      case OrderStatus.inProgress:
        return l10n.orderStatusInProgress;
      case OrderStatus.ready:
        return l10n.orderStatusReady;
      case OrderStatus.completed:
        return l10n.orderStatusCompleted;
      case OrderStatus.cancelled:
        return l10n.orderStatusCancelled;
      case OrderStatus.pending:
        return status.name;
    }
  }
}
