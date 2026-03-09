part of 'stock_management_bloc.dart';

enum StockManagementStatus { initial, loading, success, failure }

@MappableClass()
class StockManagementState with StockManagementStateMappable {
  const StockManagementState({
    this.status = StockManagementStatus.initial,
    this.groups = const [],
    this.items = const [],
  });

  final StockManagementStatus status;
  final List<MenuGroup> groups;
  final List<MenuItem> items;

  List<MenuItem> itemsForGroup(String groupId) =>
      items.where((i) => i.groupId == groupId).toList();
}
