import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/pos_order_complete/bloc/pos_order_complete_bloc.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class PosOrderCompleteView extends StatelessWidget {
  const PosOrderCompleteView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<PosOrderCompleteBloc, PosOrderCompleteState>(
      builder: (context, state) {
        if (state.status == PosOrderCompleteStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == PosOrderCompleteStatus.failure) {
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
    const panelColor = Color(0xFF2D1B14);

    return ColoredBox(
      color: panelColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.orderCompleteTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                order.orderNumber,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.orderCompleteDetails,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              BaseButton(
                label: l10n.orderCompleteNewOrder,
                onPressed: () => context.read<PosOrderCompleteBloc>().add(
                  const PosOrderCompleteNewOrderRequested(),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: order.items.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final item = order.items[index];
              final total = item.price * item.quantity;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReceiptLine(
                label: l10n.orderTicketSubtotal,
                amount: order.total,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              _ReceiptLine(
                label: l10n.orderTicketTax,
                amount: order.tax,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
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
