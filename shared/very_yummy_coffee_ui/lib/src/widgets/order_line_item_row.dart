import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';
import 'package:very_yummy_coffee_ui/src/widgets/modifier_summary_chips.dart';
import 'package:very_yummy_coffee_ui/src/widgets/out_of_stock_badge.dart';

/// {@template order_line_item_row}
/// A row displaying a single order line: item name, optional modifiers,
/// optional quantity, optional price, and optional remove control.
///
/// Accepts only primitive parameters to remain domain-agnostic.
/// When both [totalCents] and [priceDisplayText] are null, price is not shown.
/// For i18n/locale, pass [priceDisplayText] (app-formatted); otherwise price is
/// derived from [totalCents] with default formatting.
/// When [onRemove] is null, no remove control is shown.
/// When [outOfStockLabel] is non-null, item is shown as out-of-stock with
/// muted name and badge.
/// {@endtemplate}
class OrderLineItemRow extends StatelessWidget {
  /// {@macro order_line_item_row}
  const OrderLineItemRow({
    required this.itemName,
    required this.quantity,
    this.modifierLabels = const [],
    this.totalCents,
    this.priceDisplayText,
    this.outOfStockLabel,
    this.onRemove,
    super.key,
  });

  /// Display name of the item.
  final String itemName;

  /// Quantity (must be >= 1 for display).
  final int quantity;

  /// Optional modifier option labels; when empty, modifier row is hidden.
  final List<String> modifierLabels;

  /// Optional total in cents; used when [priceDisplayText] is null.
  final int? totalCents;

  /// Optional pre-formatted price (e.g. locale/currency); when set, shown
  /// instead of formatting [totalCents].
  final String? priceDisplayText;

  /// When non-null, show muted name and [OutOfStockBadge] with this label.
  final String? outOfStockLabel;

  /// When non-null, show a remove control that invokes this callback.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final isOutOfStock = outOfStockLabel != null;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.sm - spacing.xxs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: typography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isOutOfStock ? colors.mutedForeground : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (modifierLabels.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.xxs),
                    child: ModifierSummaryChips(labels: modifierLabels),
                  ),
                if (isOutOfStock)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.xs),
                    child: OutOfStockBadge(label: outOfStockLabel!),
                  ),
                if (quantity > 1)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.xxs),
                    child: Text(
                      'Qty: $quantity',
                      style: typography.caption.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (priceDisplayText != null || totalCents != null) ...[
            SizedBox(width: spacing.sm),
            Text(
              priceDisplayText ?? '\$${(totalCents! / 100).toStringAsFixed(2)}',
              style: typography.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (onRemove != null) ...[
            SizedBox(width: spacing.xs),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: context.iconSize.medium,
                color: colors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
