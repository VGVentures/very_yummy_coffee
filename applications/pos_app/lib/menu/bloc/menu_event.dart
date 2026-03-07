part of 'menu_bloc.dart';

@immutable
sealed class MenuEvent {
  const MenuEvent();
}

final class MenuSubscriptionRequested extends MenuEvent {
  const MenuSubscriptionRequested();
}

final class MenuCategorySelected extends MenuEvent {
  const MenuCategorySelected(this.groupId);

  final String? groupId;
}

final class MenuItemAdded extends MenuEvent {
  const MenuItemAdded(this.item, {this.modifiers = const []});

  final MenuItem item;
  final List<SelectedModifier> modifiers;
}
