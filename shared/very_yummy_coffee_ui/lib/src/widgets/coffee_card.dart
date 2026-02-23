import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/src/theme/coffee_theme.dart';

/// {@template coffee_card}
/// A generic card widget for displaying menu items and menu groups.
///
/// Provides a consistent card surface with optional leading and trailing
/// widgets, a required title, and an optional subtitle. Supports tap
/// handling and a disabled state for unavailable items.
///
/// Example usage for a menu group:
///
/// ```dart
/// CoffeeCard(
///   title: group.name,
///   subtitle: group.description,
///   trailing: ColorBox(color: group.color),
///   onTap: () => navigateToGroup(group.id),
/// );
/// ```
///
/// Example usage for a menu item:
///
/// ```dart
/// CoffeeCard(
///   title: item.name,
///   subtitle: '\$${(item.price / 100).toStringAsFixed(2)}',
///   leading: ImageThumbnail(),
///   isEnabled: item.available,
/// );
/// ```
/// {@endtemplate}
class CoffeeCard extends StatelessWidget {
  /// {@macro coffee_card}
  const CoffeeCard({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.isEnabled = true,
  });

  /// The primary label displayed in the card.
  final String title;

  /// An optional secondary label displayed below [title].
  final String? subtitle;

  /// An optional widget displayed to the left of the text content.
  final Widget? leading;

  /// An optional widget displayed to the right of the text content.
  final Widget? trailing;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Whether the card represents an enabled/available item.
  ///
  /// When `false`, the card content is rendered at reduced opacity.
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(context.radius.large),
            border: Border.all(color: context.colors.border),
          ),
          padding: EdgeInsets.all(context.spacing.xl),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: context.spacing.lg),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: context.typography.subtitle.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: context.spacing.xs),
                      Text(subtitle!, style: context.typography.muted),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: context.spacing.lg),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
