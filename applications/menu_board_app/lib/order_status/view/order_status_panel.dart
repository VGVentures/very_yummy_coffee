import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_menu_board_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_menu_board_app/order_status/order_status.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

const _maxVisiblePerSection = 5;

class OrderStatusPanel extends StatelessWidget {
  const OrderStatusPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderStatusBloc, OrderStatusState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.lg,
            vertical: context.spacing.xl,
          ),
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: BorderRadius.circular(context.radius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.inProgressOrders.isNotEmpty)
                _OrderSection(
                  title: context.l10n.orderStatusPreparing,
                  titleColor: context.colors.statusWarningForeground,
                  orders: state.inProgressOrders,
                  statusLabel: context.l10n.orderStatusPreparing,
                  statusBackgroundColor: context.colors.statusWarningBackground,
                  statusForegroundColor: context.colors.statusWarningForeground,
                ),
              if (state.inProgressOrders.isNotEmpty &&
                  state.readyOrders.isNotEmpty)
                SizedBox(height: context.spacing.xl),
              if (state.readyOrders.isNotEmpty)
                _OrderSection(
                  title: context.l10n.orderStatusReady,
                  titleColor: context.colors.statusSuccessForeground,
                  orders: state.readyOrders,
                  statusLabel: context.l10n.orderStatusReady,
                  statusBackgroundColor: context.colors.statusSuccessBackground,
                  statusForegroundColor: context.colors.statusSuccessForeground,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _OrderSection extends StatelessWidget {
  const _OrderSection({
    required this.title,
    required this.titleColor,
    required this.orders,
    required this.statusLabel,
    required this.statusBackgroundColor,
    required this.statusForegroundColor,
  });

  final String title;
  final Color titleColor;
  final List<Order> orders;
  final String statusLabel;
  final Color statusBackgroundColor;
  final Color statusForegroundColor;

  @override
  Widget build(BuildContext context) {
    final visible = orders.take(_maxVisiblePerSection).toList();
    final overflowCount = orders.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: context.typography.subtitle.copyWith(color: titleColor),
        ),
        SizedBox(height: context.spacing.sm),
        for (final order in visible) ...[
          OrderStatusCard(
            displayName: order.customerName ?? order.orderNumber,
            statusLabel: statusLabel,
            statusBackgroundColor: statusBackgroundColor,
            statusForegroundColor: statusForegroundColor,
          ),
          SizedBox(height: context.spacing.xs),
        ],
        if (overflowCount > 0)
          Padding(
            padding: EdgeInsets.only(top: context.spacing.xs),
            child: Text(
              context.l10n.orderStatusMoreCount(overflowCount),
              style: context.typography.muted,
            ),
          ),
      ],
    );
  }
}
