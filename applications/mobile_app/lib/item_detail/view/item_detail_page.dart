import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_mobile_app/item_detail/item_detail.dart';

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({
    required this.groupId,
    required this.itemId,
    super.key,
  });

  factory ItemDetailPage.pageBuilder(
    BuildContext _,
    GoRouterState state,
  ) => ItemDetailPage(
    key: const Key('item_detail_page'),
    groupId: state.pathParameters['groupId']!,
    itemId: state.pathParameters['itemId']!,
  );

  static const routePathTemplate = ':itemId';
  static const routeName = 'item-detail';

  final String groupId;
  final String itemId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ItemDetailBloc(
        menuRepository: context.read<MenuRepository>(),
        orderRepository: context.read<OrderRepository>(),
      )..add(ItemDetailSubscriptionRequested(groupId, itemId)),
      child: const ItemDetailView(),
    );
  }
}
