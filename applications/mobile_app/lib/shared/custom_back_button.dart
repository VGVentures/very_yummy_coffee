import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: context.iconSize.tapTarget,
        height: context.iconSize.tapTarget,
        decoration: BoxDecoration(
          color: context.colors.primaryForeground.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(context.radius.medium),
        ),
        child: Icon(
          Icons.arrow_back,
          color: context.colors.primaryForeground,
          size: context.iconSize.large,
        ),
      ),
    );
  }
}
