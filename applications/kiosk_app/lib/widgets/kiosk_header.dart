import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_kiosk_app/cart_count/cart_count.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class KioskHeader extends StatelessWidget {
  const KioskHeader({
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.showCartBadge = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showCartBadge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      color: colors.primary,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xxl,
        vertical: subtitle != null ? spacing.xxl : spacing.lg,
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            _BackButton(onBack: onBack),
            SizedBox(width: spacing.lg),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: typography.headline.copyWith(
                    color: colors.primaryForeground,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: typography.body.copyWith(
                      color: colors.primaryForeground.withValues(alpha: 0.67),
                    ),
                  ),
              ],
            ),
          ),
          if (showCartBadge) const CartBadge(),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;

    return GestureDetector(
      onTap: onBack,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: colors.primaryForeground.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(radius.pill),
        ),
        child: Icon(
          Icons.chevron_left,
          color: colors.primaryForeground,
          size: 32,
        ),
      ),
    );
  }
}
