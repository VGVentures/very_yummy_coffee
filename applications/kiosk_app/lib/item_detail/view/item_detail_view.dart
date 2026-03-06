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
                _SizeSection(selectedSize: state.selectedSize),
                SizedBox(height: spacing.xl),
                _MilkSection(selectedMilk: state.selectedMilk),
                SizedBox(height: spacing.xl),
                _ExtrasSection(selectedExtras: state.selectedExtras),
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

class _SizeSection extends StatelessWidget {
  const _SizeSection({required this.selectedSize});

  final DrinkSize selectedSize;

  @override
  Widget build(BuildContext context) {
    return _CustomizationCard(
      label: context.l10n.itemDetailSizeLabel,
      child: Row(
        children: DrinkSize.values.map((size) {
          final isSelected = size == selectedSize;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: size != DrinkSize.values.last ? context.spacing.sm : 0,
              ),
              child: _SizeOption(size: size, isSelected: isSelected),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({required this.size, required this.isSelected});

  final DrinkSize size;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return GestureDetector(
      onTap: () =>
          context.read<ItemDetailBloc>().add(ItemDetailSizeSelected(size)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: spacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.secondary,
          borderRadius: BorderRadius.circular(context.radius.medium),
          border: isSelected ? null : Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              size.shortLabel,
              style: typography.subtitle.copyWith(
                color: isSelected
                    ? colors.primaryForeground
                    : colors.mutedForeground,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              size.label,
              style: typography.small.copyWith(
                color: isSelected
                    ? colors.primaryForeground
                    : colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilkSection extends StatelessWidget {
  const _MilkSection({required this.selectedMilk});

  final MilkOption selectedMilk;

  @override
  Widget build(BuildContext context) {
    return _CustomizationCard(
      label: context.l10n.itemDetailMilkLabel,
      child: Column(
        children: MilkOption.values.map((milk) {
          final isSelected = milk == selectedMilk;
          return Padding(
            padding: EdgeInsets.only(
              bottom: milk != MilkOption.values.last ? context.spacing.sm : 0,
            ),
            child: _MilkOption(milk: milk, isSelected: isSelected),
          );
        }).toList(),
      ),
    );
  }
}

class _MilkOption extends StatelessWidget {
  const _MilkOption({required this.milk, required this.isSelected});

  final MilkOption milk;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return GestureDetector(
      onTap: () =>
          context.read<ItemDetailBloc>().add(ItemDetailMilkSelected(milk)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.xl,
          vertical: spacing.lg,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.secondary,
          borderRadius: BorderRadius.circular(context.radius.medium),
          border: isSelected
              ? Border.all(color: colors.primary, width: 2)
              : Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              milk.label,
              style: typography.body.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? colors.primaryForeground
                    : colors.mutedForeground,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: context.iconSize.medium,
                color: colors.primaryForeground,
              ),
          ],
        ),
      ),
    );
  }
}

class _ExtrasSection extends StatelessWidget {
  const _ExtrasSection({required this.selectedExtras});

  final List<DrinkExtra> selectedExtras;

  @override
  Widget build(BuildContext context) {
    return _CustomizationCard(
      label: context.l10n.itemDetailExtrasLabel,
      child: Wrap(
        spacing: context.spacing.sm,
        runSpacing: context.spacing.sm,
        children: DrinkExtra.values.map((extra) {
          final isSelected = selectedExtras.contains(extra);
          return _ExtraChip(extra: extra, isSelected: isSelected);
        }).toList(),
      ),
    );
  }
}

class _ExtraChip extends StatelessWidget {
  const _ExtraChip({required this.extra, required this.isSelected});

  final DrinkExtra extra;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return GestureDetector(
      onTap: () =>
          context.read<ItemDetailBloc>().add(ItemDetailExtraToggled(extra)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.lg,
          vertical: spacing.sm + spacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.secondary,
          borderRadius: BorderRadius.circular(context.radius.pill),
          border: isSelected ? null : Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check : Icons.add,
              size: 14,
              color: isSelected
                  ? colors.primaryForeground
                  : colors.mutedForeground,
            ),
            SizedBox(width: spacing.xs),
            Text(
              extra.label,
              style: typography.small.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? colors.primaryForeground
                    : colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomizationCard extends StatelessWidget {
  const _CustomizationCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.typography.subtitle.copyWith(
            color: context.colors.foreground,
          ),
        ),
        SizedBox(height: context.spacing.md),
        child,
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
                onPressed: isUnavailable || isAdding
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
