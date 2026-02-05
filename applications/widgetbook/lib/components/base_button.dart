import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Primary', type: BaseButton)
Widget baseButtonPrimaryUseCase(BuildContext context) {
  return BaseButton(
    onPressed: () {},
    label: context.knobs.string(label: 'Label', initialValue: 'Order Coffee'),
  );
}

@widgetbook.UseCase(name: 'Secondary', type: BaseButton)
Widget baseButtonSecondaryUseCase(BuildContext context) {
  return BaseButton(
    onPressed: () {},
    label: context.knobs.string(
      label: 'Label',
      initialValue: 'Secondary Button',
    ),
    variant: BaseButtonVariant.secondary,
  );
}

@widgetbook.UseCase(name: 'Cancel', type: BaseButton)
Widget baseButtonCancelUseCase(BuildContext context) {
  return BaseButton(
    onPressed: () {},
    label: context.knobs.string(label: 'Label', initialValue: 'Cancel Button'),
    variant: BaseButtonVariant.cancel,
  );
}
