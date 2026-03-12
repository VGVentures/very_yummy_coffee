---
title: "feat: shared menu feature"
type: feat
date: 2026-03-11
---

## feat: shared menu feature

## Overview

Create **`shared/menu_feature`** and move duplicated menu flow (menu groups + menu items) from **mobile_app** and **kiosk_app** into it: shared `MenuGroupsBloc`, `MenuItemsBloc`, and shared content widgets (`MenuGroupList`, `MenuGroupRow`, `MenuItemList`, `MenuItemGrid`, `MenuGroupCard`, `MenuItemCard`). Both apps keep their own `MenuGroupsPage` / `MenuItemsPage` (BlocProvider + routing) and headers; they compose the shared blocs and widgets. Goal: remove duplication and raise shared-code percentage (CODE_SHARING_REPORT todo #1).

**Brainstorm:** `docs/ideate/2026-03-11-shared-menu-feature-brainstorm-doc.md`

## Background and motivation

Mobile and kiosk implement nearly identical `MenuGroupsBloc` and `MenuItemsBloc` (~32 lines each) and similar views (list vs row for groups, list vs grid for items). The brainstorm chose **blocs + shared content widgets**: one unified `MenuItemsState` (`group` + `menuItems`), two widgets per layout concept (list/row for groups, list/grid for items), and shared card widgets in the package. Apps own pages, headers, routing, and l10n; shared widgets take data and callbacks only. POS and menu_board are out of scope.

## Success criteria

- [ ] **Package:** `shared/menu_feature` exists with `pubspec.yaml` depending on `menu_repository`, `very_yummy_coffee_ui`, `very_yummy_coffee_models`, `bloc`, `flutter_bloc`, `dart_mappable`, `rxdart`. No dependency on any app, `go_router`, or app l10n.
- [ ] **Blocs:** Package exports `MenuGroupsBloc`, `MenuItemsBloc` (and events/states). `MenuItemsState` has `group` (`MenuGroup?`) and `menuItems` only (no separate `groupName`). Blocs use `MenuRepository`; `MenuItemsBloc` takes `groupId` and combines `getMenuGroups()` + `getMenuItems(groupId)`.
- [ ] **Widgets:** Package exports `MenuGroupList`, `MenuGroupRow`, `MenuItemList`, `MenuItemGrid` (cards are internal). List/row/grid take data + callbacks (`onGroupTap`, `onItemTap`); apps build routes in callbacks using e.g. `item.groupId` and `item.id`. No `context.go` or `context.l10n` inside the package.
- [ ] **Mobile app:** Uses `menu_feature` for blocs and widgets. `MenuGroupsPage` / `MenuItemsPage` provide blocs and build screens with app header + `MenuGroupList` + `MenuItemList`. Routes and l10n unchanged; tap callbacks call `context.go` with app paths.
- [ ] **Kiosk app:** Same; uses `MenuGroupRow` + `MenuItemGrid` and kiosk header. Routes and l10n unchanged.
- [ ] **Loading and error:** Initial and loading states both show loading UI (app or shared content). Bloc emits failure with no message; app supplies error string and builds error UI (no shared “error widget” required).
- [ ] **Empty and invalid:** Empty groups/items show empty list (no package-provided “No groups” / “No items” copy). When `groupId` is invalid or missing, bloc may emit `group == null` and empty items; app header must handle `group == null` (e.g. fallback title). No validation inside the package; redirect or error for invalid `groupId` is app-defined.
- [ ] **Tests:** Bloc and widget tests live in `menu_feature`. Mobile and kiosk remove local menu_groups/menu_items bloc and view code; app tests (e.g. `pump_app`, router tests) provide or mock shared blocs. All tests pass.

## Technical considerations

### Package layout (follow app_shell)

- Implementation under `lib/src/` only. Public API in `lib/menu_feature.dart` (exports blocs, events, states, widgets).
- Suggested structure: `lib/src/bloc/` (menu_groups_bloc, menu_items_bloc + events/states), `lib/src/widgets/` (list, row, grid, cards). Use `part`/`part of` for bloc events and states; `dart_mappable` + build_runner for mapper generation.

### MenuItemsState unification

- Use `group` (`MenuGroup?`) and `menuItems` (`List<MenuItem>`). Kiosk currently has `groupName` in state; after migration kiosk uses `state.group?.name ?? ''` for header. Bloc logic: keep `Rx.combineLatest2(getMenuGroups(), getMenuItems(groupId))` and resolve matching `MenuGroup` by `_groupId` (same as mobile today).

### Widget API (primitives and callbacks)

- **MenuGroupList / MenuGroupRow:** `List<MenuGroup> groups`, `void Function(MenuGroup group) onGroupTap`. Use `MenuGroupCard` internally; card takes group name, description, color (primitive).
- **MenuItemList / MenuItemGrid:** `List<MenuItem> items`, `void Function(MenuItem item) onItemTap` only. Apps build routes in the callback using `item.groupId` and `item.id` (e.g. `context.go('/home/menu/${item.groupId}/${item.id}')`). Use `MenuItemCard` internally; card takes **name, price, available** only (primitives), uses `UnavailableOverlay` from `very_yummy_coffee_ui`. Add more card fields only when a concrete use case appears.
- **MenuGroupCard / MenuItemCard:** Internal only in v1 (not exported). List/row/grid use them internally. Add to public API only if an app later needs a standalone card.

### Route path constants

- Out of scope for this initiative; may add later (e.g. `MenuFeatureRoutes`) if we want consistency with `app_shell`.

### Dependency chain

- `menu_feature` → `menu_repository`, `very_yummy_coffee_ui`, `very_yummy_coffee_models`, `bloc`, `flutter_bloc`, `dart_mappable`, `rxdart`.
- `menu_repository` already exposes `MenuGroup`, `MenuItem` (from models). No new model types in `menu_feature`.

### Retry and edge cases

- No retry inside the package. On failure, apps may re-dispatch `MenuGroupsSubscriptionRequested` / `MenuItemsSubscriptionRequested` or navigate away and back. Plan does not add a shared “Retry” widget.

## Dependencies and risks

| Dependency | Notes |
|------------|------|
| `menu_repository` | Already used by both apps; no API change. |
| `very_yummy_coffee_ui` | Design tokens, `UnavailableOverlay`; no change. |
| `very_yummy_coffee_models` | Via menu_repository; types used in blocs and widget params. |
| Mobile/kiosk app_router | Continue to use `MenuGroupsPage.routeName`, `MenuItemsPage.routePathTemplate`; pages import from `menu_feature` and provide blocs. |

**Risks:** (1) Kiosk `MenuItemsBloc` currently uses a different state shape (`groupName`); migration must update kiosk views to use `state.group?.name ?? ''`. (2) App tests that depend on local menu blocs must switch to providing/mocking shared blocs; barrel files (`menu_groups.dart`, `menu_items.dart`) in apps go away.

## Implementation plan

### Phase 1: Create `shared/menu_feature` package

#### 1.1 — Package scaffold

- [ ] **New package:** `shared/menu_feature/` with `pubspec.yaml`: name `menu_feature`, dependencies `menu_repository` (path), `very_yummy_coffee_ui` (path), `very_yummy_coffee_models` (path), `bloc`, `flutter_bloc`, `dart_mappable`, `rxdart`. Dev deps: `bloc_test`, `flutter_test`, `mocktail`, `test`, `very_good_analysis`, `build_runner`.
- [ ] **Layout:** `lib/src/bloc/`, `lib/src/widgets/`. `analysis_options.yaml` with `include: package:very_good_analysis/analysis_options.yaml`.
- [ ] Run `dart run build_runner build` for mapper generation where used (bloc state/event).

#### 1.2 — MenuGroupsBloc

- [ ] **Files:** `lib/src/bloc/menu_groups_bloc.dart` (with `part` for event and state), `menu_groups_event.dart`, `menu_groups_state.dart`, `menu_groups_bloc.mapper.dart` (generated). Copy logic from `applications/mobile_app/lib/menu_groups/bloc/` (identical in kiosk).
- [ ] **API:** `MenuGroupsBloc({required MenuRepository menuRepository})`, `on<MenuGroupsSubscriptionRequested>`, `emit.forEach(_menuRepository.getMenuGroups(), ...)`. States: initial, loading, success (menuGroups), failure.
- [ ] **Tests:** `test/bloc/menu_groups_bloc_test.dart` — initial state, loading then success, loading then failure. Copy/adjust from mobile or kiosk bloc test.

#### 1.3 — MenuItemsBloc (unified state)

- [ ] **Files:** `lib/src/bloc/menu_items_bloc.dart`, `menu_items_event.dart`, `menu_items_state.dart`, `menu_items_bloc.mapper.dart` (generated). State: `group` (`MenuGroup?`), `menuItems` (no `groupName`).
- [ ] **Logic:** Same as mobile: `Rx.combineLatest2(getMenuGroups(), getMenuItems(_groupId))`, resolve `group` by matching `_groupId`, emit `status`, `group`, `menuItems`.
- [ ] **Tests:** `test/bloc/menu_items_bloc_test.dart` — initial, success with group and items, success with unknown groupId (group null), failure.

#### 1.4 — Content widgets

- [ ] **MenuGroupCard:** `lib/src/widgets/menu_group_card.dart`. Takes primitives (e.g. `name`, `description`, `color` int). Uses `context.colors`, `context.typography`, `context.radius`, `context.spacing`. No tap; parent handles tap.
- [ ] **MenuGroupList:** Takes `List<MenuGroup> groups`, `void Function(MenuGroup) onGroupTap`. Builds vertical list with `MenuGroupCard`; `GestureDetector(onTap: () => onGroupTap(group))`.
- [ ] **MenuGroupRow:** Same data/callback; builds horizontal row of `MenuGroupCard` (e.g. `Row` with `Expanded` children).
- [ ] **MenuItemCard:** Takes primitives **name, price, available** only. Wraps content in `UnavailableOverlay(isUnavailable: !available, child: ...)`. Uses theme.
- [ ] **MenuItemList:** Takes `List<MenuItem> items`, `void Function(MenuItem item) onItemTap`. Vertical list of `MenuItemCard`.
- [ ] **MenuItemGrid:** Same signature; uses `GridView.builder` with two-column grid (match kiosk).
- [ ] **Tests:** Widget tests for list/row/grid/cards. Wrap subject in `MaterialApp(theme: CoffeeTheme.light, home: ...)` (or a small helper using `very_yummy_coffee_ui`'s `CoffeeTheme`) so `context.colors`, `context.spacing`, `context.typography`, `context.radius` are available. Assert structure and callback invocation. Place under `test/widgets/`.

#### 1.5 — Public API

- [ ] **Export file:** `lib/menu_feature.dart` exports: `MenuGroupsBloc`, `MenuGroupsEvent`, `MenuGroupsState`, `MenuGroupsStatus`, `MenuItemsBloc`, `MenuItemsEvent`, `MenuItemsState`, `MenuItemsStatus`, `MenuGroupList`, `MenuGroupRow`, `MenuItemList`, `MenuItemGrid`. Cards are internal only (not exported).

#### 1.6 — CI

- [ ] Run `.github/update_github_actions.sh` after adding the package; add workflow for `menu_feature` if not auto-included. Commit workflow changes.

### Phase 2: Migrate mobile_app

- [ ] **pubspec:** Add `menu_feature: path: ../../shared/menu_feature`.
- [ ] **Replace menu implementation:** Remove existing bloc and view implementations under `lib/menu_groups/` and `lib/menu_items/`. Keep `MenuGroupsPage` / `MenuItemsPage` and their route names; rewrite them to use shared blocs and widgets. App continues to own the route wiring in `app_router.dart` (paths and page builders reference app-owned page classes).
- [ ] **MenuGroupsPage:** `BlocProvider(create: (_) => MenuGroupsBloc(menuRepository: context.read<MenuRepository>())..add(const MenuGroupsSubscriptionRequested()), child: MenuGroupsView())`. Import `MenuGroupsBloc` and `MenuGroupsView`; view lives in app (thin wrapper). **MenuGroupsView:** app header (back, title, cart) + `BlocBuilder<MenuGroupsBloc, MenuGroupsState>` with loading/error/success; success body = `MenuGroupList(groups: state.menuGroups, onGroupTap: (g) => context.go('/home/menu/${g.id}'))`. Use `context.l10n` for title and error string only.
- [ ] **MenuItemsPage:** Provide **only** `MenuItemsBloc(menuRepository, groupId: state.pathParameters['groupId']!)`; view with app header (group name = `state.group?.name ?? ''`, description = `state.group?.description`; handle `group == null`) + `MenuItemList(items: state.menuItems, onItemTap: (i) => context.go('/home/menu/${i.groupId}/${i.id}'))`.
- [ ] **Router:** No path changes; `MenuGroupsPage` and `MenuItemsPage` remain in mobile_app and are referenced by app_router as today. Blocs are provided at the Page (feature level) per existing convention.
- [ ] **Tests:** Remove `test/menu_groups/`, `test/menu_items/` bloc and view tests (covered by menu_feature tests). Update `pump_app` and router tests to provide or mock `MenuGroupsBloc` / `MenuItemsBloc` from `menu_feature` (e.g. `BlocProvider<MenuGroupsBloc>.value(...)` where needed). Optionally add a minimal widget test that menu groups page builds and shows list when state is success.

### Phase 3: Migrate kiosk_app

Same as Phase 2 (pubspec, replace local menu impl, keep pages/views, router, tests), with these differences:

- [ ] **MenuGroupsPage:** BlocProvider + view with `KioskHeader` + `BlocBuilder`; success body = `MenuGroupRow(groups: state.menuGroups, onGroupTap: (g) => context.go('/home/menu/${g.id}'))`.
- [ ] **MenuItemsPage:** Provide **only** `MenuItemsBloc` (not `MenuGroupsBloc`). View uses **`state.group?.name ?? ''`** for `KioskHeader` title and **no longer** uses `BlocSelector<MenuGroupsBloc, ...>`. Body: `MenuItemGrid(items: state.menuItems, onItemTap: (i) => context.go('/home/menu/${i.groupId}/${i.id}'))`. Handle `group == null` in header.
- [ ] **Tests:** Remove local menu_groups/menu_items tests; update pump_app and router tests to provide or mock shared blocs.

### Phase 4: Regressions and cleanup

- [ ] Run full test suite for `menu_feature`, `mobile_app`, `kiosk_app`.
- [ ] Manually verify: mobile and kiosk menu groups → items → item detail; back; loading and error states; empty list when no groups/items.
- [ ] Update **CODE_SHARING_REPORT.md**: mark todo #1 (Shared menu feature) as done and add a short completion note (e.g. “Done: shared/menu_feature created; mobile and kiosk migrated.”).

## Out of scope

- POS app menu flow; menu_board menu_display.
- Route path constants from menu_feature (optional later).
- Retry-on-failure UI inside the package.
- Shared empty-state message widget (“No groups” / “No items”); apps may add their own above the list if desired.
- Validating `groupId` against menu in the package; apps may redirect or show error for invalid ids.
