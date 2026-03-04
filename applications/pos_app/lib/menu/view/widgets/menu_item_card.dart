import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/menu/bloc/menu_bloc.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({required this.item, super.key});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.read<MenuBloc>().add(MenuItemAdded(item)),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    '\$${(item.price / 100).toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.available)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Text(
                      l10n.menuItemUnavailable,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
