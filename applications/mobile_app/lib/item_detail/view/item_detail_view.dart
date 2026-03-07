import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_mobile_app/item_detail/item_detail.dart';
import 'package:very_yummy_coffee_mobile_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class ItemDetailView extends StatelessWidget {
  const ItemDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ItemDetailBloc, ItemDetailState>(
      listener: (context, state) {
        if (state.status == ItemDetailStatus.added) {
          context.go('/home/menu/cart');
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
              const _HeroSection(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DrinkInfoSection(item: item),
                      for (final group in state.applicableModifierGroups)
                        _ModifierSection(
                          group: group,
                          selectedIds:
                              state.selectedModifiers[group.id] ?? const [],
                        ),
                      SizedBox(height: context.spacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _CartBar(state: state),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.colors.primary,
                  context.colors.foreground,
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: context.colors.primaryForeground.withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_cafe_outlined,
                size: 64,
                color: context.colors.primaryForeground.withValues(alpha: 0.6),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: context.spacing.xl,
                  top: context.spacing.xl,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomBackButton(
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrinkInfoSection extends StatelessWidget {
  const _DrinkInfoSection({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border(
          bottom: BorderSide(color: context.colors.border),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: context.spacing.xl,
          right: context.spacing.xl,
          top: context.spacing.xxl,
          bottom: context.spacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: context.typography.pageTitle.copyWith(
                color: context.colors.primary,
              ),
            ),
            SizedBox(height: context.spacing.md),
            Text(
              '\$${(item.price / 100).toStringAsFixed(2)}',
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

class _ModifierSection extends StatelessWidget {
  const _ModifierSection({
    required this.group,
    required this.selectedIds,
  });

  final ModifierGroup group;
  final List<String> selectedIds;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border(
          bottom: BorderSide(color: context.colors.border),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: ModifierGroupSelector(
          groupName: group.name,
          isRequired: group.required,
          isMultiSelect: group.selectionMode == SelectionMode.multi,
          options: group.options
              .map(
                (o) => ModifierOptionData(
                  name: o.name,
                  priceDeltaCents: o.priceDeltaCents,
                  isSelected: selectedIds.contains(o.id),
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
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({required this.state});

  final ItemDetailState state;

  @override
  Widget build(BuildContext context) {
    final isAdding = state.status == ItemDetailStatus.adding;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border(
          top: BorderSide(color: context.colors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl),
          child: Row(
            children: [
              _QuantitySelector(quantity: state.quantity),
              SizedBox(width: context.spacing.xl),
              Expanded(
                child: _AddToCartButton(
                  totalPrice: state.totalPrice,
                  isLoading: isAdding,
                  isEnabled: state.canAddToCart,
                ),
              ),
            ],
          ),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.secondary,
        borderRadius: BorderRadius.circular(context.radius.medium),
        border: Border.all(color: context.colors.border),
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
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: context.typography.subtitle.copyWith(
                color: context.colors.foreground,
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            onTap: () => context.read<ItemDetailBloc>().add(
              const ItemDetailQuantityIncremented(),
            ),
            iconColor: context.colors.primary,
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

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({
    required this.totalPrice,
    required this.isLoading,
    required this.isEnabled,
  });

  final int totalPrice;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading || !isEnabled
          ? null
          : () => context.read<ItemDetailBloc>().add(
              const ItemDetailAddToCartRequested(),
            ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isEnabled
              ? context.colors.primary
              : context.colors.mutedForeground,
          borderRadius: BorderRadius.circular(context.radius.large),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colors.primaryForeground,
                ),
              )
            else ...[
              Icon(
                Icons.shopping_bag_outlined,
                size: context.iconSize.medium,
                color: context.colors.primaryForeground,
              ),
              SizedBox(width: context.spacing.sm),
              Text(
                '${context.l10n.itemDetailAddToCart} — '
                '\$${(totalPrice / 100).toStringAsFixed(2)}',
                style: context.typography.button.copyWith(
                  color: context.colors.primaryForeground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
