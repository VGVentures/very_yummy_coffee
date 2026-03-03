# VGV Code Review — Implementation Plan: feat/home-screen

## Summary

The plan is well-structured, clearly motivated, and faithfully follows established project patterns in the areas that matter most: Bloc design, repository wiring, layer separation, and use of `dart_mappable`. The phased approach is sensible and the risk table is honest. However, there are four issues that must be addressed before an engineer picks this up: a critical l10n regression introduced by the `OrderStatus.ready` insertion that will break all four existing `_StatusTracker` label-index mappings, a GoRouter configuration bug where `name` and `path` diverge from the rest of the router, a greedy-filtering approach in `HomeBloc` that silently drops a future enum value, and a missing `home.dart` barrel export from `app_router.dart`. There are also several important naming, test-gap, and view-logic concerns to resolve. With those addressed this plan is ready to implement.

---

## Critical — Must Fix Before Implementation

### 1. l10n step labels will break after inserting `ready` at index 2

**Location:** Plan section 2.1 (`OrderStepTracker._activeStepIndex`) and existing `order_complete_view_test.dart`

**Problem:** The current `_StatusTracker` uses only three statuses (`pending=0`, `submitted=1`, `completed=2`). The existing l10n keys map to those three positions:

- `orderCompleteStep1` = "Placed" (index 0)
- `orderCompleteStep2` = "In Progress" (index 1)
- `orderCompleteStep3` = "Ready" (index 2, currently shown for `completed`)
- `orderCompleteStep4` = "Picked Up" (index 3, currently unreachable)

After adding `ready` at index 2 and shifting `completed` to index 3, the existing string key `orderCompleteStep3` ("Ready") is already in the ARB file but was used to label the `completed` step. The plan's new mapping means:
- index 2 → `ready` → label "Ready" (correct, already "orderCompleteStep3")
- index 3 → `completed` → label "Picked Up" (correct, already "orderCompleteStep4")

**The regression is in the existing tests**, not just the visual.  `order_complete_view_test.dart` line 176 asserts:

```dart
// test name: 'step 3 label is shown when order status is completed'
expect(find.text('Ready'), findsOneWidget);
```

"Ready" is the label for `orderCompleteStep3` which the test assumes maps to `completed`. After the migration, `completed` maps to index 3 ("Picked Up"), so this test will now find "Ready" only because `ready` is a new step label — but the test description says "completed." This will produce a misleading false-positive rather than a failing test, making the regression invisible.

**Fix:** Before extracting `OrderStepTracker`, add a dedicated regression test for `completed` asserting "Picked Up" at index 3. Then update the misleadingly-named existing test. The plan notes this risk but the proposed mitigation ("add a regression test for `completed` status before extracting") does not specify what the test should assert — it needs to assert `find.text('Picked Up')` for `OrderStatus.completed` after the migration.

---

### 2. GoRouter `name` and `path` are the same string — inconsistent with codebase convention

**Location:** Plan section 5.1, router snippet

The plan proposes:

```dart
GoRoute(
  name: HomePage.routeName,
  path: HomePage.routeName,  // both are '/home'
  ...
)
```

GoRouter's `name` is a logical identifier; `path` is the URL segment. Every other route in the codebase separates these clearly using named constants (`routeName` vs `routePath` / `routePathTemplate`). More importantly, all existing top-level routes use `routeName` as the full absolute path (e.g. `static const routeName = '/menu'`). The proposed snippet is technically functional but it sets `name` to `/home` (with a leading slash), which is non-standard for GoRouter's `name` field and duplicates the path.

Additionally, `HomePage.routeName` is defined as `'/home'`, which matches `MenuGroupsPage.routeName = '/menu'`. These are both top-level routes, so the pattern is consistent. The actual implementation is fine; the issue is that the plan's snippet uses `name: HomePage.routeName` for the GoRoute's `name` parameter, but `GoRoute.name` in GoRouter is a separate logical name that can differ from the path. Since this project uses `context.go('/path')` hardcoded strings everywhere and never calls `context.goNamed`, the `name` field on `GoRoute` is unused noise. Follow the existing pattern:

```dart
GoRoute(
  path: HomePage.routeName,  // '/home'
  pageBuilder: (BuildContext context, GoRouterState state) =>
      NoTransitionPage(
        child: HomePage.pageBuilder(context, state),
      ),
),
```

Drop `name:` on the `GoRoute` entirely to match `ConnectingPage`'s route and avoid confusion. If `name:` is kept for parity with other routes, it must use a stable non-path identifier, not the path string itself.

---

### 3. `HomeBloc` filter uses denylist — will silently miss future enum values

**Location:** Plan section 3.4, `_onSubscriptionRequested`

```dart
final active = orders.orders
    .where((o) =>
        o.status != OrderStatus.completed &&
        o.status != OrderStatus.cancelled)
    .toList();
```

This is a denylist. If another `OrderStatus` value is added later (e.g. `refunded`, `expired`), it will silently appear on the home screen as an "active" order. The project has already added one status (`ready`) in this very ticket; the pattern is clearly extensible.

The plan's "Accepted statuses" decision table explicitly lists `pending`, `submitted`, `ready` as active. Use an allowlist:

```dart
const _activeStatuses = {
  OrderStatus.pending,
  OrderStatus.submitted,
  OrderStatus.ready,
};

final active = orders.orders
    .where((o) => _activeStatuses.contains(o.status))
    .toList();
```

This makes the intent explicit and future-safe. When a new status is added, the exhaustive `switch` in `OrderStepTracker._activeStepIndex` will produce a compile-time error, and the allowlist here will correctly exclude it until explicitly added.

---

### 4. `app_router.dart` import for `HomeBloc` barrel is not listed in plan

**Location:** Plan section 5.1 / Files To Modify

The plan lists `app_router.dart` as a file to modify for the route, but `app_router.dart` imports feature barrels (e.g. `order_complete/order_complete.dart`). The `home/home.dart` barrel must be imported in `app_router.dart`. The plan's "Files To Modify" table omits mentioning this import addition, and the "Files To Create" table lists `home.dart` but does not spell out that `app_router.dart` needs a corresponding `import` line. A developer following this plan literally could miss it. Add an explicit note.

---

## Important — Should Fix

### 5. Greeting computation belongs in the Bloc, not in the view

**Location:** Plan section 4.2, `HomeView._greeting()`

```dart
String _greeting() {
  final hour = DateTime.now().hour;
  ...
}
```

The plan acknowledges this is a view-level method. `DateTime.now()` in `build` is untestable without `Clock` injection or a layer boundary. The existing `HomeState` already holds `status` and `orders`; adding a `greeting` field (computed once in `_onSubscriptionRequested`) keeps all business logic in the Bloc and makes it trivially testable:

```dart
// In HomeState
final String greeting;  // or a HomeGreeting enum

// In HomeBloc._onSubscriptionRequested onData
return state.copyWith(
  greeting: _computeGreeting(),
  orders: active,
  status: HomeStatus.success,
);
```

A `HomeGreeting` enum (`morning`, `afternoon`, `evening`) is more idiomatic than a raw String on the state — the view translates it to an l10n string, keeping the Bloc free of localization concerns. Either approach is acceptable, but the current plan's placement of `DateTime.now()` in the view is a testability gap and a mild VGV convention violation (no business logic in widgets).

---

### 6. `OrderStepTracker` receives `List<String> labels` — fragile API

**Location:** Plan section 2.1, `OrderStepTracker` constructor

```dart
const OrderStepTracker({
  required this.status,
  required this.labels,  // always length 4
});
```

`List<String> labels` with a length-4 constraint documented only in a comment is a footgun. The shared widget will be used from two places (Home and OrderComplete). If a caller passes 3 or 5 strings, it silently produces broken UI. Two alternatives:

**Option A:** Use a fixed named parameter for each label:

```dart
const OrderStepTracker({
  required this.status,
  required this.placedLabel,
  required this.brewingLabel,
  required this.readyLabel,
  required this.pickedUpLabel,
  super.key,
});
```

**Option B:** Assert at construction time:

```dart
OrderStepTracker({...})
    : assert(labels.length == 4, 'OrderStepTracker requires exactly 4 labels'),
      ...;
```

Option A is preferred — it's self-documenting and prevents the bug at compile time.

---

### 7. Missing `home_bloc.dart` barrel in `home.dart` — inconsistent with every other feature

**Location:** Plan section 3.1, file tree

The plan shows:

```
lib/home/
  bloc/
    home_bloc.dart
    home_event.dart
    home_state.dart
  view/
    home_page.dart
    home_view.dart
    view.dart
  home.dart
```

Every other feature barrel (`order_complete.dart`, `cart.dart`, etc.) exports both the Bloc and the view barrel. The plan's `home.dart` example is not shown. Confirm it exports `bloc/home_bloc.dart` and `view/view.dart`, and that `view/view.dart` exports both `home_page.dart` and `home_view.dart`. Also confirm there is a `bloc/bloc.dart` barrel if the pattern from other features requires it (the existing features do not use a `bloc/bloc.dart` intermediate — they export directly from the feature barrel, e.g. `export 'bloc/order_complete_bloc.dart';`).

---

### 8. `HomeBloc` event should emit `HomeStatus.loading` at stream start

**Location:** Plan section 3.4

The plan's `_onSubscriptionRequested` handler only emits on `onData` and `onError`. There is no explicit loading-state transition at subscription start — the Bloc relies on `const HomeState()` defaulting to `status: HomeStatus.loading`. This is the same pattern as `OrderCompleteBloc` and is acceptable, but the plan should acknowledge that the `loading` state is never re-entered once the stream emits. This matters for the test plan: a test that only dispatches `HomeSubscriptionRequested` and waits for the first `onData` will never see a state with `status == loading` emitted via `blocTest`'s `expect` list (since `loading` is the initial state, not an emitted state). The test in section 7.1 should include a `seed` or `initialState` assertion test to verify the initial loading state, mirroring the pattern in `order_complete_bloc_test.dart` line 33-36.

---

### 9. Widget test for `HomeView` does not cover the `failure` state

**Location:** Plan section 7.2

The listed test cases are:
- Loading state → `CircularProgressIndicator`
- Empty orders → empty state
- Non-empty orders → order cards
- "Start New Order" button navigation

The `failure` state is missing. `HomeView` renders `_ErrorState` when `state.status == HomeStatus.failure`. A test verifying this renders `context.l10n.errorSomethingWentWrong` must be included — this is a VGV requirement (cover failure states; section Pass 3).

---

### 10. `OrderStatus` file path is wrong in the plan

**Location:** Plan section 1.1

The plan says:

> File: `shared/order_repository/lib/src/models/order.dart`

But the plan header also states:

> `very_yummy_coffee_models` (shared) — Shared models: `MenuGroup`, `MenuItem`

The `OrderStatus` enum lives in `shared/order_repository/lib/src/models/order.dart` (confirmed by reading the file). This is correct. However, the plan's Files To Modify table lists `shared/order_repository/lib/src/models/order.dart` which is right. No action needed, but be aware `build_runner` must run in `shared/order_repository`, not in `very_yummy_coffee_models`.

---

### 11. `_StartNewOrderBar` widget name is vague; consider `_StartNewOrderButton`

**Location:** Plan section 4.2

`_StartNewOrderBar` implies a full-width bottom bar container (which it is, via `bottomNavigationBar`), but the naming suggests a Scaffold-slot wrapper rather than a widget. If the widget is simply a `BaseButton` wrapped in `SafeArea` + `Padding`, name it `_StartNewOrderButton` and place it directly in `bottomNavigationBar`. If it is a container with additional styling (background color, elevation), `_StartNewOrderBar` is acceptable but the plan should describe its contents to distinguish it from a nav bar.

---

## Suggestions — Nice to Have

### 12. `homeOrderItemCount` ARB string uses non-standard ICU plural syntax

**Location:** Plan section 6

```arb
"homeOrderItemCount": "{count} {count, plural, =1{item} other{items}}"
```

This embeds `count` twice — once as a prefix and once inside the plural selector. The existing `cartItemCount` key in `app_en.arb` uses the cleaner pattern where the plural selector handles the count prefix itself:

```arb
"cartItemCount": "{count, plural, =1{1 item} other{{count} items}}"
```

Align `homeOrderItemCount` with this pattern, or simply reuse `cartItemCount` since the string "1 item / N items" is identical in meaning.

---

### 13. `homeActiveOrdersCount` l10n key may be unused

**Location:** Plan section 6

```arb
"homeActiveOrdersCount": "{count} active"
```

The plan's `HomeView` structure doesn't explicitly show where this count is displayed. If it appears in `_HomeHeader` as a subtitle ("3 active"), confirm it is actually rendered. If it ends up unused at implementation time, remove it — ARB keys without UI callers are dead strings.

---

### 14. `_greeting()` hardcodes English strings — bypasses l10n

**Location:** Plan section 4.2

```dart
if (hour < 12) return 'Good morning';
if (hour < 18) return 'Good afternoon';
return 'Good evening';
```

The plan adds l10n keys (`homeGreetingMorning`, etc.) in Phase 6 but the `HomeView._greeting()` method in Phase 4 returns raw strings. The plan must ensure the view uses `context.l10n.homeGreetingMorning` etc., not the hardcoded English strings shown in the snippet. This looks like a documentation inconsistency in the plan — the final implementation should use the l10n keys — but it should be made explicit.

---

### 15. No `@MappableClass` description comments on `HomeState` / `HomeEvent`

**Location:** Plan section 3.2–3.3

The existing models in the codebase use `{@template ...}` / `{@macro ...}` doc comments (e.g. `Order`). The plan's state and event snippets omit these. For consistency with the rest of the codebase, add doc comments to `HomeState` and `HomeSubscriptionRequested`. Minor, but worth noting for PRs.

---

## Simplicity Assessment

- Lines that could be removed: ~5 (the redundant `name:` parameter on `GoRoute`)
- Unnecessary abstractions: None. The plan avoids over-engineering well.
- YAGNI violations: `homeActiveOrdersCount` may be unused (see suggestion 13). The `markOrderReady` backend action has no client trigger yet — this is explicitly acknowledged as intentional and acceptable.
- Complexity verdict: Already minimal. The plan is appropriately scoped.

---

## Testing Assessment

- New code with tests: Partial — `HomeBloc` and `HomeView` tests planned, but `failure` state missing from view tests and `loading` initial-state assertion missing from Bloc tests.
- Test quality: Meaningful for the cases listed; the filtering test ("filters out completed and cancelled") is the most important and is present.
- Bloc test coverage: Partial — happy path and error path present; initial state assertion and multi-emission test (matching `order_complete_bloc_test.dart` line 96) are not mentioned.
- Widget test coverage: Partial — `failure` state unspecified; regression for `OrderCompleteView` with `completed` → step 3 ("Picked Up") is mentioned but the assertion content is not specified.
- OrderComplete regression: The plan calls for a regression test but the existing test at line 164–178 of `order_complete_view_test.dart` asserts `find.text('Ready')` for `completed` status. After the migration this test will still pass (because "Ready" is the label for the new `ready` step which is also rendered), making it a false positive. A new test explicitly asserting `find.text('Picked Up')` for `OrderStatus.completed` must be added, and the existing test description updated to reflect that it now validates `OrderStatus.ready`.
