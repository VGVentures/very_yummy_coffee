---
date: 2026-03-04
type: review
plan: 2026-03-04-feat-menu-board-app-plan.md
reviewer: VGV Review Agent
---

# VGV Code Review — Menu Board App Plan

## Summary

The plan is well-structured and closely mirrors the KDS app reference implementation. It correctly identifies the right architecture (Bloc over stream, `emit.forEach`, GoRouter redirect), the right shared infrastructure (`AppTopBar`, design tokens, `pumpApp` helper), and the right scope (read-only, no order dependency). The vast majority of decisions are sound. There are no critical architectural errors, but there are five issues that require resolution before implementation begins: one critical omission (missing `helpers.dart` barrel file), one critical model shape discrepancy (`description` field incorrectly attributed to `MenuItem`), and three important gaps around l10n, the `ConnectingPage` raw SizedBox, and missing test coverage for widget viewport setup. The plan will produce correct, mergeable code once these are addressed.

---

## Critical — Must Fix Before Implementation

### 1. Missing `test/helpers/helpers.dart` barrel file

The plan lists `test/helpers/pump_app.dart` as the only helper file but the KDS reference has three helper files:
- `test/helpers/pump_app.dart`
- `test/helpers/go_router.dart` — `MockGoRouter` + `MockGoRouterProvider`
- `test/helpers/helpers.dart` — barrel that re-exports all three

The `pumpApp` helper in `pump_app.dart` depends on `MockGoRouterProvider` from `go_router.dart`. Widget tests import `helpers.dart` as their single import. If `go_router.dart` and `helpers.dart` are missing, every widget test either fails to compile or requires individual helper imports. The KDS `kds_page_test.dart` and `kds_view_test.dart` both use `import '../../helpers/helpers.dart'` exclusively.

**Fix:** Add to the Files to Create table:
```
applications/menu_board_app/test/helpers/go_router.dart   — MockGoRouter, MockGoRouterProvider
applications/menu_board_app/test/helpers/helpers.dart      — barrel: exports go_router.dart, pump_app.dart
```

The `pumpApp` signature in `pump_app.dart` also needs `MenuRepository` instead of `OrderRepository` as its named repository parameter, consistent with what the menu board app actually provides.

---

### 2. `FeaturedItemPanel` `description` field does not exist on `MenuItem`

The plan states:

> `FeaturedItemPanel`: circular image placeholder, item name, description (if available on the model), price formatted as `$X.XX`.

And the Dependencies & Risks section says:

> The brainstorm references a "description" field in the featured panel. Verify `MenuItem` in `shared/very_yummy_coffee_models` has a `description` field before building `FeaturedItemPanel`. If not, display name + price only.

The actual `MenuItem` model (`shared/very_yummy_coffee_models/lib/src/models/menu_item.dart`) has exactly these fields:

```dart
final String id;
final String name;
final int price;
final String groupId;
final bool available;
```

There is no `description` field. `MenuGroup` has `description` and `imageUrl`, but `MenuItem` does not. The plan correctly calls this out as a risk to verify, but leaves it open. This must be resolved in the plan itself — not deferred to implementation — because it directly affects the `FeaturedItemPanel` widget contract and its tests.

**Fix:** Update the plan to state definitively:

> `FeaturedItemPanel` displays `MenuGroup.name` (group name as panel header), `MenuItem.name`, and the formatted price. No `description` field exists on `MenuItem`. The circular image uses `MenuGroup.imageUrl` (nullable), falling back to an `imagePlaceholder`-colored circle. `FeaturedItemPanel` accepts `group` (`MenuGroup`) and `item` (`MenuItem?`), not just `item`.

This also has a downstream effect on the state model: the view needs both `groups` and `items` to render `FeaturedItemPanel`, which the plan already handles correctly. But the widget signature must be explicitly documented.

---

## Important — Should Fix

### 3. l10n decision is under-specified for the `ConnectingPage` copy

The plan marks `l10n.yaml` as "optional — skip if no user-facing strings". The `ConnectingPage` it proposes to reuse verbatim from KDS uses `context.l10n.connecting` — a localized string. If l10n is skipped, `ConnectingPage` either cannot be used as-is, or must hardcode the "Connecting…" string as a raw string literal, which violates the KDS pattern and introduces a maintenance split.

The KDS `ConnectingPage` is not a standalone widget — it uses `context.l10n`, which requires the `AppLocalizations` delegate to be registered in `MaterialApp.router`. The menu board `_AppView` must either:
1. Set up l10n with `l10n.yaml` + `app_en.arb` (two strings minimum: `connecting` and `appTitle`), or
2. Not reuse `ConnectingPage` verbatim and instead use a hardcoded string (acceptable but deviates from pattern).

**Fix:** Remove the ambiguity. The simplest path that stays consistent with the KDS pattern is to create `l10n.yaml` with a minimal `app_en.arb` (at minimum `connecting` and `appTitle`). Update the plan to mark l10n as required, and add `l10n.yaml`, `lib/l10n/arb/app_en.arb`, `lib/l10n/arb/app_localizations.dart` (generated), and `lib/l10n/l10n.dart` to the Files to Create table.

---

### 4. `pumpApp` helper needs `MenuRepository` parameter, not `OrderRepository`

The plan says "Widget tests use the `pumpApp` helper" and lists `test/helpers/pump_app.dart` as a file to create. The KDS `pumpApp` provides `OrderRepository` as its named repository parameter because the KDS app needs it. The menu board app needs `MenuRepository` in its `MultiRepositoryProvider`.

If the plan's implementor copies the KDS `pump_app.dart` without updating the repository type, every widget test that relies on `MenuDisplayPage` (which reads `MenuRepository` from context) will fail with a `ProviderNotFoundException` at runtime.

**Fix:** Explicitly state in the plan that `pump_app.dart` accepts `MenuRepository? menuRepository` as its named parameter and provides it via `RepositoryProvider<MenuRepository>`. Include a code snippet showing the correct signature:

```dart
extension AppTester on WidgetTester {
  Future<void> pumpApp(
    Widget widgetUnderTest, {
    AppBloc? appBloc,
    GoRouter? goRouter,
    MenuRepository? menuRepository,
  }) async { ... }
}
```

---

### 5. `MenuDisplayState` uses `@MappableClass()` but state-only serialization is unnecessary overhead

The plan uses `dart_mappable` with `@MappableClass()` on `MenuDisplayState`. The KDS `KdsState` does the same and it is the established pattern in this codebase, so this is not a violation per se. However, Bloc states in this project only need `dart_mappable` if they are serialized across a network or storage boundary. `MenuDisplayState` is never serialized — it is purely in-memory Bloc state. The `copyWith` from `dart_mappable` is used for state mutation, but a hand-written `copyWith` would serve identically with no code generation step.

The KDS app uses `@MappableClass()` on `KdsState` as an established pattern, and consistency with that pattern is the stronger argument here. Flag this for awareness but do not require a change.

**Suggestion:** Consider whether the project-wide convention to use `dart_mappable` on Bloc states is intentional (for `==`/`hashCode` generation, which `blocTest` depends on) or accidental. If it is intentional, document it in `CLAUDE.md`. `dart_mappable` generates `==` and `hashCode` in addition to `copyWith`, which is the real value for Bloc states.

---

### 6. Router redirect has a subtle asymmetry with `AppStatus.initial`

The plan's redirect logic:

```dart
if (status != AppStatus.connected && !onConnecting) return ConnectingPage.routeName;
if (status == AppStatus.connected && onConnecting) return MenuDisplayPage.routeName;
return null;
```

This exactly mirrors the KDS `app_router.dart`, which is correct. The KDS `AppState` has three statuses: `initial`, `connected`, `disconnected`. On `initial` (before the first WS message), `status != AppStatus.connected` is true, so the user lands on `ConnectingPage`. This is correct behavior. No change needed — calling it out as confirmed-correct for reviewer awareness.

---

### 7. `MenuDisplayStatus` is missing the `initial` enum value

The KDS `KdsStatus` enum is: `initial, loading, success, failure`. The plan's `MenuDisplayStatus` is: `loading, success, failure`. The `initial` value exists in KDS and is used in the initial state constructor default. Its absence from the plan is a deviation. More importantly, `blocTest` for initial-state assertions will fail if the initial state has `status: MenuDisplayStatus.loading` instead of a distinct `initial` value, making it impossible to distinguish "never received any event" from "received an event and is now loading."

**Fix:** Add `initial` as the first value to `MenuDisplayStatus`:

```dart
enum MenuDisplayStatus { initial, loading, success, failure }
```

And update the default constructor:

```dart
const MenuDisplayState({
  this.status = MenuDisplayStatus.initial,
  ...
});
```

---

### 8. `ConnectingPage` raw `SizedBox(height: 16)` violates design token rules

The plan says "Reuse KDS `ConnectingPage` verbatim." The actual KDS `ConnectingPage` contains:

```dart
const SizedBox(height: 16),
```

This is a raw numeric literal `16` for spacing. Per `CLAUDE.md`: "Use `context.spacing.xxx`... Avoid raw numeric literals for layout values when a spacing/radius token matches." `spacing.lg == 16` is an exact match for this value. If the plan instructs verbatim copy without flagging this, the implementor will reproduce the violation.

**Fix:** Note in the plan that `ConnectingPage` should be adapted (not copied verbatim) and the `SizedBox(height: 16)` should become `SizedBox(height: context.spacing.lg)` or wrapped in a `Builder` if needed. Alternatively, a `Spacing` widget using the token would be cleaner:

```dart
SizedBox(height: spacing.lg),
```

This requires a `spacing` local variable in `build`.

---

### 9. `pubspec.yaml` is missing `nested` dev dependency

The KDS `pubspec.yaml` includes `nested: ^1.0.0` in `dev_dependencies`. The menu board `pubspec.yaml` in the plan omits it. `nested` is required by `bloc_test` and `flutter_bloc` for certain test helpers. The KDS app's inclusion of it suggests it was needed. Verify whether `nested` is a transitive dependency that does not need explicit declaration in this context, or whether the KDS app added it for a reason. If the test suite uses `MultiBlocProvider` inside `pumpApp`, `nested` may be needed.

**Fix:** Add `nested: ^1.0.0` to `dev_dependencies` to match the KDS template, per the plan's own acceptance criterion: "pubspec.yaml and analysis_options.yaml follow the KDS app template."

---

### 10. `pubspec.yaml` is missing the `flutter: generate: true` section

The KDS `pubspec.yaml` ends with:

```yaml
flutter:
  generate: true
  uses-material-design: true
```

`generate: true` is required for the l10n build step (`flutter gen-l10n`) to work. The plan's `pubspec.yaml` snippet does not include this section. If l10n is decided to be required (see issue 3), this section is mandatory.

**Fix:** Add the `flutter:` section to the plan's `pubspec.yaml` snippet:

```yaml
flutter:
  generate: true
  uses-material-design: true
```

---

## Suggestions — Nice to Have

### 11. Viewport size setup in widget tests is undocumented

The plan lists `menu_display_view_test.dart` as a file to create. The KDS `kds_view_test.dart` sets a landscape viewport for every test group:

```dart
tester.view.physicalSize = const Size(1280, 800);
tester.view.devicePixelRatio = 1;
addTearDown(tester.view.resetPhysicalSize);
addTearDown(tester.view.resetDevicePixelRatio);
```

The menu board targets a 1920x1080 display. Without a matching viewport override, widget tests for `MenuDisplayView` will overflow or clip. The plan does not mention this. It's a testing detail, but it has caused flaky/broken widget tests in the KDS app historically.

**Suggestion:** Add a note to the Testing section: "Widget tests for `MenuDisplayView` must set a widescreen viewport (e.g., 1920x1080 at `devicePixelRatio: 1`) using `tester.view.physicalSize` with `addTearDown` teardown calls."

---

### 12. `MenuDisplayPage` should dispatch `MenuDisplaySubscriptionRequested` in `create`, not in `build`

The plan snippet shows:

```dart
class MenuDisplayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MenuDisplayBloc(...)..add(const MenuDisplaySubscriptionRequested()),
      child: const MenuDisplayView(),
    );
  }
}
```

This mirrors the KDS `KdsPage` pattern exactly — the event is dispatched via the cascade `..add(...)` in `create`. This is correct. Confirming it is the right pattern so the implementor does not move the `add` call into `initState` or a listener.

---

### 13. Derived data computed in the view

The plan correctly places derived data computation in the view:

```dart
final featuredLeft = items.where((i) => i.groupId == groups.first.id && i.available).firstOrNull;
```

Note that `groups.first` will throw a `StateError` if `groups` is empty (e.g., during `loading` state before any data arrives). The view must guard against empty groups before computing derived values:

```dart
final featuredLeft = groups.isNotEmpty
    ? items.where((i) => i.groupId == groups.first.id && i.available).firstOrNull
    : null;
```

The plan does document the "Server sends empty groups" edge case decision correctly. Just ensure the implementing developer sees the connection between that decision and the guard needed in the `build` method.

---

### 14. `AppRouter` class naming: `routes` getter returns a `GoRouter`

The KDS `AppRouter` exposes `GoRouter get routes => _goRouter`. The name `routes` is slightly misleading — it returns the router instance, not a collection of routes. This is established pattern in the codebase, so it should be copied as-is. Just a naming observation for future refactoring consideration, not actionable for this plan.

---

## Simplicity Assessment

- Lines that could be removed: ~0. The plan is tightly scoped.
- Unnecessary abstractions: None identified. The three-file Bloc split (bloc/event/state) is the established convention.
- YAGNI violations: None. The explicit call-out of what is NOT included (no `order_repository`, no `intl`, no `flutter_localizations`) is well-reasoned. If l10n is required (see issue 3), `flutter_localizations` and `intl` would need to be added — but those are legitimate needs, not scope creep.
- Complexity verdict: Already minimal. The plan correctly rejects premature generalization and defers non-critical enhancements (window sizing, custom branding) appropriately.

---

## Testing Assessment

- New code with tests: Bloc tests planned for `AppBloc` and `MenuDisplayBloc`. Widget tests planned for `MenuDisplayPage` and `MenuDisplayView`.
- Test quality: Plan describes the right structure. `blocTest` usage confirmed. `mocktail` confirmed. `pumpApp` confirmed.
- Bloc test coverage: Needs explicit call-out of failure state test case for `MenuDisplayBloc` (the plan mentions defining `MenuDisplayStatus.failure` but does not explicitly require a test for the `onError` path in the bloc test plan).
- Widget test coverage: Partial — missing explicit mention of: loading state renders `CircularProgressIndicator`, failure state renders error indicator, empty groups renders without crash.

**Recommended additions to the test plan:**

```
MenuDisplayBlocTest:
  - emits [loading] on subscription requested (initial emit before first stream value)
  - emits [loading, success] on stream data with available items
  - emits [loading, success] with items filtered by group correctly
  - emits [loading, failure] on stream error

MenuDisplayViewTest:
  - renders CircularProgressIndicator when status is loading
  - renders three-panel layout when status is success with data
  - renders error indicator when status is failure
  - renders no crash when groups list is empty (status success, empty data)
  - featured panels receive correct items from first/last groups
```

---

## Summary of Required Plan Updates

| # | Severity | Action |
|---|---|---|
| 1 | Critical | Add `go_router.dart` + `helpers.dart` to Files to Create |
| 2 | Critical | Resolve `FeaturedItemPanel` contract: uses `MenuGroup` + `MenuItem`, no `description` on `MenuItem` |
| 3 | Important | Commit to l10n setup; mark as required; add l10n files to Files to Create |
| 4 | Important | Specify `pumpApp` accepts `MenuRepository?` not `OrderRepository?` |
| 5 | Important | Add `initial` to `MenuDisplayStatus` enum |
| 6 | Important | Note `ConnectingPage` adaptation needed: `SizedBox(height: 16)` → `SizedBox(height: spacing.lg)` |
| 7 | Important | Add `nested: ^1.0.0` to `dev_dependencies` |
| 8 | Important | Add `flutter: generate: true` to `pubspec.yaml` snippet |
| 9 | Suggestion | Document viewport size setup requirement for `MenuDisplayView` widget tests |
| 10 | Suggestion | Add explicit test cases for loading/failure/empty-groups states |
