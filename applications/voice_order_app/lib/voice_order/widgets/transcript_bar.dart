import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

/// What the round button in the [TranscriptBar] is doing.
enum TranscriptBarButtonState { idle, connecting, listening }

/// The dark bar along the bottom: a live transcript, the decision latency
/// and the microphone button.
class TranscriptBar extends StatelessWidget {
  const TranscriptBar({
    required this.transcript,
    required this.decidedTranscript,
    required this.buttonState,
    required this.onButtonPressed,
    this.idleIcon = Icons.mic,
    this.hint = 'Tap the mic and order out loud',
    this.latency,
    super.key,
  });

  final String transcript;

  /// The start of [transcript] that the order on screen already reflects.
  /// The rest is drawn dimmed until a decision catches up with it.
  final String decidedTranscript;

  final TranscriptBarButtonState buttonState;
  final VoidCallback onButtonPressed;
  final IconData idleIcon;

  /// Shown while there is no transcript yet.
  final String hint;

  /// How long the latest decision took. Null hides the readout.
  final Duration? latency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final textStyle = typography.subtitle.copyWith(
      fontWeight: FontWeight.w500,
      color: colors.primaryForeground,
    );
    final dimmed = textStyle.copyWith(color: colors.navBarInactive);

    final decidedLength = transcript.startsWith(decidedTranscript)
        ? decidedTranscript.length
        : 0;

    return Container(
      padding: EdgeInsets.only(
        left: spacing.xxl,
        right: spacing.md,
        top: spacing.md,
        bottom: spacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.topBarBackground,
        borderRadius: BorderRadius.circular(radius.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: transcript.isEmpty
                ? Text(hint, maxLines: 1, style: dimmed)
                : _FadingStart(
                    // Reversed so the newest words stay in view.
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: transcript.substring(0, decidedLength),
                            ),
                            TextSpan(
                              text: transcript.substring(decidedLength),
                              style: dimmed,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        style: textStyle,
                      ),
                    ),
                  ),
          ),
          if (latency case final latency?) ...[
            SizedBox(width: spacing.lg),
            Text(
              '${latency.inMilliseconds} ms',
              style: typography.caption.copyWith(
                color: colors.navBarInactive,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
          SizedBox(width: spacing.lg),
          _BarButton(
            state: buttonState,
            idleIcon: idleIcon,
            onPressed: onButtonPressed,
          ),
        ],
      ),
    );
  }
}

/// Fades out the leading edge of a scrolled line of text.
class _FadingStart extends StatelessWidget {
  const _FadingStart({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final opaque = context.colors.primaryForeground;
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [opaque.withValues(alpha: 0), opaque],
        stops: const [0, 0.08],
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.state,
    required this.idleIcon,
    required this.onPressed,
  });

  final TranscriptBarButtonState state;
  final IconData idleIcon;
  final VoidCallback onPressed;

  static const _size = 52.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconSize = context.iconSize;
    final listening = state == TranscriptBarButtonState.listening;

    return Semantics(
      button: true,
      label: listening ? 'Stop listening' : 'Start listening',
      child: Material(
        color: listening ? colors.accentGold : colors.secondary,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: _size,
            child: Center(
              child: switch (state) {
                TranscriptBarButtonState.idle => Icon(
                  idleIcon,
                  size: iconSize.large,
                  color: colors.foreground,
                ),
                TranscriptBarButtonState.connecting => SizedBox.square(
                  dimension: iconSize.large,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.foreground,
                  ),
                ),
                TranscriptBarButtonState.listening => const _ListeningBars(),
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Five bars that rise and fall while the microphone is live.
class _ListeningBars extends StatefulWidget {
  const _ListeningBars();

  @override
  State<_ListeningBars> createState() => _ListeningBarsState();
}

class _ListeningBarsState extends State<_ListeningBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  static const _barCount = 5;
  static const _maxHeight = 20.0;
  static const _minHeight = 6.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var bar = 0; bar < _barCount; bar++)
            Container(
              width: 3,
              height: _barHeight(bar),
              margin: EdgeInsets.symmetric(horizontal: spacing.xxs / 2),
              decoration: BoxDecoration(
                color: colors.foreground,
                borderRadius: BorderRadius.circular(context.radius.pill),
              ),
            ),
        ],
      ),
    );
  }

  double _barHeight(int bar) {
    // Each bar follows the same triangle wave, offset from its neighbor.
    final phase = (_controller.value + bar / _barCount) % 1;
    final wave = 1 - (phase * 2 - 1).abs();
    return _minHeight + (_maxHeight - _minHeight) * wave;
  }
}
