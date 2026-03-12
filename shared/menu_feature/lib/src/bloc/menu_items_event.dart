part of 'menu_items_bloc.dart';

@MappableClass()
sealed class MenuItemsEvent with MenuItemsEventMappable {
  const MenuItemsEvent();
}

@MappableClass()
class MenuItemsSubscriptionRequested extends MenuItemsEvent
    with MenuItemsSubscriptionRequestedMappable {
  const MenuItemsSubscriptionRequested();
}
