part of 'menu_items_bloc.dart';

@MappableClass()
sealed class MenuItemsEvent {
  const MenuItemsEvent();
}

@MappableClass()
class MenuItemsSubscriptionRequested extends MenuItemsEvent
    with MenuItemsSubscriptionRequestedMappable {
  const MenuItemsSubscriptionRequested();
}
