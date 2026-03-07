import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/checkout/checkout.dart';
import 'package:very_yummy_coffee_mobile_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
        return Scaffold(
          backgroundColor: context.colors.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CheckoutHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: context.spacing.xl),
                      _CustomerNameCard(controller: _nameController),
                      SizedBox(height: context.spacing.xl),
                      const _FakePaymentCard(),
                      SizedBox(height: context.spacing.xl),
                      if (order != null) _OrderSummarySection(order: order),
                      SizedBox(height: context.spacing.xl),
                    ],
                  ),
                ),
              ),
              if (order != null)
                _PlaceOrderButton(
                  order: order,
                  isSubmitting: state.status == CheckoutStatus.submitting,
                  nameController: _nameController,
                ),
              if (state.status == CheckoutStatus.failure && state.order != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.xl,
                    vertical: context.spacing.sm,
                  ),
                  child: Text(
                    context.l10n.checkoutErrorRetry,
                    textAlign: TextAlign.center,
                    style: context.typography.small.copyWith(
                      color: context.colors.destructive,
                    ),
                  ),
                ),
              SizedBox(height: context.spacing.xl),
            ],
          ),
        );
      },
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: context.colors.primary),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: context.spacing.xl,
            right: context.spacing.xl,
            top: context.spacing.xl,
            bottom: context.spacing.lg,
          ),
          child: Row(
            children: [
              CustomBackButton(onPressed: () => context.go('/home/menu/cart')),
              SizedBox(width: context.spacing.lg),
              Text(
                context.l10n.checkoutTitle,
                style: context.typography.headline.copyWith(
                  color: context.colors.primaryForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerNameCard extends StatelessWidget {
  const _CustomerNameCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(context.radius.large),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing.xl),
          child: TextField(
            controller: controller,
            style: typography.body,
            maxLength: 30,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            decoration: InputDecoration(
              hintText: context.l10n.checkoutCustomerNameHint,
              hintStyle: typography.body.copyWith(
                color: colors.mutedForeground,
              ),
              counterText: '',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radius.small),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radius.small),
                borderSide: BorderSide(color: colors.border),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FakePaymentCard extends StatelessWidget {
  const _FakePaymentCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(context.radius.large),
          border: Border.all(color: context.colors.border),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: context.colors.primary,
                size: context.iconSize.medium,
              ),
              SizedBox(width: context.spacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.checkoutFakePaymentLabel,
                    style: context.typography.subtitle.copyWith(
                      color: context.colors.foreground,
                    ),
                  ),
                  Text(
                    context.l10n.checkoutFakePaymentSubtitle,
                    style: context.typography.small.copyWith(
                      color: context.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummarySection extends StatelessWidget {
  const _OrderSummarySection({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(context.radius.large),
          border: Border.all(color: context.colors.border),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.cartOrderSummaryLabel,
                style: context.typography.subtitle.copyWith(
                  color: context.colors.foreground,
                ),
              ),
              SizedBox(height: context.spacing.md),
              _SummaryRow(
                label: context.l10n.cartSubtotalLabel,
                amount: order.total,
                style: context.typography.body.copyWith(
                  color: context.colors.mutedForeground,
                ),
              ),
              SizedBox(height: context.spacing.sm),
              _SummaryRow(
                label: context.l10n.cartTaxLabel,
                amount: order.tax,
                style: context.typography.body.copyWith(
                  color: context.colors.mutedForeground,
                ),
              ),
              SizedBox(height: context.spacing.md),
              Divider(color: context.colors.border),
              SizedBox(height: context.spacing.md),
              _SummaryRow(
                label: context.l10n.cartTotalLabel,
                amount: order.grandTotal,
                style: context.typography.headline.copyWith(
                  color: context.colors.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.style,
  });

  final String label;
  final int amount;
  final TextStyle style;

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

class _PlaceOrderButton extends StatelessWidget {
  const _PlaceOrderButton({
    required this.order,
    required this.isSubmitting,
    required this.nameController,
  });

  final Order order;
  final bool isSubmitting;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    final total = '\$${(order.grandTotal / 100).toStringAsFixed(2)}';
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.spacing.xl),
        child: BaseButton(
          label: context.l10n.checkoutPlaceOrder(total),
          onPressed: () => context.read<CheckoutBloc>().add(
            CheckoutConfirmed(customerName: nameController.text),
          ),
          isLoading: isSubmitting,
        ),
      ),
    );
  }
}
