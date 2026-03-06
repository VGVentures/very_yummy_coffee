import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/checkout/checkout.dart';
import 'package:very_yummy_coffee_kiosk_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_kiosk_app/widgets/widgets.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        final orderId = state.order?.id;
        if (state.status == CheckoutStatus.success && orderId != null) {
          context.go('/home/menu/cart/checkout/confirmation/$orderId');
        }
      },
      builder: (context, state) {
        if (state.status == CheckoutStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == CheckoutStatus.failure && state.order == null) {
          return Scaffold(
            body: Center(
              child: Text(context.l10n.errorSomethingWentWrong),
            ),
          );
        }

        final order = state.order;
        final l10n = context.l10n;
        final itemCount =
            order?.items.fold<int>(0, (sum, i) => sum + i.quantity) ?? 0;
        final totalStr = order != null
            ? '\$${(order.grandTotal / 100).toStringAsFixed(2)}'
            : '';

        return Scaffold(
          backgroundColor: context.colors.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KioskHeader(
                showBackButton: true,
                onBack: () => context.go('/home/menu/cart'),
                title: l10n.checkoutTitle,
                subtitle: '$itemCount items · $totalStr',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.spacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _FakePaymentCard(),
                      SizedBox(height: context.spacing.xl),
                      if (order != null) _OrderSummaryCard(order: order),
                    ],
                  ),
                ),
              ),
              if (state.status == CheckoutStatus.failure && state.order != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.xl,
                    vertical: context.spacing.sm,
                  ),
                  child: Text(
                    l10n.checkoutErrorRetry,
                    textAlign: TextAlign.center,
                    style: context.typography.small.copyWith(
                      color: context.colors.destructive,
                    ),
                  ),
                ),
              if (order != null)
                _PlaceOrderBar(
                  order: order,
                  isSubmitting: state.status == CheckoutStatus.submitting,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FakePaymentCard extends StatelessWidget {
  const _FakePaymentCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(context.radius.large),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: colors.primary,
              size: context.iconSize.medium,
            ),
            SizedBox(width: spacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.checkoutFakePaymentLabel,
                  style: typography.subtitle.copyWith(color: colors.foreground),
                ),
                Text(
                  context.l10n.checkoutFakePaymentSubtitle,
                  style: typography.small.copyWith(
                    color: colors.mutedForeground,
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

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

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
              l10n.cartOrderSummaryLabel,
              style: typography.subtitle.copyWith(color: colors.foreground),
            ),
            SizedBox(height: spacing.md),
            SummaryRow(
              label: l10n.cartSubtotalLabel,
              amount: order.total,
              style: typography.body.copyWith(color: colors.mutedForeground),
            ),
            SizedBox(height: spacing.sm),
            SummaryRow(
              label: l10n.cartTaxLabel,
              amount: order.tax,
              style: typography.body.copyWith(color: colors.mutedForeground),
            ),
            SizedBox(height: spacing.md),
            Divider(color: colors.border),
            SizedBox(height: spacing.md),
            SummaryRow(
              label: l10n.cartTotalLabel,
              amount: order.grandTotal,
              style: typography.headline.copyWith(color: colors.foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceOrderBar extends StatelessWidget {
  const _PlaceOrderBar({
    required this.order,
    required this.isSubmitting,
  });

  final Order order;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final total = '\$${(order.grandTotal / 100).toStringAsFixed(2)}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xxl),
        child: SizedBox(
          height: 56,
          child: BaseButton(
            label: context.l10n.checkoutPlaceOrder(total),
            onPressed: isSubmitting
                ? null
                : () => context.read<CheckoutBloc>().add(
                    const CheckoutConfirmed(),
                  ),
            isLoading: isSubmitting,
          ),
        ),
      ),
    );
  }
}
