import 'package:app_shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class PosTopBar extends StatelessWidget {
  const PosTopBar({this.showBackButton = false, super.key});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final isConnected = state.status == AppStatus.connected;
        return AppTopBar(
          title: l10n.appTitle,
          isConnected: isConnected,
          middleWidgets: showBackButton
              ? [
                  GestureDetector(
                    onTap: () => context.go('/ordering'),
                    child: Container(
                      height: 32,
                      padding: EdgeInsets.symmetric(horizontal: spacing.md),
                      decoration: BoxDecoration(
                        color: colors.primaryForeground.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(radius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chevron_left,
                            color: colors.primaryForeground,
                            size: 16,
                          ),
                          SizedBox(width: spacing.xs),
                          Text(
                            l10n.ordersBack,
                            style: typography.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colors.primaryForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              : [],
          actionWidgets: showBackButton
              ? []
              : [
                  TextButton(
                    onPressed: () => context.go('/stock-management'),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primaryForeground,
                    ),
                    child: Text(l10n.posStockManagement),
                  ),
                  TextButton(
                    onPressed: () => context.go('/order-history'),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primaryForeground,
                    ),
                    child: Text(l10n.viewOrders),
                  ),
                ],
        );
      },
    );
  }
}
