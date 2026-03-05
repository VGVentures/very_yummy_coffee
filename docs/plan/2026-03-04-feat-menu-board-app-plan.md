---
date: 2026-03-04
type: feat
status: reviewed
branch: feat/menu-board-app
---

# ✨ feat: menu board app

A new Flutter macOS application — `applications/menu_board_app` — that displays the live coffee shop menu on a 1920×1080 landscape screen. Read-only; no user interaction required.

---

## Acceptance Criteria

- [ ] App boots and shows a `ConnectingPage` until the WebSocket is established
- [ ] On successful connection, router automatically navigates to `/menu-display`
- [ ] On disconnection, router redirects to `/connecting`
- [ ] `MenuDisplayBloc` subscribes to `MenuRepository.getMenuGroupsAndItems()` via `emit.forEach`
- [ ] `MenuDisplayView` renders a three-panel layout: `FeaturedItemPanel` left, menu columns center, `FeaturedItemPanel` right
- [ ] Menu columns display all menu groups and their **available** items only (unavailable items and empty group headers are hidden)
- [ ] Left featured panel shows the first available item from `groups.first` (when groups is non-empty); right panel shows the first available item from `groups.last`
- [ ] If a featured group has no available items, that panel shows a styled placeholder
- [ ] All colors, spacing, radius, and typography use design tokens via `context.colors`, `context.spacing`, `context.radius`, `context.typography`
- [ ] `AppTopBar` shared widget is used for the header (connection dot + "Very Yummy Coffee" title)
- [ ] Connection status dot in `AppTopBar` reflects live `AppBloc` state
- [ ] App runs as a macOS desktop Flutter app
- [ ] `pubspec.yaml` and `analysis_options.yaml` follow the KDS app template
- [ ] GitHub Actions workflows are regenerated after `pubspec.yaml` is created
- [ ] Widget tests use the `pumpApp` helper, `blocTest`, and `mocktail`

---

## Background & Motivation

The coffee shop has a lobby screen that currently shows a static menu. The POS and KDS apps already drive real-time availability changes over WebSocket — when a barista marks an item as unavailable on the POS, the KDS picks it up instantly. The menu board app closes the loop: customers see the same live availability on the in-store display without staff needing to manually update a static sign.

The design lives in `design.pen`, frame `eTi3R`. It shows the familiar Very Yummy Coffee branding and a three-panel layout that maximizes use of a widescreen display.

---

## Technical Approach

### Architecture

Mirrors the KDS app (`applications/kds_app`) exactly. No novel patterns needed.

```
applications/menu_board_app/
├── lib/
│   ├── main.dart                           # Init ApiClient, WsRpcClient, repos
│   ├── app/
│   │   ├── app.dart                        # barrel
│   │   ├── bloc/
│   │   │   ├── app_bloc.dart               # AppBloc: wraps ConnectionRepository.isConnected
│   │   │   ├── app_event.dart              # AppStarted
│   │   │   └── app_state.dart              # AppStatus.initial / connected / disconnected
│   │   ├── app_router/
│   │   │   └── app_router.dart             # GoRouter: /connecting ↔ /menu-display
│   │   └── view/
│   │       ├── app.dart                    # App + _AppView (MaterialApp.router)
│   │       ├── connecting_page.dart        # Spinner shown before WS connects
│   │       └── view.dart                   # barrel
│   └── menu_display/
│       ├── menu_display.dart               # barrel
│       ├── bloc/
│       │   ├── menu_display_bloc.dart      # MenuDisplayBloc
│       │   ├── menu_display_event.dart     # MenuDisplaySubscriptionRequested
│       │   └── menu_display_state.dart     # MenuDisplayState + MenuDisplayStatus
│       └── view/
│           ├── menu_display_page.dart      # BlocProvider + MenuDisplayBloc
│           ├── menu_display_view.dart      # Three-panel layout
│           └── widgets/
│               ├── featured_item_panel.dart
│               └── menu_column.dart
├── test/
│   ├── helpers/
│   │   ├── go_router.dart                  # MockGoRouter, MockGoRouterProvider
│   │   ├── helpers.dart                    # barrel: exports go_router.dart, pump_app.dart
│   │   └── pump_app.dart                   # accepts MenuRepository? menuRepository
│   ├── app/
│   │   └── bloc/
│   │       └── app_bloc_test.dart
│   └── menu_display/
│       ├── bloc/
│       │   └── menu_display_bloc_test.dart
│       └── view/
│           ├── menu_display_page_test.dart
│           └── menu_display_view_test.dart
├── pubspec.yaml
├── analysis_options.yaml
└── .gitignore
```

Note: No `l10n.yaml` — the one user-visible string ("Connecting...") is hardcoded in `ConnectingPage`. This is the simpler path for a read-only display app with no localization requirement.

### State Model

```dart
// menu_display_state.dart
enum MenuDisplayStatus { initial, loading, success, failure }

@MappableClass()
class MenuDisplayState with MenuDisplayStateMappable {
  const MenuDisplayState({
    this.status = MenuDisplayStatus.initial,
    this.groups = const [],
    this.items = const [],
  });

  final MenuDisplayStatus status;
  final List<MenuGroup> groups;
  final List<MenuItem> items;   // all items; view filters by groupId + available
}
```

The view computes derived data (always guarding for empty groups):
- `featuredLeft`: `groups.isNotEmpty ? items.where((i) => i.groupId == groups.first.id && i.available).firstOrNull : null`
- `featuredRight`: `groups.isNotEmpty ? items.where((i) => i.groupId == groups.last.id && i.available).firstOrNull : null`
- Per-group items for center columns: `items.where((i) => i.groupId == g.id && i.available).toList()`

### Bloc

```dart
// menu_display_bloc.dart
class MenuDisplayBloc extends Bloc<MenuDisplayEvent, MenuDisplayState> {
  MenuDisplayBloc({required MenuRepository menuRepository}) : ... {
    on<MenuDisplaySubscriptionRequested>(_onSubscriptionRequested);
  }

  Future<void> _onSubscriptionRequested(...) async {
    emit(state.copyWith(status: MenuDisplayStatus.loading));
    await emit.forEach(
      _menuRepository.getMenuGroupsAndItems(),
      onData: (data) => state.copyWith(
        status: MenuDisplayStatus.success,
        groups: data.groups,
        items: data.items,
      ),
      onError: (_, _) => state.copyWith(status: MenuDisplayStatus.failure),
    );
  }
}
```

### Router

```dart
// app_router.dart — same pattern as kds_app
redirect: (context, state) {
  final status = context.read<AppBloc>().state.status;
  final onConnecting = state.uri.path == ConnectingPage.routeName;
  if (status != AppStatus.connected && !onConnecting) return ConnectingPage.routeName;
  if (status == AppStatus.connected && onConnecting) return MenuDisplayPage.routeName;
  return null;
},
routes: [
  GoRoute(path: '/connecting', pageBuilder: ...),
  GoRoute(path: '/menu-display', pageBuilder: ...),
]
```

### Layout

```
┌──────────────────────────────────────────────────────────────────────┐
│  AppTopBar  (●connected · "Very Yummy Coffee")                        │
├─────────────────┬──────────────────────────┬─────────────────────────┤
│ FeaturedItem    │  Col A          Col B     │  FeaturedItem           │
│ (groups.first)  │  groups[0..n/2] groups[n/2..n-1] │  (groups.last)  │
└─────────────────┴──────────────────────────┴─────────────────────────┘
```

**`FeaturedItemPanel`** accepts `group` (`MenuGroup`) and `item` (`MenuItem?`):
- Circular image: uses `MenuGroup.imageUrl` (nullable) — shows `imagePlaceholder`-colored circle when null. **`MenuItem` has no image field.**
- Displays: `MenuGroup.name` as panel header, `MenuItem.name`, price as `$X.XX`
- `MenuItem` has no `description` field — do not render one. Fields: `id`, `name`, `price`, `groupId`, `available` only.
- When `item` is `null` (no available item in the group), shows a styled placeholder with the group name.

**`MenuColumn`**: accepts a list of `(MenuGroup, List<MenuItem>)` pairs. Renders group headers followed by available item rows (name + price). Groups with zero available items are omitted entirely. Uses a non-scrolling `Column` — current fixture (3 groups × ~2 items) fits the screen. Overflow clips; acceptable for now.

Center panel splits groups roughly in half across two `Expanded` `Column` widgets.

### `pubspec.yaml` (key deps)

```yaml
name: very_yummy_coffee_menu_board_app
description: "Very Yummy Coffee Menu Board App"
publish_to: "none"
version: 0.1.0

environment:
  sdk: ^3.11.0
  flutter: ^3.41.2

dependencies:
  api_client:
    path: ../../shared/api_client
  bloc: ^9.0.0
  connection_repository:
    path: ../../shared/connection_repository
  dart_mappable: ^4.6.1
  flutter:
    sdk: flutter
  flutter_bloc: ^9.1.1
  go_router: ^14.6.2
  menu_repository:
    path: ../../shared/menu_repository
  very_yummy_coffee_ui:
    path: ../../shared/very_yummy_coffee_ui

dev_dependencies:
  bloc_lint: ^0.3.6
  bloc_test: ^10.0.0
  build_runner: ^2.11.1
  dart_mappable_builder: ^4.6.4
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  nested: ^1.0.0
  very_good_analysis: ^10.0.0

flutter:
  uses-material-design: true
```

Note: No `order_repository`, `intl`, `flutter_localizations`, `meta`, or `generate: true` — YAGNI for this read-only display with no l10n.

### `analysis_options.yaml`

```yaml
include:
  - package:bloc_lint/recommended.yaml
  - package:very_good_analysis/analysis_options.yaml

linter:
  rules:
    public_member_api_docs: false
```

### `ConnectingPage` adaptation

Do **not** copy the KDS `ConnectingPage` verbatim. Adapt it to:
- Hardcode `'Connecting...'` as a string literal (no `context.l10n` — no l10n in this app)
- Replace any `SizedBox(height: 16)` with `SizedBox(height: context.spacing.lg)` to comply with design token rules

### `pumpApp` helper signature

```dart
// test/helpers/pump_app.dart
extension AppTester on WidgetTester {
  Future<void> pumpApp(
    Widget widgetUnderTest, {
    AppBloc? appBloc,
    GoRouter? goRouter,
    MenuRepository? menuRepository,
  }) async { ... }
}
```

### Widget test viewport

Widget tests for `MenuDisplayView` must set a widescreen viewport to match the target display:

```dart
setUp(() {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
});
```

---

## Edge Cases & Design Decisions

| Scenario | Decision |
|---|---|
| Server sends empty groups | Show empty center; both featured panels render placeholder |
| Featured group has 0 available items | `FeaturedItemPanel` receives `null` item → styled placeholder (group name), three-panel proportions maintained |
| All items in a group unavailable | Hide the group header entirely from center columns — empty headers look broken on a customer display |
| WebSocket disconnects mid-display | `AppBloc` emits `disconnected` → GoRouter redirects to `ConnectingPage` |
| Reconnect after disconnect | `MenuDisplayPage` is destroyed on disconnect and rebuilt fresh on reconnect; `MenuRepository` subscription re-established correctly |
| Loading state (post-connect, pre-snapshot) | `MenuDisplayStatus.loading` → centered `CircularProgressIndicator` in `MenuDisplayView` |
| Only one group exists | Left and right featured panels both show the same item — acceptable, document as known edge case |
| `MenuItem` has no image field | Use `MenuGroup.imageUrl` (nullable) for circular image; `imagePlaceholder`-colored circle when null |
| Price formatting | `'$${(item.price / 100).toStringAsFixed(2)}'` — hardcoded `$` + US format |
| Center column overflow | Non-scrolling `Column`; current fixture fits easily |

---

## Test Coverage Plan

**`menu_display_bloc_test.dart`:**
- emits `[loading]` on `MenuDisplaySubscriptionRequested` (before first stream value)
- emits `[loading, success]` with correct groups/items on stream data
- emits `[loading, failure]` on stream error

**`menu_display_view_test.dart`** (with 1920×1080 viewport):
- renders `CircularProgressIndicator` when `status == loading`
- renders three-panel layout when `status == success` with data
- renders without crash when groups is empty (`status == success`, `groups: []`)
- featured panels receive correct items from first/last groups

**`menu_display_page_test.dart`:**
- provides `MenuDisplayBloc` and dispatches `MenuDisplaySubscriptionRequested`

---

## Dependencies & Risks

- **macOS entitlements**: Network access requires `com.apple.security.network.client` entitlement in `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`. Needed for WebSocket to `localhost` / production server.
- **GitHub Actions**: After creating `pubspec.yaml`, run `.github/update_github_actions.sh` and commit the result, or the `Verify Github Actions` CI check will fail.
- **Window size**: No `window_manager` dependency — macOS kiosk handles fullscreen. Set initial window dimensions in `AppDelegate.swift` if needed for development ergonomics; not required to unblock implementation.

---

## Implementation Order

1. **Scaffold the package**: `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `main.dart`
2. **Regenerate GitHub Actions**: `.github/update_github_actions.sh`
3. **App layer**: `AppBloc` (adapt from KDS — copy verbatim), `AppRouter`, `ConnectingPage` (adapt from KDS), `App`/`_AppView`
4. **MenuDisplay bloc**: `MenuDisplayEvent`, `MenuDisplayState` (with `initial` status), `MenuDisplayBloc`
5. **Run build_runner**: generate `.mapper.dart` files
6. **MenuDisplay view**: `MenuDisplayPage`, `MenuDisplayView`, `FeaturedItemPanel`, `MenuColumn`
7. **Tests**: test helpers (`go_router.dart`, `helpers.dart`, `pump_app.dart`), bloc tests, widget tests
8. **Smoke test on macOS**: `flutter run -d macos`; verify live updates from POS app

---

## Files to Create

| File | Notes |
|---|---|
| `applications/menu_board_app/pubspec.yaml` | |
| `applications/menu_board_app/analysis_options.yaml` | |
| `applications/menu_board_app/.gitignore` | Copy from `kds_app/.gitignore` |
| `applications/menu_board_app/lib/main.dart` | Init ApiClient, WsRpcClient, MenuRepository, ConnectionRepository |
| `applications/menu_board_app/lib/app/app.dart` | barrel |
| `applications/menu_board_app/lib/app/bloc/app_bloc.dart` | Copy from KDS verbatim |
| `applications/menu_board_app/lib/app/bloc/app_event.dart` | Copy from KDS verbatim |
| `applications/menu_board_app/lib/app/bloc/app_state.dart` | Copy from KDS verbatim |
| `applications/menu_board_app/lib/app/app_router/app_router.dart` | Adapt from KDS; target route is `/menu-display` |
| `applications/menu_board_app/lib/app/view/app.dart` | Adapt from KDS; no l10n delegates |
| `applications/menu_board_app/lib/app/view/connecting_page.dart` | Adapt from KDS; hardcode string, fix spacing token |
| `applications/menu_board_app/lib/app/view/view.dart` | barrel |
| `applications/menu_board_app/lib/menu_display/menu_display.dart` | barrel |
| `applications/menu_board_app/lib/menu_display/bloc/menu_display_bloc.dart` | |
| `applications/menu_board_app/lib/menu_display/bloc/menu_display_event.dart` | |
| `applications/menu_board_app/lib/menu_display/bloc/menu_display_state.dart` | `enum MenuDisplayStatus { initial, loading, success, failure }` |
| `applications/menu_board_app/lib/menu_display/view/menu_display_page.dart` | |
| `applications/menu_board_app/lib/menu_display/view/menu_display_view.dart` | |
| `applications/menu_board_app/lib/menu_display/view/widgets/featured_item_panel.dart` | Accepts `MenuGroup` + `MenuItem?` |
| `applications/menu_board_app/lib/menu_display/view/widgets/menu_column.dart` | |
| `applications/menu_board_app/test/helpers/go_router.dart` | `MockGoRouter`, `MockGoRouterProvider` |
| `applications/menu_board_app/test/helpers/helpers.dart` | barrel: exports `go_router.dart`, `pump_app.dart` |
| `applications/menu_board_app/test/helpers/pump_app.dart` | Accepts `MenuRepository? menuRepository` |
| `applications/menu_board_app/test/app/bloc/app_bloc_test.dart` | |
| `applications/menu_board_app/test/menu_display/bloc/menu_display_bloc_test.dart` | |
| `applications/menu_board_app/test/menu_display/view/menu_display_page_test.dart` | |
| `applications/menu_board_app/test/menu_display/view/menu_display_view_test.dart` | Set 1920×1080 viewport |

---

## References

- Brainstorm: [docs/ideate/2026-03-04-menu-board-app-brainstorm-doc.md](../ideate/2026-03-04-menu-board-app-brainstorm-doc.md)
- KDS template: [applications/kds_app/](../../applications/kds_app/)
- `MenuRepository.getMenuGroupsAndItems()`: [shared/menu_repository/lib/src/menu_repository.dart](../../shared/menu_repository/lib/src/menu_repository.dart)
- Shared `AppTopBar`: `shared/very_yummy_coffee_ui/lib/src/widgets/app_top_bar.dart`
- Design tokens: [shared/very_yummy_coffee_ui/lib/src/theme/coffee_theme.dart](../../shared/very_yummy_coffee_ui/lib/src/theme/coffee_theme.dart)
