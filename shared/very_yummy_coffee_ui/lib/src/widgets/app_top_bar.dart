import 'dart:async';

import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';

/// A shared top bar used across KDS and POS apps.
///
/// Renders a dark header bar with a connection-status dot, the app title,
/// a live clock, and optional widget slots for app-specific content.
/// The clock stream is created once in [State.initState] to avoid
/// spawning a new timer on every parent rebuild.
class AppTopBar extends StatefulWidget {
  /// {@macro app_top_bar}
  const AppTopBar({
    required this.title,
    required this.isConnected,
    this.middleWidgets = const [],
    this.actionWidgets = const [],
    super.key,
  });

  /// The app title displayed next to the connection dot.
  final String title;

  /// Whether the app is currently connected to the server.
  final bool isConnected;

  /// Widgets placed between the title and the spacer (e.g., queue count badge).
  final List<Widget> middleWidgets;

  /// Widgets placed after the clock (e.g., navigation buttons).
  final List<Widget> actionWidgets;

  @override
  State<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends State<AppTopBar> {
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
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Container(
      color: colors.topBarBackground,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xxl,
        vertical: spacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: widget.isConnected ? colors.connected : colors.destructive,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: spacing.md),
          Text(
            widget.title,
            style: typography.subtitle.copyWith(
              color: colors.primaryForeground,
            ),
          ),
          for (final w in widget.middleWidgets) ...[
            SizedBox(width: spacing.lg),
            w,
          ],
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
          for (final w in widget.actionWidgets) ...[
            SizedBox(width: spacing.xl),
            w,
          ],
        ],
      ),
    );
  }
}
