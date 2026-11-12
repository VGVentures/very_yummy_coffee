import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:very_yummy_coffee_voice_order_app/menu/menu.dart';
import 'package:very_yummy_coffee_voice_order_app/voice_order/bloc/voice_order_bloc.dart';
import 'package:very_yummy_coffee_voice_order_app/voice_order/widgets/widgets.dart';

class VoiceOrderView extends StatelessWidget {
  const VoiceOrderView({this.isSample = false, this.onExit, super.key});

  /// Whether the recorded sample order is playing instead of a live session.
  final bool isSample;

  /// Returns to the setup screen. Null hides the control.
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(isSample: isSample, onExit: onExit),
              const Expanded(child: _OrderArea()),
              const _ErrorBanner(),
              _OrderTranscriptBar(isSample: isSample),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isSample, required this.onExit});

  final bool isSample;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final onExit = this.onExit;

    final drinkCount = context.select<VoiceOrderBloc, int>(
      (bloc) => bloc.state.drinks.length,
    );
    final totalCents = context.select<VoiceOrderBloc, int>(
      (bloc) => bloc.state.totalCents,
    );
    final hasTranscript = context.select<VoiceOrderBloc, bool>(
      (bloc) => bloc.state.transcript.isNotEmpty,
    );

    return Row(
      children: [
        Text('Very Yummy Coffee', style: typography.pageTitle),
        if (isSample) ...[
          SizedBox(width: spacing.md),
          StatusBadge(
            label: 'Sample replay',
            backgroundColor: colors.statusWarningBackground,
            foregroundColor: colors.statusWarningForeground,
          ),
        ],
        const Spacer(),
        if (drinkCount > 0)
          Text(
            '$drinkCount ${drinkCount == 1 ? 'drink' : 'drinks'}'
            '  ·  ${formatCents(totalCents)}',
            style: typography.subtitle,
          ),
        if (hasTranscript) ...[
          SizedBox(width: spacing.lg),
          TextButton(
            onPressed: () =>
                context.read<VoiceOrderBloc>().add(const VoiceOrderReset()),
            style: TextButton.styleFrom(foregroundColor: colors.primary),
            child: const Text('Start over'),
          ),
        ],
        if (onExit != null)
          IconButton(
            onPressed: onExit,
            tooltip: 'Back to setup',
            color: colors.mutedForeground,
            icon: const Icon(Icons.logout),
          ),
      ],
    );
  }
}

class _OrderArea extends StatelessWidget {
  const _OrderArea();

  static const _minCardWidth = 176.0;
  static const _maxCardWidth = 236.0;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final spacing = context.spacing;
    final drinks = context.select<VoiceOrderBloc, List<DrinkOrder>>(
      (bloc) => bloc.state.drinks,
    );

    if (drinks.isEmpty) {
      return Center(
        child: Text(
          'What can I get started for you?',
          textAlign: TextAlign.center,
          style: typography.sectionTitle,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Shrink the cards to keep them on one row for as long as they fit.
        final gaps = spacing.lg * (drinks.length - 1);
        final cardWidth = ((constraints.maxWidth - gaps) / drinks.length).clamp(
          _minCardWidth,
          _maxCardWidth,
        );

        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: spacing.lg),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing.lg,
              runSpacing: spacing.lg,
              children: [
                for (final (index, drink) in drinks.indexed)
                  _Entrance(
                    // Keyed by position so a card keeps its state, and its
                    // change highlights, while the drink in it is edited.
                    key: ValueKey(index),
                    child: SizedBox(
                      width: cardWidth,
                      child: DrinkCard(order: drink),
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

/// Fades and lifts a newly added card into place.
class _Entrance extends StatelessWidget {
  const _Entrance({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final offset = context.spacing.lg;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, offset * (1 - progress)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final message = context.select<VoiceOrderBloc, String?>(
      (bloc) => bloc.state.errorMessage,
    );
    if (message == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: spacing.md),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.statusDestructiveBackground,
        borderRadius: BorderRadius.circular(context.radius.small),
      ),
      child: Text(
        message,
        style: typography.body.copyWith(
          color: colors.statusDestructiveForeground,
        ),
      ),
    );
  }
}

class _OrderTranscriptBar extends StatelessWidget {
  const _OrderTranscriptBar({required this.isSample});

  final bool isSample;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceOrderBloc, VoiceOrderState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.transcript != current.transcript ||
          previous.decidedTranscript != current.decidedTranscript ||
          previous.latency != current.latency,
      builder: (context, state) {
        final bloc = context.read<VoiceOrderBloc>();
        final idle = state.status == VoiceOrderStatus.idle;

        return TranscriptBar(
          transcript: state.transcript,
          decidedTranscript: state.decidedTranscript,
          // The sample's latency is a fixed delay, not a measurement.
          latency: isSample ? null : state.latency,
          idleIcon: isSample ? Icons.play_arrow : Icons.mic,
          hint: isSample
              ? 'Press play to hear a sample order'
              : 'Tap the mic and order out loud',
          buttonState: switch (state.status) {
            VoiceOrderStatus.idle => TranscriptBarButtonState.idle,
            VoiceOrderStatus.connecting => TranscriptBarButtonState.connecting,
            VoiceOrderStatus.listening => TranscriptBarButtonState.listening,
          },
          onButtonPressed: () {
            // The sample always plays from the top.
            if (isSample && idle && state.transcript.isNotEmpty) {
              bloc.add(const VoiceOrderReset());
            }
            bloc.add(const VoiceOrderMicToggled());
          },
        );
      },
    );
  }
}
