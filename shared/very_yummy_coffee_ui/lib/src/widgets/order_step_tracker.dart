import 'package:flutter/material.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_ui/src/theme/theme.dart';

/// {@template order_step_tracker}
/// A horizontal step tracker that visually represents the progress of an order.
///
/// Accepts an [OrderStatus] and a list of [labels] (exactly 4) and highlights
/// the active step and all completed steps.
/// {@endtemplate}
class OrderStepTracker extends StatelessWidget {
  /// {@macro order_step_tracker}
  const OrderStepTracker({
    required this.status,
    required this.labels,
    super.key,
  });

  /// The current status of the order.
  final OrderStatus status;

  /// The step labels. Must have exactly 4 elements, one per step.
  final List<String> labels;

  int get _activeStepIndex {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.submitted:
        return 1;
      case OrderStatus.ready:
        return 2;
      case OrderStatus.completed:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeStepIndex;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(context.radius.large),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: Row(
          children: List.generate(labels.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepIndex = i ~/ 2;
              final filled = active > stepIndex;
              return Expanded(
                child: Container(
                  height: 2,
                  color: filled
                      ? context.colors.primary
                      : context.colors.border,
                ),
              );
            }
            final stepIndex = i ~/ 2;
            final isActive = stepIndex == active;
            final isCompleted = stepIndex < active;
            return _StepNode(
              label: labels[stepIndex],
              isActive: isActive,
              isCompleted: isCompleted,
            );
          }),
        ),
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  final String label;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final filled = isActive || isCompleted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? context.colors.primary : context.colors.background,
            border: Border.all(
              color: filled ? context.colors.primary : context.colors.border,
              width: 2,
            ),
          ),
          child: filled
              ? Icon(
                  Icons.check,
                  size: 14,
                  color: context.colors.primaryForeground,
                )
              : null,
        ),
        SizedBox(height: context.spacing.xs),
        Text(
          label,
          style: context.typography.small.copyWith(
            color: filled
                ? context.colors.primary
                : context.colors.mutedForeground,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
