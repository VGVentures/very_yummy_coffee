import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/item_detail/item_detail.dart';
import 'package:very_yummy_coffee_kiosk_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_kiosk_app/widgets/widgets.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class ItemDetailView extends StatelessWidget {
  const ItemDetailView({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ItemDetailBloc, ItemDetailState>(
      listener: (context, state) {
        if (state.status == ItemDetailStatus.added) {
          context.go('/home/menu/$groupId');
        }
      },
      builder: (context, state) {
        final item = state.item;
        if (item == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: context.colors.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KioskHeader(
                showBackButton: true,
                onBack: () => context.go('/home/menu/$groupId'),
                title: item.name,
                showCartBadge: true,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ItemHeroPanel(item: item),
                    Expanded(
                      child: _ItemCustomPanel(
                        state: state,
                        isUnavailable: !item.available,
                      ),
                    ),
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

class _ItemHeroPanel extends StatelessWidget {
  const _ItemHeroPanel({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return SizedBox(
      width: 520,
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.primary),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.imageUrl != null && item.imageUrl!.trim().isNotEmpty)
              SizedBox(
                width: 360,
                height: 240,
                child: MenuItemImage(
                  imageUrl: item.imageUrl,
                  borderRadius: BorderRadius.circular(context.radius.large),
                ),
              )
            else
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: colors.primaryForeground.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_cafe_outlined,
                  size: 80,
                  color: colors.primaryForeground.withValues(alpha: 0.6),
                ),
              ),
            SizedBox(height: spacing.xxl),
            Text(
              item.name,
              style: typography.headline.copyWith(
                color: colors.primaryForeground,
                fontSize: 28,
              ),
            ),
            SizedBox(height: spacing.lg),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.xl,
                vertical: spacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.primaryForeground.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(context.radius.pill),
              ),
              child: Text(
                '\$${(item.price / 100).toStringAsFixed(2)}',
                style: typography.subtitle.copyWith(
                  color: colors.primaryForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCustomPanel extends StatelessWidget {
  const _ItemCustomPanel({
    required this.state,
    required this.isUnavailable,
  });

  final ItemDetailState state;
  final bool isUnavailable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final group in state.applicableModifierGroups) ...[
                  ModifierGroupSelector(
                    groupName: group.name,
                    isRequired: group.required,
                    isMultiSelect: group.selectionMode == SelectionMode.multi,
                    options: group.options
                        .map(
                          (o) => ModifierOptionData(
                            name: o.name,
                            priceDeltaCents: o.priceDeltaCents,
                            isSelected:
                                (state.selectedModifiers[group.id] ?? const [])
                                    .contains(o.id),
                          ),
                        )
                        .toList(),
                    onOptionToggled: (index) {
                      context.read<ItemDetailBloc>().add(
                        ItemDetailModifierOptionToggled(
                          groupId: group.id,
                          optionId: group.options[index].id,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: spacing.xl),
                ],
              ],
            ),
          ),
        ),
        _AddToCartBar(
          state: state,
          isUnavailable: isUnavailable,
        ),
        if (isUnavailable)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.sm),
            child: Text(
              context.l10n.itemDetailUnavailable,
              textAlign: TextAlign.center,
              style: context.typography.small.copyWith(
                color: colors.destructive,
              ),
            ),
          ),
      ],
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.state,
    required this.isUnavailable,
  });

  final ItemDetailState state;
  final bool isUnavailable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isAdding = state.status == ItemDetailStatus.adding;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Row(
          children: [
            _QuantitySelector(quantity: state.quantity),
            SizedBox(width: spacing.xl),
            Expanded(
              child: BaseButton(
                label:
                    '${context.l10n.itemDetailAddToCart} — '
                    '\$${(state.totalPrice / 100).toStringAsFixed(2)}',
                onPressed: isUnavailable || isAdding || !state.canAddToCart
                    ? null
                    : () => context.read<ItemDetailBloc>().add(
                        const ItemDetailAddToCartRequested(),
                      ),
                isLoading: isAdding,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(context.radius.medium),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove,
            onTap: () => context.read<ItemDetailBloc>().add(
              const ItemDetailQuantityDecremented(),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: typography.subtitle.copyWith(color: colors.foreground),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            onTap: () => context.read<ItemDetailBloc>().add(
              const ItemDetailQuantityIncremented(),
            ),
            iconColor: colors.primary,
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: context.iconSize.tapTarget,
        height: context.iconSize.tapTarget,
        child: Icon(
          icon,
          size: context.iconSize.medium,
          color: iconColor ?? context.colors.foreground,
        ),
      ),
    );
  }
}
