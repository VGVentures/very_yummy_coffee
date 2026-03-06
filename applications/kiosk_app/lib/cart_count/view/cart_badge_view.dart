import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_kiosk_app/cart_count/cart_count.dart';
import 'package:very_yummy_coffee_kiosk_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class CartBadgeView extends StatelessWidget {
  const CartBadgeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radius = context.radius;

    return BlocSelector<CartCountBloc, CartCountState, int>(
      selector: (state) => state.itemCount,
      builder: (context, count) {
        return GestureDetector(
          onTap: () => context.go('/home/menu/cart'),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.xl,
              vertical: spacing.md,
            ),
            decoration: BoxDecoration(
              color: colors.primaryForeground.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(radius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: colors.primaryForeground,
                  size: 20,
                ),
                SizedBox(width: spacing.sm),
                Text(
                  context.l10n.kioskCartBadge(count),
                  style: typography.subtitle.copyWith(
                    color: colors.primaryForeground,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
