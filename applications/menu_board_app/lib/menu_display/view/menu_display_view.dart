import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:very_yummy_coffee_menu_board_app/app/app.dart';
import 'package:very_yummy_coffee_menu_board_app/l10n/l10n.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/bloc/menu_display_bloc.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/widgets/featured_item_panel.dart';
import 'package:very_yummy_coffee_menu_board_app/menu_display/view/widgets/menu_column.dart';
import 'package:very_yummy_coffee_menu_board_app/order_status/order_status.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';

class MenuDisplayView extends StatelessWidget {
  const MenuDisplayView({super.key});

  static const double _featuredPanelWidth = 320;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BlocBuilder<AppBloc, AppState>(
            builder: (context, appState) => AppTopBar(
              title: context.l10n.appTitle,
              isConnected: appState.status == AppStatus.connected,
            ),
          ),
          Expanded(
            child: BlocBuilder<MenuDisplayBloc, MenuDisplayState>(
              builder: (context, state) {
                if (state.status == MenuDisplayStatus.loading ||
                    state.status == MenuDisplayStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == MenuDisplayStatus.failure) {
                  return Center(
                    child: Text(
                      context.l10n.failedToLoadMenu,
                      style: context.typography.body.copyWith(
                        color: context.colors.mutedForeground,
                      ),
                    ),
                  );
                }

                return Row(
                  children: [
                    if (state.groups.isNotEmpty)
                      SizedBox(
                        width: _featuredPanelWidth,
                        child: FeaturedItemPanel(
                          group: state.groups.first,
                          item: state.featuredLeft,
                        ),
                      ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MenuColumn(
                              groupEntries: state.leftGroupEntries,
                            ),
                          ),
                          Expanded(
                            child: MenuColumn(
                              groupEntries: state.rightGroupEntries,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.groups.isNotEmpty)
                      SizedBox(
                        width: _featuredPanelWidth,
                        child: _RightPanel(
                          lastGroup: state.groups.last,
                          featuredRight: state.featuredRight,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({
    required this.lastGroup,
    required this.featuredRight,
  });

  final MenuGroup lastGroup;
  final MenuItem? featuredRight;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderStatusBloc, OrderStatusState>(
      builder: (context, orderState) {
        final hasOrders =
            orderState.inProgressOrders.isNotEmpty ||
            orderState.readyOrders.isNotEmpty;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: hasOrders
              ? const OrderStatusPanel(
                  key: ValueKey('order_status'),
                )
              : FeaturedItemPanel(
                  key: const ValueKey('featured'),
                  group: lastGroup,
                  item: featuredRight,
                ),
        );
      },
    );
  }
}
