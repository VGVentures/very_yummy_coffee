import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/order_complete/bloc/order_complete_bloc.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class OrderCompleteView extends StatelessWidget {
  const OrderCompleteView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<OrderCompleteBloc, OrderCompleteState>(
      builder: (context, state) {
        if (state.status == OrderCompleteStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == OrderCompleteStatus.failure) {
          return Center(child: Text(l10n.menuError));
        }
        final order = state.order;
        if (order == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _SuccessPanel(order: order, l10n: l10n),
            ),
            const VerticalDivider(width: 1),
            SizedBox(
              width: 320,
              child: _ReceiptPanel(order: order, l10n: l10n),
            ),
          ],
        );
      },
    );
  }
}

class _SuccessPanel extends StatelessWidget {
  const _SuccessPanel({required this.order, required this.l10n});

  final Order order;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final spacing = context.spacing;

    return ColoredBox(
      color: colors.topBarBackground,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.connected,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: colors.primaryForeground,
                  size: 44,
                ),
              ),
              SizedBox(height: spacing.xxl),
              Text(
                l10n.orderCompleteTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.primaryForeground,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.sm),
              Text(
                order.orderNumber,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.primaryForeground.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: spacing.md),
              Text(
                l10n.orderCompleteDetails,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.primaryForeground.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.huge),
              BaseButton(
                label: l10n.orderCompleteNewOrder,
                onPressed: () => context.read<OrderCompleteBloc>().add(
                  const OrderCompleteNewOrderRequested(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptPanel extends StatelessWidget {
  const _ReceiptPanel({required this.order, required this.l10n});

  final Order order;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: spacing.lg,
            top: spacing.lg,
            right: spacing.lg,
            bottom: spacing.md,
          ),
          child: Row(
            children: [
              Text(
                l10n.orderCompleteReceipt,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                order.orderNumber,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: spacing.sm),
            itemCount: order.items.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final item = order.items[index];
              final total = item.price * item.quantity;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.lg,
                  vertical: spacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}× ${item.name}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '\$${(total / 100).toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: EdgeInsets.only(
            left: spacing.lg,
            top: spacing.md,
            right: spacing.lg,
            bottom: spacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReceiptLine(
                label: l10n.orderTicketSubtotal,
                amount: order.total,
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: spacing.xs),
              _ReceiptLine(
                label: l10n.orderTicketTax,
                amount: order.tax,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: spacing.sm),
                child: const Divider(height: 1),
              ),
              _ReceiptLine(
                label: l10n.orderTicketTotal,
                amount: order.grandTotal,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({
    required this.label,
    required this.amount,
    this.style,
  });

  final String label;
  final int amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('\$${(amount / 100).toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
