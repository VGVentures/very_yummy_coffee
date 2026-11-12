import 'dart:async';

import 'package:flutter/material.dart';

/// Rebuilds with a strength that jumps to 1 whenever [value] changes and
/// then eases back to 0, so a change is noticed and then settles.
class HighlightOnChange extends StatefulWidget {
  const HighlightOnChange({
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 2200),
    super.key,
  });

  final Object value;
  final Duration duration;
  final Widget Function(BuildContext context, double strength) builder;

  @override
  State<HighlightOnChange> createState() => _HighlightOnChangeState();
}

class _HighlightOnChangeState extends State<HighlightOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );

  @override
  void didUpdateWidget(HighlightOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Hold at full strength for the first half, then fade out.
        final fade = ((_controller.value - 0.5) * 2).clamp(0.0, 1.0);
        return widget.builder(
          context,
          1 - Curves.easeOut.transform(fade),
        );
      },
    );
  }
}
