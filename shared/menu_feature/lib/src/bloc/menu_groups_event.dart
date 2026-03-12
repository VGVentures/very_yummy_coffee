part of 'menu_groups_bloc.dart';

@MappableClass()
sealed class MenuGroupsEvent with MenuGroupsEventMappable {
  const MenuGroupsEvent();
}

@MappableClass()
class MenuGroupsSubscriptionRequested extends MenuGroupsEvent
    with MenuGroupsSubscriptionRequestedMappable {
  const MenuGroupsSubscriptionRequested();
}
