// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:very_yummy_coffee_widgetbook/components/buttons.dart'
    as _very_yummy_coffee_widgetbook_components_buttons;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'material',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'ElevatedButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Elevated Button',
            builder: _very_yummy_coffee_widgetbook_components_buttons
                .elevatedButtonUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'TextButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Text Button',
            builder: _very_yummy_coffee_widgetbook_components_buttons
                .textButtonUseCase,
          ),
        ],
      ),
    ],
  ),
];
