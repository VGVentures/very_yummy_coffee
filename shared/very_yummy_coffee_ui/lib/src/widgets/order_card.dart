import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';
import 'package:very_yummy_coffee_ui/src/widgets/status_badge.dart';

/// {@template order_card}
/// A card displaying order number, optional customer name, optional line
/// summaries, total, status pill, optional elapsed, and optional trailing
/// action row.
///
/// Accepts only primitive parameters to remain domain-agnostic.
/// Width is parent-constrained. When [lineSummaries] is empty, the line
/// section is hidden. When [customerName] is null or empty, the customer
/// line is omitted. When [elapsed] is null or empty, the elapsed section
/// is omitted.
/// {@endtemplate}
class OrderCard extends StatelessWidget {
  /// {@macro order_card}
  const OrderCard({
    required this.orderNumber,
    required this.totalDisplayText,
    this.orderNumberColor,
    this.statusLabel,
    this.statusBackgroundColor,
    this.statusForegroundColor,
    this.customerName,
    this.lineSummaries = const [],
    this.elapsed,
    this.elapsedWidget,
    this.trailing,
    super.key,
  });

  /// Order number (e.g. "#42").
  final String orderNumber;

  /// Optional color for order number (e.g. KDS column accent); null uses
  /// theme foreground.
  final Color? orderNumberColor;

  /// Customer name; null or empty omits the customer line.
  final String? customerName;

  /// Line summaries (e.g. "2× Espresso"); empty hides the section.
  final List<String> lineSummaries;

  /// Formatted total string (app owns locale/currency).
  final String totalDisplayText;

  /// Status pill label; null omits the status pill (e.g. KDS).
  final String? statusLabel;

  /// Status pill background color; required when [statusLabel] is non-null.
  final Color? statusBackgroundColor;

  /// Status pill foreground color; required when [statusLabel] is non-null.
  final Color? statusForegroundColor;

  /// Optional elapsed time string; null or empty omits the section.
  /// Ignored when [elapsedWidget] is non-null.
  final String? elapsed;

  /// Optional elapsed widget (e.g. live-updating KDS timer). When set,
  /// shown in the top-right instead of [elapsed] text.
  final Widget? elapsedWidget;

  /// Optional trailing widget (e.g. Cancel + Progress buttons).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final showCustomer = customerName != null && customerName!.isNotEmpty;
    final showElapsed =
        elapsedWidget != null || (elapsed != null && elapsed!.isNotEmpty);
    final showLineSection = lineSummaries.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(spacing.xl),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(radius.small),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  orderNumber,
                  style: typography.pageTitle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: orderNumberColor ?? colors.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showElapsed)
                elapsedWidget != null
                    ? DefaultTextStyle(
                        style: typography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.mutedForeground,
                        ),
                        child: elapsedWidget!,
                      )
                    : Text(
                        elapsed!,
                        style: typography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.mutedForeground,
                        ),
                      ),
            ],
          ),
          if (showCustomer)
            Padding(
              padding: EdgeInsets.only(top: spacing.xs),
              child: Text(
                customerName!,
                style: typography.body.copyWith(
                  color: colors.mutedForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (showLineSection) ...[
            SizedBox(height: spacing.md),
            ...lineSummaries.map(
              (s) => Padding(
                padding: EdgeInsets.only(bottom: spacing.xxs),
                child: Text(
                  s,
                  style: typography.caption.copyWith(
                    color: colors.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          SizedBox(height: spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalDisplayText,
                style: typography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              if (statusLabel != null &&
                  statusBackgroundColor != null &&
                  statusForegroundColor != null)
                StatusBadge(
                  label: statusLabel!,
                  backgroundColor: statusBackgroundColor!,
                  foregroundColor: statusForegroundColor!,
                ),
            ],
          ),
          if (trailing != null) ...[
            SizedBox(height: spacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}
