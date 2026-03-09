import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_pos_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_pos_app/ordering/ordering.dart';
import 'package:very_yummy_coffee_pos_app/stock_management/bloc/stock_management_bloc.dart';
import 'package:very_yummy_coffee_pos_app/stock_management/view/widgets/stock_item_tile.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class StockManagementView extends StatelessWidget {
  const StockManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        const PosTopBar(showBackButton: true),
        Expanded(
          child: BlocBuilder<StockManagementBloc, StockManagementState>(
            builder: (context, state) {
              if (state.status == StockManagementStatus.initial ||
                  state.status == StockManagementStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == StockManagementStatus.failure) {
                return Center(child: Text(l10n.menuError));
              }
              return _StockList(state: state);
            },
          ),
        ),
      ],
    );
  }
}

class _StockList extends StatelessWidget {
  const _StockList({required this.state});

  final StockManagementState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: spacing.lg),
      itemCount: state.groups.length,
      itemBuilder: (context, index) {
        final group = state.groups[index];
        final groupItems = state.itemsForGroup(group.id);
        final availableCount = groupItems.where((i) => i.available).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.lg,
                vertical: spacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: typography.label.copyWith(
                        color: colors.foreground,
                      ),
                    ),
                  ),
                  Text(
                    l10n.posStockItemCount(availableCount, groupItems.length),
                    style: typography.caption.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.border),
            ...groupItems.map(
              (item) => StockItemTile(
                key: ValueKey(item.id),
                name: item.name,
                price: item.price,
                available: item.available,
                onToggled: (value) {
                  context.read<StockManagementBloc>().add(
                    StockManagementItemToggled(
                      itemId: item.id,
                      available: value,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: spacing.md),
          ],
        );
      },
    );
  }
}
