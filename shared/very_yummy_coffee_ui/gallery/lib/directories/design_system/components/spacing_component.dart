import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook component showcasing the spacing scale.
final spacingComponent = WidgetbookComponent(
  name: 'Spacing',
  useCases: [
    WidgetbookUseCase(
      name: 'Scale',
      builder: (context) {
        final s = context.spacing;
        final tokens = <(String, double)>[
          ('xxs', s.xxs),
          ('xs', s.xs),
          ('sm', s.sm),
          ('md', s.md),
          ('lg', s.lg),
          ('xl', s.xl),
          ('xxl', s.xxl),
          ('huge', s.huge),
        ];
        return SingleChildScrollView(
          padding: EdgeInsets.all(s.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tokens
                .map((t) => _SpacingRow(name: t.$1, value: t.$2))
                .toList(),
          ),
        );
      },
    ),
  ],
);

class _SpacingRow extends StatelessWidget {
  const _SpacingRow({required this.name, required this.value});

  final String name;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(name, style: context.typography.caption),
          ),
          SizedBox(width: context.spacing.md),
          Container(
            width: value * 4,
            height: 24,
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(context.radius.medium),
            ),
          ),
          SizedBox(width: context.spacing.md),
          Text('${value.toInt()}px', style: context.typography.muted),
        ],
      ),
    );
  }
}
