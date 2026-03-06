import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/cart/cart.dart';
import 'package:very_yummy_coffee_kiosk_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_kiosk_app/widgets/widgets.dart';
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
            body: Center(
              child: Text(context.l10n.errorSomethingWentWrong),
            ),
          );
        }

        final order = state.order;
        final items = order?.items ?? [];
        final l10n = context.l10n;

        return Scaffold(
          backgroundColor: context.colors.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KioskHeader(
                showBackButton: true,
                onBack: () => context.go('/home/menu'),
                title: l10n.cartTitle,
                subtitle: l10n.cartItemCount(items.length),
              ),
              Expanded(
                child: items.isEmpty
                    ? const _EmptyCartView()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _CartItemList(items: items)),
                          _OrderSummaryPanel(order: order!),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartItemList extends StatelessWidget {
  const _CartItemList({required this.items});

  final List<LineItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(context.spacing.xxl),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: context.colors.border),
      itemBuilder: (_, index) => _CartItemRow(item: items[index]),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item});

  final LineItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.card),
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.secondary,
                borderRadius: BorderRadius.circular(context.radius.medium),
              ),
              child: Icon(
                Icons.local_cafe_outlined,
                size: context.iconSize.medium,
                color: colors.primary,
              ),
            ),
            SizedBox(width: spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: typography.subtitle.copyWith(
                      color: colors.foreground,
                    ),
                  ),
                  if (item.options.isNotEmpty) ...[
                    SizedBox(height: spacing.xs),
                    Text(
                      item.options,
                      style: typography.small.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                  SizedBox(height: spacing.sm),
                  Text(
                    '\$${(item.price / 100).toStringAsFixed(2)}',
                    style: typography.body.copyWith(
                      color: colors.primary,
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
                    color: colors.mutedForeground,
                  ),
                ),
                SizedBox(height: spacing.md),
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
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(context.radius.medium),
        border: Border.all(color: colors.border),
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
                color: colors.foreground,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: context.typography.subtitle.copyWith(
                color: colors.foreground,
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
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryPanel extends StatelessWidget {
  const _OrderSummaryPanel({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;
    final isEmpty = order.items.isEmpty;

    return SizedBox(
      width: 400,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          border: Border(left: BorderSide(color: colors.border)),
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.cartOrderSummaryLabel,
                style: typography.headline.copyWith(color: colors.foreground),
              ),
              SizedBox(height: spacing.xxl),
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
              const Spacer(),
              BaseButton(
                label: l10n.kioskProceedToCheckout,
                onPressed: isEmpty
                    ? null
                    : () => context.go('/home/menu/cart/checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: colors.mutedForeground,
          ),
          SizedBox(height: spacing.lg),
          Text(
            l10n.cartEmptyTitle,
            style: typography.headline.copyWith(color: colors.foreground),
          ),
          SizedBox(height: spacing.sm),
          Text(
            l10n.cartEmptySubtitle,
            textAlign: TextAlign.center,
            style: typography.body.copyWith(color: colors.mutedForeground),
          ),
          SizedBox(height: spacing.xl),
          BaseButton(
            label: l10n.cartBrowseMenu,
            onPressed: () => context.go('/home/menu'),
          ),
        ],
      ),
    );
  }
}
