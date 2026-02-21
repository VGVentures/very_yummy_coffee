import 'dart:async';
import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

/// Internal cache holding the full menu fetched from the server.
class _MenuCache {
  const _MenuCache({required this.groups, required this.items});

  final List<MenuGroup> groups;
  final List<MenuItem> items;

  List<MenuItem> itemsForGroup(String groupId) =>
      items.where((i) => i.groupId == groupId).toList();
}

/// {@template menu_repository}
/// A repository managing the menu domain.
///
/// On first subscription, fetches the current menu via HTTP then subscribes
/// to live updates over WebSocket. Multiple callers share a single WS
/// subscription — when the last listener unsubscribes, the WS subscription
/// is torn down automatically.
/// {@endtemplate}
class MenuRepository {
  /// {@macro menu_repository}
  MenuRepository({
    required ApiClient apiClient,
    required WsRpcClient wsRpcClient,
  }) : _apiClient = apiClient,
       _wsRpcClient = wsRpcClient;

  final ApiClient _apiClient;
  final WsRpcClient _wsRpcClient;

  BehaviorSubject<_MenuCache>? _menuSubject;
  int _menuListenerCount = 0;
  StreamSubscription<Map<String, dynamic>>? _menuWsSub;

  /// Returns a live stream of menu groups.
  ///
  /// The first subscriber triggers an HTTP fetch for initial data and starts
  /// a WebSocket subscription. Subsequent subscribers share the same
  /// connection. When all subscribers cancel, the WebSocket subscription is
  /// closed.
  Stream<List<MenuGroup>> getMenuGroups() => Rx.defer(() {
    _initMenuIfNeeded();
    _menuListenerCount++;
    return _menuSubject!.stream
        .map((cache) => cache.groups)
        .doOnCancel(_decrementMenuCount);
  });

  /// Returns a live stream of menu items for [groupId].
  ///
  /// Shares the same underlying WebSocket subscription as [getMenuGroups].
  Stream<List<MenuItem>> getMenuItems(String groupId) => Rx.defer(() {
    _initMenuIfNeeded();
    _menuListenerCount++;
    return _menuSubject!.stream
        .map((cache) => cache.itemsForGroup(groupId))
        .doOnCancel(_decrementMenuCount);
  });

  void _initMenuIfNeeded() {
    if (_menuSubject != null) return;

    _menuSubject = BehaviorSubject<_MenuCache>();

    // Fetch initial menu data concurrently via HTTP.
    unawaited(
      Future.wait([
            _apiClient.get<List<MenuGroup>>(
              '/menu/groups',
              responseFromJson: (body) {
                final list = jsonDecode(body) as List<dynamic>;
                return list
                    .map(
                      (e) => MenuGroupMapper.fromMap(e as Map<String, dynamic>),
                    )
                    .toList();
              },
            ),
            _apiClient.get<List<MenuItem>>(
              '/menu/items',
              responseFromJson: (body) {
                final list = jsonDecode(body) as List<dynamic>;
                return list
                    .map(
                      (e) => MenuItemMapper.fromMap(e as Map<String, dynamic>),
                    )
                    .toList();
              },
            ),
          ])
          .then((results) {
            _menuSubject?.add(
              _MenuCache(
                groups: results[0] as List<MenuGroup>,
                items: results[1] as List<MenuItem>,
              ),
            );
          })
          .catchError((_) {}),
    );

    // Subscribe to live WebSocket updates for the 'menu' topic.
    _menuWsSub = _wsRpcClient.subscribe('menu').listen((payload) {
      final groupList = payload['groups'] as List<dynamic>?;
      final itemList = payload['items'] as List<dynamic>?;
      if (groupList == null || itemList == null) return;

      _menuSubject?.add(
        _MenuCache(
          groups: groupList
              .map((e) => MenuGroupMapper.fromMap(e as Map<String, dynamic>))
              .toList(),
          items: itemList
              .map((e) => MenuItemMapper.fromMap(e as Map<String, dynamic>))
              .toList(),
        ),
      );
    });
  }

  void _decrementMenuCount() {
    _menuListenerCount--;
    if (_menuListenerCount == 0) {
      _wsRpcClient.unsubscribe('menu');
      unawaited(_menuWsSub?.cancel());
      _menuWsSub = null;
      unawaited(_menuSubject?.close());
      _menuSubject = null;
    }
  }
}
