part of 'pos_orders_bloc.dart';

@immutable
sealed class PosOrdersEvent {
  const PosOrdersEvent();
}

final class PosOrdersSubscriptionRequested extends PosOrdersEvent {
  const PosOrdersSubscriptionRequested();
}
