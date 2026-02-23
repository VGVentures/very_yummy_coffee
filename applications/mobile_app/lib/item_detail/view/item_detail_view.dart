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
        if (state.status == .added) {
          context.go('/menu/cart');
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
                      _SizeSection(selectedSize: state.selectedSize),
                      _MilkSection(selectedMilk: state.selectedMilk),
                      _ExtrasSection(selectedExtras: state.selectedExtras),
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
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFC96B45), Color(0xFFA0522D)],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_cafe_outlined,
                size: 64,
                color: Colors.white.withValues(alpha: 0.6),
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
                  child: CustomBackButton(onPressed: () => context.pop()),
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
    return GestureDetector(
      onTap: () =>
          context.read<ItemDetailBloc>().add(ItemDetailSizeSelected(size)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: context.spacing.md),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : context.colors.secondary,
          borderRadius: BorderRadius.circular(context.radius.medium),
          border: isSelected ? null : Border.all(color: context.colors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              size.shortLabel,
              style: context.typography.subtitle.copyWith(
                color: isSelected
                    ? context.colors.primaryForeground
                    : context.colors.mutedForeground,
              ),
            ),
            SizedBox(height: context.spacing.xs),
            Text(
              size.label,
              style: context.typography.small.copyWith(
                color: isSelected
                    ? context.colors.primaryForeground
                    : context.colors.mutedForeground,
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
    return GestureDetector(
      onTap: () =>
          context.read<ItemDetailBloc>().add(ItemDetailMilkSelected(milk)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.xl,
          vertical: context.spacing.lg,
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : context.colors.secondary,
          borderRadius: BorderRadius.circular(context.radius.medium),
          border: isSelected
              ? Border.all(color: context.colors.primary, width: 2)
              : Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              milk.label,
              style: context.typography.body.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? context.colors.primaryForeground
                    : context.colors.mutedForeground,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: context.iconSize.medium,
                color: context.colors.primaryForeground,
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
    return GestureDetector(
      onTap: () =>
          context.read<ItemDetailBloc>().add(ItemDetailExtraToggled(extra)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.lg,
          vertical: context.spacing.sm + context.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : context.colors.secondary,
          borderRadius: BorderRadius.circular(context.radius.pill),
          border: isSelected ? null : Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check : Icons.add,
              size: 14,
              color: isSelected
                  ? context.colors.primaryForeground
                  : context.colors.mutedForeground,
            ),
            SizedBox(width: context.spacing.xs),
            Text(
              extra.label,
              style: context.typography.small.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? context.colors.primaryForeground
                    : context.colors.mutedForeground,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border(
          bottom: BorderSide(color: context.colors.border),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: Column(
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
          padding: EdgeInsets.only(
            left: context.spacing.xl,
            right: context.spacing.xl,
            top: context.spacing.xl,
            bottom: context.spacing.xl,
          ),
          child: Row(
            children: [
              _QuantitySelector(quantity: state.quantity),
              SizedBox(width: context.spacing.xl),
              Expanded(
                child: _AddToCartButton(
                  totalPrice: state.totalPrice,
                  isLoading: isAdding,
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
  });

  final int totalPrice;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () => context.read<ItemDetailBloc>().add(
              const ItemDetailAddToCartRequested(),
            ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: context.colors.primary,
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
