import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

/// {@template menu_repository}
/// A repository managing the menu domain.
/// {@endtemplate}
class MenuRepository {
  /// {@macro menu_repository}
  const MenuRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Returns a stream of menu groups.
  Stream<List<MenuGroup>> getMenuGroups() => Stream.fromFuture(
    _apiClient.get<List<MenuGroup>>(
      '/menu/groups',
      responseFromJson: (body) {
        final list = jsonDecode(body) as List<dynamic>;
        return list
            .map((e) => MenuGroupMapper.fromMap(e as Map<String, dynamic>))
            .toList();
      },
    ),
  );

  /// Returns a stream of menu items for the given [groupId].
  Stream<List<MenuItem>> getMenuItems(String groupId) => Stream.fromFuture(
    _apiClient.get<List<MenuItem>>(
      '/menu/groups/$groupId/items',
      responseFromJson: (body) {
        final list = jsonDecode(body) as List<dynamic>;
        return list
            .map((e) => MenuItemMapper.fromMap(e as Map<String, dynamic>))
            .toList();
      },
    ),
  );
}
