import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook component showcasing CustomBackButton.
final customBackButtonComponent = WidgetbookComponent(
  name: 'CustomBackButton',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => ColoredBox(
        color: context.colors.primary,
        child: Center(child: CustomBackButton(onPressed: () {})),
      ),
    ),
  ],
);
