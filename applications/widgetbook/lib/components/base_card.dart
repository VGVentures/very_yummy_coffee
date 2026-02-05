import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: BaseCard)
Widget baseCardUseCase(BuildContext context) {
  return BaseCard(
    padding: context.knobs.object.dropdown<BaseCardPadding>(
      label: 'Padding',
      options: BaseCardPadding.values,
      initialOption: BaseCardPadding.large,
    ),
    child: Text(
      context.knobs.string(label: 'Content', initialValue: 'This is a card.'),
    ),
  );
}
