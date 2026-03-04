import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_pos_app/app/app.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class PosTopBar extends StatefulWidget {
  const PosTopBar({super.key});

  @override
  State<PosTopBar> createState() => _PosTopBarState();
}

class _PosTopBarState extends State<PosTopBar> {
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
          BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              final isConnected = state.status == AppStatus.connected;
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green : colors.destructive,
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          SizedBox(width: spacing.md),
          Text(
            l10n.appTitle,
            style: typography.subtitle.copyWith(
              color: colors.primaryForeground,
            ),
          ),
          const Spacer(),
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
          SizedBox(width: spacing.xl),
          TextButton(
            onPressed: () => context.go('/pos-orders'),
            style: TextButton.styleFrom(
              foregroundColor: colors.primaryForeground,
            ),
            child: Text(l10n.viewOrders),
          ),
        ],
      ),
    );
  }
}
