part of 'menu_display_bloc.dart';

sealed class MenuDisplayEvent {
  const MenuDisplayEvent();
}

final class MenuDisplaySubscriptionRequested extends MenuDisplayEvent {
  const MenuDisplaySubscriptionRequested();
}
