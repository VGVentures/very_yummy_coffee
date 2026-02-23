import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook component showcasing the typography scale.
final typographyComponent = WidgetbookComponent(
  name: 'Typography',
  useCases: [
    WidgetbookUseCase(
      name: 'Scale',
      builder: (context) {
        final t = context.typography;
        return SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypeSample(label: 'sectionTitle', style: t.sectionTitle),
              _TypeSample(label: 'pageTitle', style: t.pageTitle),
              _TypeSample(label: 'headline', style: t.headline),
              _TypeSample(label: 'subtitle', style: t.subtitle),
              _TypeSample(label: 'body', style: t.body),
              _TypeSample(label: 'muted', style: t.muted),
              _TypeSample(label: 'caption', style: t.caption),
              _TypeSample(label: 'small', style: t.small),
              _TypeSample(label: 'navLabel', style: t.navLabel),
              _TypeSample(label: 'navLabelActive', style: t.navLabelActive),
              _TypeSample(label: 'button', style: t.button),
            ],
          ),
        );
      },
    ),
  ],
);

class _TypeSample extends StatelessWidget {
  const _TypeSample({required this.label, required this.style});

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('The quick brown fox', style: style),
          SizedBox(height: context.spacing.xxs),
          Text(
            '$label — ${style.fontSize?.toInt()}px',
            style: context.typography.caption.copyWith(
              color: context.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
