import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_kds_app/app/app.dart';
import 'package:very_yummy_coffee_kds_app/kds/bloc/kds_bloc.dart';
import 'package:very_yummy_coffee_kds_app/kds/view/kds_colors.dart';
import 'package:very_yummy_coffee_kds_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// The top bar of the KDS display.
///
/// Shows the app title, connection status dot, queue count pill, and a live
/// clock. The clock stream is created once in State.initState to avoid
/// spawning a new timer on every parent rebuild.
class KdsTopBar extends StatefulWidget {
  const KdsTopBar({super.key});

  @override
  State<KdsTopBar> createState() => _KdsTopBarState();
}

class _KdsTopBarState extends State<KdsTopBar> {
  late final Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();
    _clockStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    ).asBroadcastStream(onCancel: (sub) => sub.cancel());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    const barBackground = Color(0xFF2D1B14);

    return Container(
      color: barBackground,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xxl,
        vertical: spacing.md,
      ),
      child: Row(
        children: [
          // Connection status dot
          BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              final isConnected = state.status == AppStatus.connected;
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isConnected ? kdsReadyGreen : colors.destructive,
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          SizedBox(width: spacing.md),
          // App title
          Text(
            l10n.appTitle,
            style: typography.subtitle.copyWith(
              color: colors.primaryForeground,
            ),
          ),
          SizedBox(width: spacing.lg),
          // Queue count pill
          BlocBuilder<KdsBloc, KdsState>(
            builder: (context, state) {
              final total =
                  state.newOrders.length +
                  state.inProgressOrders.length +
                  state.readyOrders.length;
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
          const Spacer(),
          // Live clock
          StreamBuilder<DateTime>(
            stream: _clockStream,
            builder: (context, snapshot) {
              final now = snapshot.data ?? DateTime.now();
              final hours = now.hour.toString().padLeft(2, '0');
              final minutes = now.minute.toString().padLeft(2, '0');
              final seconds = now.second.toString().padLeft(2, '0');
              return Text(
                '$hours:$minutes:$seconds',
                style: typography.subtitle.copyWith(
                  color: colors.primaryForeground,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
