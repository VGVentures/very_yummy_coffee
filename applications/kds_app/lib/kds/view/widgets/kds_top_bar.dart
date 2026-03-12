import 'package:app_shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_kds_app/kds/bloc/kds_bloc.dart';
import 'package:very_yummy_coffee_kds_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// The top bar of the KDS display.
///
/// Shows the app title, connection status dot, queue count pill, and a live
/// clock via the shared [AppTopBar] widget.
class KdsTopBar extends StatelessWidget {
  const KdsTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final isConnected = state.status == AppStatus.connected;
        return AppTopBar(
          title: l10n.appTitle,
          isConnected: isConnected,
          middleWidgets: [
            BlocBuilder<KdsBloc, KdsState>(
              builder: (context, kdsState) {
                final total =
                    kdsState.newOrders.length +
                    kdsState.inProgressOrders.length +
                    kdsState.readyOrders.length;
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.orderQueue(total),
                    style: typography.caption.copyWith(
                      color: colors.primaryForeground,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
