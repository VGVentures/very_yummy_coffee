import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook component showcasing the color palette.
final colorsComponent = WidgetbookComponent(
  name: 'Colors',
  useCases: [
    WidgetbookUseCase(
      name: 'Palette',
      builder: (context) {
        final colors = context.colors;
        return SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing.xl),
          child: Wrap(
            spacing: context.spacing.lg,
            runSpacing: context.spacing.lg,
            children: [
              _ColorSwatch(color: colors.primary, name: 'primary'),
              _ColorSwatch(color: colors.secondary, name: 'secondary'),
              _ColorSwatch(color: colors.accentGold, name: 'accentGold'),
              _ColorSwatch(color: colors.background, name: 'background'),
              _ColorSwatch(color: colors.card, name: 'card'),
              _ColorSwatch(color: colors.foreground, name: 'foreground'),
              _ColorSwatch(
                color: colors.primaryForeground,
                name: 'primaryForeground',
              ),
              _ColorSwatch(
                color: colors.mutedForeground,
                name: 'mutedForeground',
              ),
              _ColorSwatch(color: colors.border, name: 'border'),
              _ColorSwatch(color: colors.destructive, name: 'destructive'),
              _ColorSwatch(color: colors.success, name: 'success'),
              _ColorSwatch(color: colors.warning, name: 'warning'),
              _ColorSwatch(
                color: colors.navBarBackground,
                name: 'navBarBackground',
              ),
              _ColorSwatch(
                color: colors.navBarInactive,
                name: 'navBarInactive',
              ),
              _ColorSwatch(
                color: colors.imagePlaceholder,
                name: 'imagePlaceholder',
              ),
            ],
          ),
        );
      },
    ),
  ],
);

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.name});

  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(context.radius.medium),
            border: Border.all(color: context.colors.border),
          ),
        ),
        SizedBox(height: context.spacing.xs),
        Text(name, style: context.typography.caption),
      ],
    );
  }
}
