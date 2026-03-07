import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_kiosk_app/order_complete/order_complete.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class OrderCompleteView extends StatelessWidget {
  const OrderCompleteView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocConsumer<OrderCompleteBloc, OrderCompleteState>(
        listener: (context, state) {
          if (state.status == OrderCompleteStatus.navigatingBack) {
            context.go('/home');
          }
        },
        builder: (context, state) {
          if (state.status == OrderCompleteStatus.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == OrderCompleteStatus.failure) {
            return Scaffold(
              backgroundColor: context.colors.background,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.errorSomethingWentWrong,
                      style: context.typography.body.copyWith(
                        color: context.colors.mutedForeground,
                      ),
                    ),
                    SizedBox(height: context.spacing.xl),
                    BaseButton(
                      label: context.l10n.kioskDone,
                      onPressed: () => context.read<OrderCompleteBloc>().add(
                        const OrderCompleteDoneRequested(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final order = state.order;
          if (order == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: context.colors.background,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SuccessHeroPanel(order: order),
                Expanded(child: _OrderStatusPanel(order: order)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SuccessHeroPanel extends StatelessWidget {
  const _SuccessHeroPanel({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final l10n = context.l10n;

    return SizedBox(
      width: 520,
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.primary),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colors.primaryForeground.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 64,
                color: colors.primaryForeground,
              ),
            ),
            SizedBox(height: spacing.xxl),
            Text(
              l10n.kioskOrderPlacedTitle,
              style: typography.headline.copyWith(
                fontSize: 32,
                color: colors.primaryForeground,
              ),
            ),
            SizedBox(height: spacing.md),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.huge),
              child: Text(
                l10n.kioskOrderPlacedSubtitle,
                textAlign: TextAlign.center,
                style: typography.body.copyWith(
                  color: colors.primaryForeground.withValues(alpha: 0.7),
                ),
              ),
            ),
            SizedBox(height: spacing.huge),
            GestureDetector(
              onTap: () => context.read<OrderCompleteBloc>().add(
                const OrderCompleteDoneRequested(),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.xxl,
                  vertical: spacing.lg,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryForeground.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(radius.pill),
                ),
                child: Text(
                  l10n.kioskDone,
                  style: typography.subtitle.copyWith(
                    color: colors.primaryForeground,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderStatusPanel extends StatelessWidget {
  const _OrderStatusPanel({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;
    final isCancelled = order.status == OrderStatus.cancelled;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusTrackerCard(order: order),
          if (isCancelled) ...[
            SizedBox(height: spacing.md),
            Text(
              l10n.orderCompleteCancelledLabel,
              textAlign: TextAlign.center,
              style: typography.body.copyWith(color: colors.destructive),
            ),
          ],
          SizedBox(height: spacing.xxl),
          _OrderNumberCard(order: order),
          SizedBox(height: spacing.xl),
          _OrderItemsCard(order: order),
        ],
      ),
    );
  }
}

class _StatusTrackerCard extends StatelessWidget {
  const _StatusTrackerCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(context.radius.large),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: OrderStepTracker(
          activeStep: switch (order.status) {
            OrderStatus.pending || OrderStatus.submitted => 0,
            OrderStatus.inProgress => 1,
            OrderStatus.ready => 2,
            OrderStatus.completed => 3,
            OrderStatus.cancelled => -1,
          },
          labels: [
            l10n.orderCompleteStep1,
            l10n.orderCompleteStep2,
            l10n.orderCompleteStep3,
            l10n.orderCompleteStep4,
          ],
        ),
      ),
    );
  }
}

class _OrderNumberCard extends StatelessWidget {
  const _OrderNumberCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(context.radius.large),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.orderCompleteOrderNumber(order.orderNumber),
              style: typography.headline.copyWith(color: colors.foreground),
            ),
            Text(
              '\$${(order.grandTotal / 100).toStringAsFixed(2)}',
              style: typography.headline.copyWith(color: colors.foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(context.radius.large),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.orderCompleteOrderDetailsLabel,
              style: typography.subtitle.copyWith(color: colors.foreground),
            ),
            SizedBox(height: spacing.md),
            ...order.items.map((item) {
              final lineTotal =
                  (item.unitPriceWithModifiers * item.quantity / 100)
                      .toStringAsFixed(2);
              return Padding(
                padding: EdgeInsets.only(bottom: spacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}× ${item.name}',
                        style: typography.body.copyWith(
                          color: colors.foreground,
                        ),
                      ),
                    ),
                    Text(
                      '\$$lineTotal',
                      style: typography.body.copyWith(
                        color: colors.foreground,
                      ),
                    ),
                  ],
                ),
              );
            }),
            Divider(color: colors.border),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.cartTotalLabel,
                  style: typography.subtitle.copyWith(
                    color: colors.foreground,
                  ),
                ),
                Text(
                  '\$${(order.grandTotal / 100).toStringAsFixed(2)}',
                  style: typography.subtitle.copyWith(
                    color: colors.foreground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
