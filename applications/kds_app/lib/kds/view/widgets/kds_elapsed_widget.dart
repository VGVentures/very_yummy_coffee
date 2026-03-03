import 'dart:async';

import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_kds_app/l10n/l10n.dart';

/// Displays a live elapsed time for an order.
///
/// When [isLiveTimer] is true, shows a counting-up MM:SS timer (for IN
/// PROGRESS orders). When false, shows a human-readable age string such as
/// "just now", "X min ago", or "Xh Xm ago" (for NEW orders).
///
/// If [submittedAt] is null, a dash is shown in place of time.
class KdsElapsedWidget extends StatefulWidget {
  const KdsElapsedWidget({
    required this.submittedAt,
    required this.isLiveTimer,
    super.key,
  });

  final DateTime? submittedAt;
  final bool isLiveTimer;

  @override
  State<KdsElapsedWidget> createState() => _KdsElapsedWidgetState();
}

class _KdsElapsedWidgetState extends State<KdsElapsedWidget> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateElapsed(),
    );
  }

  void _updateElapsed() {
    final submitted = widget.submittedAt;
    if (submitted == null) return;
    setState(() => _elapsed = DateTime.now().difference(submitted));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.submittedAt == null) {
      return const Text('—');
    }

    final text = widget.isLiveTimer ? _formatTimer() : _formatAge(context);

    return Text(text);
  }

  String _formatTimer() {
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatAge(BuildContext context) {
    final l10n = context.l10n;
    final totalSeconds = _elapsed.inSeconds;
    if (totalSeconds < 60) return l10n.ageJustNow;

    final totalMinutes = _elapsed.inMinutes;
    if (totalMinutes < 60) return l10n.ageMinutesAgo(totalMinutes);

    final hours = _elapsed.inHours;
    final minutes = totalMinutes.remainder(60);
    return l10n.ageHoursMinutesAgo(hours, minutes);
  }
}
