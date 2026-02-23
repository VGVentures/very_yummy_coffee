import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook component showcasing BaseButton variants.
final baseButtonComponent = WidgetbookComponent(
  name: 'BaseButton',
  useCases: [
    WidgetbookUseCase(
      name: 'Primary',
      builder: (context) => BaseButton(
        onPressed: () {},
        label: context.knobs.string(
          label: 'Label',
          initialValue: 'Order Coffee',
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Secondary',
      builder: (context) => BaseButton(
        onPressed: () {},
        label: context.knobs.string(
          label: 'Label',
          initialValue: 'Secondary Button',
        ),
        variant: BaseButtonVariant.secondary,
      ),
    ),
    WidgetbookUseCase(
      name: 'Cancel',
      builder: (context) => BaseButton(
        onPressed: () {},
        label: context.knobs.string(
          label: 'Label',
          initialValue: 'Cancel Button',
        ),
        variant: BaseButtonVariant.cancel,
      ),
    ),
  ],
);
