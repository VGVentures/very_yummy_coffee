# Test Quality Review: Shared Menu Feature

**Scope:** (1) `shared/menu_feature/test/` — bloc and widget tests; (2) mobile_app and kiosk_app — menu tests removed (covered by menu_feature); pump_app and router tests that touch menu.

**Date:** 2026-03-11

---

## Coverage Summary

- **Test run:** Pass (all 12 tests pass when run with `flutter test` in `shared/menu_feature`).
- **Coverage:** Bloc and list widget code are covered. From lcov: `menu_groups_bloc`, `menu_items_bloc`, `menu_group_list`, and `menu_item_list` have line hits. `menu_group_row` has **0 hits** (not exercised by any test). `MenuItemGrid`, `MenuGroupCard`, and `MenuItemCard` are only exercised indirectly via list widgets (list layout path only).
- **Files with tests:** 4 test files (2 bloc, 2 widget) for 2 blocs and 2 list widgets.
- **Missing test files:**
  - No dedicated tests for `MenuItemGrid`, `MenuGroupRow`, `MenuGroupCard`, or `MenuItemCard`. The cards are used inside `MenuGroupList` and `MenuItemList`, so list layout and basic rendering are covered indirectly; grid and row layouts are not.

**Important:** Widget tests in `menu_feature` use Flutter (Material, theme). Running with `dart test` fails (dart:ui not available on VM). Always use `flutter test` for this package.

---

## Bloc/Cubit Test Quality

### menu_groups_bloc_test.dart — **Pass**

- Uses `bloc_test` and `blocTest` for subscription flows.
- Uses `mocktail`: `_MockMenuRepository`; `when()` for `getMenuGroups()`.
- **Initial state:** Plain `test()` with `expect(bloc.state, ...)`.
- **Success path:** `blocTest` emits `[loading, success]` with groups.
- **Failure path:** `blocTest` emits `[loading, failure]` on stream error.
- **Setup:** `setUp` creates fresh `MenuRepository` mock per test.
- **Groups:** `group('MenuGroupsBloc')`, `group('MenuGroupsSubscriptionRequested')`.
- No tautological assertions; no mocking the class under test.

### menu_items_bloc_test.dart — **Pass** (minor style note)

- Uses `bloc_test` and `blocTest` for all subscription flows.
- Uses `mocktail`: `_MockMenuRepository`; `when()` for `getMenuGroups()` and `getMenuItems(...)`.
- **Initial state:** Tested with `expect(bloc.state, const MenuItemsState())`.
- **Success path:** Emits `[loading, success]` with group and items.
- **Edge case:** Unknown `groupId` — emits success with `group: null`, `menuItems: isEmpty`; `verify` block asserts final state (acceptable).
- **Failure path:** Emits `[loading, failure]` when stream throws.
- **Setup:** `setUp` and shared `testGroup` / `testItems` constants.
- **Suggestion:** `when(menuRepository.getMenuGroups)` (getter) vs `when(() => menuRepository.getMenuItems(groupId))` (closure) — both valid in mocktail; using closure form consistently improves readability.

---

## Widget Test Quality

### menu_group_list_test.dart — **Pass**

- **Ancestors:** Wraps in `MaterialApp(theme: CoffeeTheme.light)` and `Scaffold` — correct for a shared package (no app-level `pump_app` here).
- **Tests:** Renders group names; invokes `onGroupTap` when a group is tapped (with `pump()` after tap); renders when groups empty (expects `ListView`).
- **Assertions:** Meaningful (text, callback argument, widget type).
- **Empty list:** Covered.

### menu_item_list_test.dart — **Pass** (gap)

- **Ancestors:** Same as above — `MaterialApp(theme: CoffeeTheme.light)`, `Scaffold`.
- **Tests:** Renders item names and prices; invokes `onItemTap` when an item is tapped.
- **Gap:** No test for **empty items** list (e.g. `items: []`). `ListView.separated` with `itemCount: 0` is a valid edge case and should be tested.

---

## Mobile App and Kiosk App

### Menu tests removed

- Git status shows deleted menu_groups and menu_items bloc/view tests in both apps; coverage for menu logic is intended to live in `shared/menu_feature`. **Confirmed:** no `*menu_groups*` or `*menu_items*` test files remain under `applications/mobile_app/test` or `applications/kiosk_app/test`.

### pump_app

- **mobile_app** (`test/helpers/pump_app.dart`): Provides `RepositoryProvider<MenuRepository>.value(menuRepository ?? _MockMenuRepository())`, plus `AppBloc`, `OrderRepository`, `GoRouter`, `MaterialApp` with `CoffeeTheme.light` and localizations. Used by views that host menu or navigate to menu routes.
- **kiosk_app** (`test/helpers/pump_app.dart`): Same idea; includes `MenuRepository` and default mocks. Appropriate for widget tests that need menu or navigation to `/menu`.

### Router tests that touch menu

- **mobile_app:** No dedicated `app_router_test.dart`. Navigation to menu routes is exercised in:
  - `home_view_test.dart`: “tapping Start New Order navigates to /menu” (`goRouter.go('/home/menu')`).
  - `cart_view_test.dart`: back to `/home/menu`, “Browse Menu” to `/home/menu`, checkout to `/home/menu/cart/checkout`.
  - `checkout_view_test.dart`: back to `/home/menu/cart`.
  - `order_complete_view_test.dart`: “Back to Menu” to `/menu`.
- **kiosk_app:** No dedicated `app_router_test.dart`. Menu routes exercised in:
  - `home_view_test.dart`: “navigates to /home/menu on start order tap”.
  - `cart_view_test.dart`, `cart_badge_view_test.dart`, `item_detail_view_test.dart`, `checkout_view_test.dart`: various `/home/menu`, `/home/menu/cart`, `/home/menu/:groupId` assertions.

So menu routes are covered indirectly via view tests and `pump_app`; no standalone router test file for menu in either app.

---

## Anti-Patterns Found

- None critical.
- **menu_items_bloc_test.dart:** The `verify` block in the “unknown groupId” test repeats state checks already implied by `expect`. This is slightly redundant but acceptable for extra safety and is not over-verification of internal calls.

---

## Missing Coverage and Gaps

1. **MenuItemGrid** — No widget test. Used for kiosk-style grid; only indirectly exercised if an app-level test uses it.
2. **MenuGroupRow** — No widget test; lcov shows **0 line hits**. Same kiosk-oriented widget.
3. **MenuGroupCard / MenuItemCard** — No direct tests. Both have two layouts (list vs row/grid). List path is covered via list tests; row/grid and **unavailable** state (e.g. `MenuItemCard(available: false)`) are not explicitly tested.
4. **MenuItemList** — No test for `items: []` (empty list).
5. **Package test runner** — Running `dart test` in `shared/menu_feature` fails (Flutter/dart:ui required). CI or scripts must use `flutter test` for this package.

---

## Recommendations

1. **Critical:** Ensure `shared/menu_feature` is always tested with `flutter test` (not `dart test`) so widget tests run.
2. Add widget tests for **MenuItemGrid** and **MenuGroupRow** (or document that they are kiosk-only and covered by app-level tests).
3. Add a **MenuItemList** test for empty `items` (e.g. “renders without error when items empty” and/or expects no item text).
4. Optionally add a **MenuItemCard** test (or small widget test) for `available: false` and grid layout so unavailable overlay and grid path are covered.
5. Use consistent **when()** style in bloc tests (e.g. closure form `when(() => repo.method(args))`) for readability.

---

## Verdict

**All current tests pass the quality bar.** Bloc tests use `blocTest` and mocktail correctly; widget tests use MaterialApp and theme. Fix the **critical** item (use `flutter test` for menu_feature) and add the recommended widget coverage (grid, row, empty list, and optionally unavailable/grid card) for a stronger baseline.
