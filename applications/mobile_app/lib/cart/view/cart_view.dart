import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/cart/cart.dart';
import 'package:very_yummy_coffee_mobile_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.status == CartStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == CartStatus.failure) {
          return Scaffold(
            body: Center(child: Text(context.l10n.errorSomethingWentWrong)),
          );
        }

        final order = state.order;
        if (order == null || order.items.isEmpty) {
          return Scaffold(
            backgroundColor: context.colors.background,
            body: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CartHeader(itemCount: 0),
                Expanded(child: _EmptyCartView()),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: context.colors.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CartHeader(itemCount: order.items.length),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.items.length,
                        separatorBuilder: (_, _) =>
                            Divider(height: 1, color: context.colors.border),
                        itemBuilder: (_, index) =>
                            _CartItemCard(item: order.items[index]),
                      ),
                      _OrderSummaryCard(order: order),
                      SizedBox(height: context.spacing.xl),
                    ],
                  ),
                ),
              ),
              _CheckoutButton(order: order),
            ],
          ),
        );
      },
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.itemCount});

  final int itemCount;

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
              CustomBackButton(onPressed: () => context.go('/home/menu')),
              SizedBox(width: context.spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.cartTitle,
                      style: context.typography.headline.copyWith(
                        color: context.colors.primaryForeground,
                      ),
                    ),
                    Text(
                      context.l10n.cartItemCount(itemCount),
                      style: context.typography.small.copyWith(
                        color: context.colors.primaryForeground.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});

  final LineItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: context.colors.card),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.secondary,
                borderRadius: BorderRadius.circular(context.radius.medium),
              ),
              child: Icon(
                Icons.local_cafe_outlined,
                size: context.iconSize.medium,
                color: context.colors.primary,
              ),
            ),
            SizedBox(width: context.spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: context.typography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.foreground,
                    ),
                  ),
                  if (item.options.isNotEmpty) ...[
                    SizedBox(height: context.spacing.xs),
                    Text(
                      item.options,
                      style: context.typography.small.copyWith(
                        color: context.colors.mutedForeground,
                      ),
                    ),
                  ],
                  SizedBox(height: context.spacing.sm),
                  Text(
                    '\$${(item.price / 100).toStringAsFixed(2)}',
                    style: context.typography.body.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () => context.read<CartBloc>().add(
                    CartItemQuantityUpdated(
                      lineItemId: item.id,
                      quantity: 0,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: context.iconSize.medium,
                    color: context.colors.mutedForeground,
                  ),
                ),
                SizedBox(height: context.spacing.md),
                _QuantityControls(item: item),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControls extends StatelessWidget {
  const _QuantityControls({required this.item});

  final LineItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.secondary,
        borderRadius: BorderRadius.circular(context.radius.medium),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => context.read<CartBloc>().add(
              CartItemQuantityUpdated(
                lineItemId: item.id,
                quantity: item.quantity - 1,
              ),
            ),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: context.iconSize.tapTarget,
              height: context.iconSize.tapTarget,
              child: Icon(
                Icons.remove,
                size: context.iconSize.small,
                color: context.colors.foreground,
              ),
            ),
          ),
          SizedBox(
            width: 24,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: context.typography.subtitle.copyWith(
                color: context.colors.foreground,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<CartBloc>().add(
              CartItemQuantityUpdated(
                lineItemId: item.id,
                quantity: item.quantity + 1,
              ),
            ),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: context.iconSize.tapTarget,
              height: context.iconSize.tapTarget,
              child: Icon(
                Icons.add,
                size: context.iconSize.small,
                color: context.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final subtotal = order.total;
    final tax = order.tax;
    final total = order.grandTotal;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border(top: BorderSide(color: context.colors.border)),
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
              amount: subtotal,
              style: context.typography.body.copyWith(
                color: context.colors.mutedForeground,
              ),
            ),
            SizedBox(height: context.spacing.sm),
            _SummaryRow(
              label: context.l10n.cartTaxLabel,
              amount: tax,
              style: context.typography.body.copyWith(
                color: context.colors.mutedForeground,
              ),
            ),
            SizedBox(height: context.spacing.md),
            Divider(color: context.colors.border),
            SizedBox(height: context.spacing.md),
            _SummaryRow(
              label: context.l10n.cartTotalLabel,
              amount: total,
              style: context.typography.headline.copyWith(
                color: context.colors.foreground,
              ),
            ),
          ],
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

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final total = '\$${(order.grandTotal / 100).toStringAsFixed(2)}';
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: BaseButton(
          label: context.l10n.cartProceedToCheckout(total),
          onPressed: () => context.go('/home/menu/cart/checkout'),
        ),
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: context.colors.mutedForeground,
            ),
            SizedBox(height: context.spacing.lg),
            Text(
              context.l10n.cartEmptyTitle,
              style: context.typography.headline.copyWith(
                color: context.colors.foreground,
              ),
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              context.l10n.cartEmptySubtitle,
              textAlign: TextAlign.center,
              style: context.typography.body.copyWith(
                color: context.colors.mutedForeground,
              ),
            ),
            SizedBox(height: context.spacing.xl),
            BaseButton(
              label: context.l10n.cartBrowseMenu,
              onPressed: () => context.go('/home/menu'),
            ),
          ],
        ),
      ),
    );
  }
}
