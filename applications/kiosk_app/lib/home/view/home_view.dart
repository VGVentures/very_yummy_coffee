import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_kiosk_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/home_bg.png',
              fit: BoxFit.cover,
            ),
            ColoredBox(color: colors.homeBackgroundOverlay),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.kioskBrandName,
                    style: typography.pageTitle.copyWith(
                      fontSize: 88,
                      color: colors.primaryForeground,
                    ),
                  ),
                  SizedBox(height: spacing.huge * 1.5),
                  Text(
                    l10n.kioskTagline,
                    style: typography.subtitle.copyWith(
                      fontSize: 28,
                      color: colors.primaryForeground.withValues(alpha: 0.67),
                    ),
                  ),
                  SizedBox(height: spacing.huge * 1.5),
                  GestureDetector(
                    onTap: () => context.go('/home/menu'),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.huge * 2.5,
                        vertical: spacing.xxl,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accentGold,
                        borderRadius: BorderRadius.circular(radius.pill),
                      ),
                      child: Text(
                        l10n.kioskStartOrder,
                        style: typography.headline.copyWith(
                          fontSize: 36,
                          color: colors.foreground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
