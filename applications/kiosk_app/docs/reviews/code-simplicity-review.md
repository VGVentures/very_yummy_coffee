# Code Simplicity Review -- kiosk_app/lib

**Reviewer**: Claude Opus 4.6 (automated)
**Date**: 2026-03-05
**Scope**: `applications/kiosk_app/lib/` -- all hand-written Dart files (excluding generated `.mapper.dart` files)
**Approximate LOC reviewed**: ~1,850 (hand-written, across 34 source files)

---

## Simplification Analysis

### Core Purpose

The kiosk app is a landscape-locked, in-store self-service ordering application. Customers browse a menu by group, drill into items, customize drinks (size/milk/extras), manage a cart, check out, and see an order-complete confirmation with live status tracking. The code must connect via WebSocket RPC, subscribe to menu and order data, and manage navigation between seven distinct screens.

---

### Critical Issues

#### C1. `MenuItemsBloc` subscribes to `getMenuGroups()` unnecessarily via `Rx.combineLatest2`

**File**: `lib/menu_items/bloc/menu_items_bloc.dart`, lines 28-44
**File**: `lib/menu_items/bloc/menu_items_state.dart`, line 11 (`group` field)

The bloc combines two streams: `getMenuGroups()` and `getMenuItems(groupId)`. It stores the matching `MenuGroup` in `state.group`. However, the view (`menu_items_view.dart`) never reads `state.group`. Instead, it obtains the group name through a `BlocSelector<MenuGroupsBloc, MenuGroupsState, String>` (line 23). This means:

- The `rxdart` import and `Rx.combineLatest2` call are unnecessary in this bloc.
- The `group` field on `MenuItemsState` is dead state -- written but never read.
- A redundant second subscription to the menu groups stream is opened for no reason, doubling the ref-count on the shared WS subscription while this screen is active.

**Recommendation**: Remove `Rx.combineLatest2` and replace with a direct subscription to `_menuRepository.getMenuItems(_groupId)`. Remove the `group` field from `MenuItemsState`. Remove the `rxdart` import from the bloc file (and possibly from `pubspec.yaml` if no other file needs it).

**Impact**: Removes ~10 lines, one unnecessary stream subscription, one dead state field. Reduces cognitive load for anyone reading the bloc.

---

### Important Issues

#### I1. Duplicated `_SummaryRow` widget across cart and checkout views

**Files**:
- `lib/cart/view/cart_view.dart`, lines 304-325
- `lib/checkout/view/checkout_view.dart`, lines 198-219

These two private `_SummaryRow` widgets are identical -- same fields (`label`, `amount`, `style`), same build method, same price-formatting logic. Per the project CLAUDE.md ("When implementing a new widget that is used in more than one screen... place it in `shared/very_yummy_coffee_ui`"), this should be extracted.

**Recommendation**: Extract a shared `OrderSummaryRow` widget (or similar) into the kiosk app's `lib/widgets/` directory (since it formats `int` amounts to dollar strings, which is app-specific, not pure-UI). Import it from both views.

**Impact**: Removes ~22 duplicate lines, prevents divergent maintenance.

#### I2. Repeated price-formatting expression `'\$${(amount / 100).toStringAsFixed(2)}'` appears 11 times

**Files**: `cart_view.dart` (2x), `checkout_view.dart` (3x), `order_complete_view.dart` (3x), `menu_items_view.dart` (1x), `item_detail_view.dart` (2x)

The cents-to-dollars string conversion `'\$${(value / 100).toStringAsFixed(2)}'` is copy-pasted across 11 call sites. Any change to currency formatting (e.g., locale-aware, different currency symbol) would require editing every occurrence.

**Recommendation**: Create a simple extension method or top-level helper, e.g.:

```dart
extension CentsFormatX on int {
  String toDollars() => '\$${(this / 100).toStringAsFixed(2)}';
}
```

Place in `lib/widgets/` or a `lib/helpers/` file and import where needed.

**Impact**: Reduces 11 inline expressions to 11 `.toDollars()` calls; single point of change for formatting.

#### I3. Hardcoded English strings in bloc state enums (`DrinkSize`, `MilkOption`, `DrinkExtra`)

**File**: `lib/item_detail/bloc/item_detail_state.dart`, lines 10-51

The `label` and `shortLabel` getters on `DrinkSize`, `MilkOption`, and `DrinkExtra` return hardcoded English strings (e.g., `'Whole Milk'`, `'Large'`). The app already has a full l10n setup with ARB files and `context.l10n`. These labels bypass localization entirely.

Furthermore, `label` is used in `_onAddToCartRequested` (line 101-108 of `item_detail_bloc.dart`) to build the `options` string sent to the server. If the labels were ever localized, the options string sent to the backend would also change -- a sign that display labels and data labels are conflated.

**Recommendation**: For display purposes, move the label strings to the ARB file and resolve them in the view via `context.l10n`. For the server-sent `options` string, use the enum name or a dedicated serialization key that is independent of the display label.

**Impact**: Proper separation of concerns; enables future localization without breaking server data.

#### I4. Inconsistent `@MappableClass` annotations on event classes

**Files**:
- `app_event.dart` -- no `@MappableClass` on `AppEvent` or `AppStarted`
- `item_detail_event.dart` -- no `@MappableClass` on any event class
- Other event files (`cart_event.dart`, `checkout_event.dart`, etc.) -- all have `@MappableClass`

Two of eight event files skip the annotation entirely while the rest apply it. The annotation generates `Mappable` mixin code and `.mapper.dart` part files. If the annotation is unnecessary for events (since they are not serialized), it should be removed from all event files, not inconsistently applied. If it is necessary (e.g., for `bloc_lint` or testing), it should be added to the two missing files.

**Recommendation**: Pick one approach and apply consistently. If `@MappableClass` is only needed on states (for `copyWith`), remove it from all event classes to reduce generated code.

**Impact**: Consistency improvement; potentially removes several hundred lines of generated `.mapper.dart` code if annotations are removed from events.

---

### Suggestions

#### S1. Magic numbers for layout dimensions

Several raw numeric literals appear in view code that could benefit from named constants or spacing tokens:

| Value | Location | Purpose |
|---|---|---|
| `520` | `item_detail_view.dart:76`, `order_complete_view.dart:92` | Left panel width |
| `400` | `cart_view.dart:253` | Order summary panel width |
| `200` | `item_detail_view.dart:83-84` | Hero image circle size |
| `120` | `order_complete_view.dart:100-101` | Success check circle size |
| `64` | `kiosk_header.dart:121-122` | Back button size |
| `48` | `cart_view.dart:101-102` | Cart item icon container |
| `28` | `cart_view.dart:207` | Quantity text width |
| `32` | `item_detail_view.dart:501` | Quantity text width |
| `56` | `checkout_view.dart:242` | Place order button height |

These are not token violations (the project tokens cover spacing, not component dimensions), but extracting them to named constants at the top of each file or in a kiosk layout constants file would improve readability and make kiosk-wide layout adjustments easier.

**Impact**: Readability improvement. No functional change.

#### S2. `spacing.huge * 1.5` and `spacing.huge * 2.5` in HomeView

**File**: `lib/home/view/home_view.dart`, lines 39, 47, 52

Multiplying a spacing token by a decimal creates a non-standard value that defeats the purpose of the spacing scale. `spacing.huge` is 32, so `* 1.5` = 48 and `* 2.5` = 80. Neither value exists in the spacing scale.

**Recommendation**: Either add named tokens for these sizes (e.g., `spacing.enormous = 48`, `spacing.heroHorizontalPadding = 80`) or accept the raw number and comment its derivation. The current form gives the appearance of using the design system while actually circumventing it.

**Impact**: Minor design system hygiene.

#### S3. `_EmptyCartView` is missing `const` constructor

**File**: `lib/cart/view/cart_view.dart`, line 327

`_EmptyCartView` does not have a `const` constructor and is instantiated without `const` on line 48. All other private widgets in the codebase use `const` constructors. This is a minor inconsistency.

**Recommendation**: Add `const _EmptyCartView()` constructor.

**Impact**: Trivial. Enables const propagation.

#### S4. `_CategoryCardRow` uses `asMap().entries.map()` for index access

**File**: `lib/menu_groups/view/menu_groups_view.dart`, lines 66-78

The code uses `groups.asMap().entries.map((entry) { ... })` to get both the index and group. Dart 3 provides `indexed` on `Iterable`:

```dart
groups.indexed.map((r) {
  final (index, group) = r;
  ...
})
```

Or better, use `ListView.separated` or `Row` with `SeparatedList` to avoid manual padding logic entirely.

**Recommendation**: Consider simplifying to use `.indexed` or restructuring to avoid index-based conditional padding.

**Impact**: Minor readability improvement.

#### S5. `HomePage` / `HomeView` split adds no value

**File**: `lib/home/view/home_page.dart` (19 lines), `lib/home/view/home_view.dart` (76 lines)

`HomePage.build()` simply returns `const HomeView()` with no bloc provider, no parameters, and no logic. The page/view split pattern exists in other features to scope a `BlocProvider`, but `HomePage` provides no bloc. The two files could be merged.

However, this follows the project's established convention (every feature has a `page.dart` + `view.dart`), and consistency has value. This is noted as a suggestion, not an important issue.

**Impact**: ~15 lines saved if merged, but breaks convention.

#### S6. `ConnectingPage.routeName` is both a name and a path

**File**: `lib/app/view/connecting_page.dart`, line 12
**File**: `lib/app/app_router/app_router.dart`, lines 42-43

`ConnectingPage.routeName` is `/connecting` and is used as both the GoRouter `name:` and `path:`. Route names are typically non-path identifiers. Similarly, `HomePage.routeName` is `/home`. This is not a complexity issue but a naming clarity issue.

**Impact**: Negligible. Conventional in this codebase.

#### S7. `_AppView` is a StatefulWidget only for `GlobalKey` and `AppRouter` init

**File**: `lib/app/view/app.dart`, lines 24-61

The StatefulWidget is used solely to create a `GlobalKey<NavigatorState>` and an `AppRouter` in `initState`. This could be simplified to a StatelessWidget using `late final` fields or by creating the router inline, since `GoRouter` manages its own lifecycle.

**Recommendation**: This is a minor structural preference. The current approach is valid and avoids recreating the router on rebuilds. No action strictly needed.

**Impact**: Minor. ~5 lines could be saved.

---

### YAGNI Violations

#### Y1. `MenuItemsState.group` field -- dead code

As described in C1, the `group` field on `MenuItemsState` is written by the bloc but never read by any view or widget. This is code that was likely carried over from the mobile app but is not needed in the kiosk implementation.

#### Y2. `@MappableClass` on event classes

Event classes are never serialized, deserialized, or copied. The `@MappableClass` annotation generates `Mappable` mixins and `.mapper.dart` part files for each annotated event. These generated files add to build time and project size without providing any runtime value. The annotations on event classes appear to be applied "just in case" rather than for a concrete need.

#### Y3. `@MappableEnum` on `DrinkSize`, `MilkOption`, `DrinkExtra`

**File**: `lib/item_detail/bloc/item_detail_state.dart`

These three enums have `@MappableEnum()` annotations but are never serialized or deserialized. They are local UI-state enums used only within the item detail feature. The annotation generates unnecessary mapper code.

---

### Code That Could Be Removed

| File | Lines | Reason | LOC |
|---|---|---|---|
| `menu_items_bloc.dart` | 4, 29-33 | Remove `rxdart` import and `combineLatest2` wrapping | ~5 |
| `menu_items_state.dart` | 11 | Remove unused `group` field | ~1 |
| `cart_view.dart` | 304-325 | Extract `_SummaryRow` to shared location | ~22 (net 0, moved) |
| `checkout_view.dart` | 198-219 | Remove duplicate `_SummaryRow` | ~22 |
| `item_detail_state.dart` | 3, 23, 39 | Remove `@MappableEnum` from local enums (if not needed) | ~3 annotations + generated code |
| Various event files | multiple | Remove `@MappableClass` from events (if not needed) | ~12 annotations + generated code |

**Estimated hand-written LOC reduction**: ~30-50 lines
**Estimated generated code reduction**: Several hundred lines of `.mapper.dart` files (if unnecessary annotations are removed)

---

### Final Assessment

| Metric | Value |
|---|---|
| **Total potential LOC reduction** | ~3% of hand-written code (~50 lines); ~15-20% of generated code if unnecessary annotations are removed |
| **Complexity score** | Low |
| **Critical issues** | 1 |
| **Important issues** | 4 |
| **Suggestions** | 7 |
| **Recommended action** | Minor tweaks needed. The codebase is well-structured and follows project conventions closely. Address C1 (dead stream subscription) and I1-I2 (duplication) before merge. The remaining items are improvements that can be addressed in a follow-up. |

---

### Positive Observations

The kiosk app code is generally clean, well-organized, and consistent with the project's established patterns:

- Design token usage is excellent: no raw `Color(0xFF...)` or `Colors.*` anywhere in view code.
- No `EdgeInsets.fromLTRB` usage (project rule followed).
- Consistent use of `context.spacing.*`, `context.radius.*`, and `context.typography.*`.
- Bloc scoping is correct: each feature provides its own bloc at the page level.
- Navigation uses `context.go('/path')` with hardcoded strings as required.
- `PopScope(canPop: false)` is correctly applied on Home and Order Complete screens.
- Order Complete screen is properly exempt from disconnect redirect.
- Cart route is correctly ordered before `:groupId` in the router.
- `BlocSelector` is used appropriately in `MenuItemsView` for group name (avoiding `context.read` in builder).
- The `KioskHeader` widget is well-designed: no `height` parameter, sizes to content, cleanly handles optional back button and cart badge.
