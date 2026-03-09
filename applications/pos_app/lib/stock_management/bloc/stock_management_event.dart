part of 'stock_management_bloc.dart';

@immutable
sealed class StockManagementEvent {
  const StockManagementEvent();
}

final class StockManagementSubscriptionRequested extends StockManagementEvent {
  const StockManagementSubscriptionRequested();
}

final class StockManagementItemToggled extends StockManagementEvent {
  const StockManagementItemToggled({
    required this.itemId,
    required this.available,
  });

  final String itemId;
  final bool available;
}
