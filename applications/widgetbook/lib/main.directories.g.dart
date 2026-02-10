// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:very_yummy_coffee_widgetbook/components/base_button.dart'
    as _very_yummy_coffee_widgetbook_components_base_button;
import 'package:very_yummy_coffee_widgetbook/components/base_card.dart'
    as _very_yummy_coffee_widgetbook_components_base_card;
import 'package:very_yummy_coffee_widgetbook/components/bottom_tab_bar.dart'
    as _very_yummy_coffee_widgetbook_components_bottom_tab_bar;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'atoms',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'BaseButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Cancel',
            builder: _very_yummy_coffee_widgetbook_components_base_button
                .baseButtonCancelUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Primary',
            builder: _very_yummy_coffee_widgetbook_components_base_button
                .baseButtonPrimaryUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Secondary',
            builder: _very_yummy_coffee_widgetbook_components_base_button
                .baseButtonSecondaryUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'BaseCard',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _very_yummy_coffee_widgetbook_components_base_card
                .baseCardUseCase,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'molecules',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'BottomTabBar',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _very_yummy_coffee_widgetbook_components_bottom_tab_bar
                .bottomTabBarDefaultUseCase,
          ),
        ],
      ),
    ],
  ),
];
