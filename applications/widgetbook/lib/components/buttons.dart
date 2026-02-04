import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Elevated Button', type: ElevatedButton)
/// Elevated Button Use Case
Widget elevatedButtonUseCase(BuildContext context) {
  return ElevatedButton(
    onPressed: () {},
    child: Text(
      context.knobs.string(label: 'Button Text', initialValue: 'Press Me'),
    ),
  );
}

@widgetbook.UseCase(name: 'Text Button', type: TextButton)
/// Text Button Use Case
Widget textButtonUseCase(BuildContext context) {
  return TextButton(
    onPressed: () {},
    child: Text(
      context.knobs.string(label: 'Button Text', initialValue: 'Press Me'),
    ),
  );
}
