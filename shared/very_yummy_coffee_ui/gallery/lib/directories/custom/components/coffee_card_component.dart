import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook component showcasing CoffeeCard variants.
final coffeeCardComponent = WidgetbookComponent(
  name: 'CoffeeCard',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: CoffeeCard(
          title: context.knobs.string(label: 'Title', initialValue: 'Espresso'),
          subtitle: context.knobs.string(
            label: 'Subtitle',
            initialValue: r'$3.50',
          ),
          onTap: () {},
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'With Leading',
      builder: (context) => Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: CoffeeCard(
          title: context.knobs.string(
            label: 'Title',
            initialValue: 'Cappuccino',
          ),
          subtitle: context.knobs.string(
            label: 'Subtitle',
            initialValue: r'$4.50',
          ),
          leading: Container(
            width: context.iconSize.imageThumbnail,
            height: context.iconSize.imageThumbnail,
            decoration: BoxDecoration(
              color: context.colors.imagePlaceholder,
              borderRadius: BorderRadius.circular(context.radius.medium),
            ),
          ),
          onTap: () {},
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Disabled',
      builder: (context) => Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: const CoffeeCard(
          title: 'Sold Out Item',
          subtitle: r'$5.00',
          isEnabled: false,
        ),
      ),
    ),
  ],
);
