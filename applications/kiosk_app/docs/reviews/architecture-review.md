# Architecture Review: kiosk_app

**Date**: 2026-03-05
**Reviewer**: Architecture Review Agent (Claude Opus 4.6)
**Branch**: `feat/kiosk-app`
**Scope**: Full architecture review of `applications/kiosk_app/`

---

## Layer Separation

### Dependency Analysis

The kiosk_app is a **presentation layer** application. Its `pubspec.yaml` declares the following layer dependencies:

| Dependency | Layer | Acceptable? |
|---|---|---|
| `api_client` | Data | See finding below |
| `connection_repository` | Domain | Yes |
| `menu_repository` | Domain | Yes |
| `order_repository` | Domain | Yes |
| `very_yummy_coffee_ui` | UI toolkit | Yes |

### Violations Found: 1

**[Important] Presentation imports Data layer directly**

- `lib/main.dart:1` -- Presentation layer imports `api_client` (Data layer) directly.

```dart
import 'package:api_client/api_client.dart';
```

`main.dart` instantiates `ApiClient` and `WsRpcClient` directly at lines 17-23. This is a bootstrap/composition-root concern. While this is a common pragmatic pattern -- someone has to wire up the data layer -- it does mean the app's `pubspec.yaml` has an explicit dependency on `api_client`, which is a data-layer package.

**Mitigation**: The `api_client` import is confined exclusively to `main.dart` (the composition root) and does not leak into any feature code, Bloc, or view file. No other file in `lib/` imports `api_client`. This is an acceptable composition-root pattern and is consistent with how `kds_app`, `pos_app`, and `mobile_app` handle bootstrap. **No action required**, but noted for completeness.

### Clean Files

All other files (views, blocs, pages, widgets) exclusively import domain-layer packages (`menu_repository`, `order_repository`, `connection_repository`) and the UI toolkit (`very_yummy_coffee_ui`). No view or bloc file imports `api_client` directly.

---

## Bloc/Cubit Assessment

The app uses **Bloc exclusively** (no Cubits), which aligns with the CLAUDE.md directive: "Prefer `Bloc` over `Cubit`. Always use `Bloc` with explicit event classes."

### AppBloc
**Status**: Correct

- **Location**: `lib/app/bloc/app_bloc.dart`
- **Events**: `AppStarted` -- descriptive, sealed class hierarchy
- **State**: `AppState` with `AppStatus` enum, immutable via `@MappableClass()` with `copyWith`
- **Logic**: `emit.forEach` on `ConnectionRepository.isConnected` stream
- **Scoping**: Provided at `App` widget level (correct -- app-level concern)
- **No issues found**

### MenuGroupsBloc
**Status**: Correct

- **Location**: `lib/menu_groups/bloc/menu_groups_bloc.dart`
- **Events**: `MenuGroupsSubscriptionRequested` -- descriptive
- **State**: Immutable with `@MappableClass()`, status enum + list
- **Logic**: Subscribes to `menuRepository.getMenuGroups()` via `emit.forEach`
- **Scoping**: Provided at `MenuGroupsPage` level (correct -- feature-scoped)
- **No issues found**

### CartCountBloc
**Status**: Correct

- **Location**: `lib/cart_count/bloc/cart_count_bloc.dart`
- **Events**: `CartCountSubscriptionRequested` -- descriptive
- **State**: Simple immutable state with `itemCount`
- **Logic**: Sums item quantities from `currentOrderStream`
- **Scoping**: Provided at `MenuGroupsPage` alongside `MenuGroupsBloc` (correct -- needed by `KioskHeader` on menu screens)
- **No issues found**

### MenuItemsBloc
**Status**: Correct

- **Location**: `lib/menu_items/bloc/menu_items_bloc.dart`
- **Events**: `MenuItemsSubscriptionRequested` -- descriptive
- **State**: Immutable with status, optional group, and items list
- **Logic**: Uses `Rx.combineLatest2` to combine groups + items streams. Group information is stored in bloc state for the header title.
- **Scoping**: Provided at `MenuItemsPage` level (correct)
- **No issues found**

### ItemDetailBloc
**Status**: Correct

- **Location**: `lib/item_detail/bloc/item_detail_bloc.dart`
- **Events**: 7 discrete events -- `ItemDetailSubscriptionRequested`, `ItemDetailSizeSelected`, `ItemDetailMilkSelected`, `ItemDetailExtraToggled`, `ItemDetailQuantityIncremented`, `ItemDetailQuantityDecremented`, `ItemDetailAddToCartRequested`
- **State**: Immutable with multiple fields (item, size, milk, extras, quantity, status). Computed property `totalPrice` as a getter.
- **Logic**: All business logic in bloc handlers. Add-to-cart creates order if needed, then adds item. No business logic in views.
- **Scoping**: Provided at `ItemDetailPage` level (correct)
- **Complexity**: 7 events with mixed sync/async handlers justifies Bloc over Cubit
- **No issues found**

### CartBloc
**Status**: Correct

- **Location**: `lib/cart/bloc/cart_bloc.dart`
- **Events**: `CartSubscriptionRequested`, `CartItemQuantityUpdated` -- descriptive
- **State**: Immutable with optional `Order` and status
- **Logic**: Subscribes to `currentOrderStream`, delegates quantity updates to repository
- **Scoping**: Provided at `CartPage` level (correct)
- **No issues found**

### CheckoutBloc
**Status**: Correct

- **Location**: `lib/checkout/bloc/checkout_bloc.dart`
- **Events**: `CheckoutSubscriptionRequested`, `CheckoutConfirmed` -- descriptive
- **State**: Immutable with status and optional order
- **Logic**: Subscribes to current order, handles submit via repository
- **Scoping**: Provided at `CheckoutPage` level (correct)
- **No issues found**

### OrderCompleteBloc
**Status**: Correct

- **Location**: `lib/order_complete/bloc/order_complete_bloc.dart`
- **Events**: `OrderCompleteSubscriptionRequested`, `OrderCompleteBackToMenuRequested` -- descriptive
- **State**: Immutable with `navigatingBack` status for clean navigation via `BlocConsumer`
- **Logic**: Subscribes to specific order stream, handles back-to-menu with `clearCurrentOrder()`
- **Scoping**: Provided at `OrderCompletePage` level (correct)
- **No issues found**

### Summary Table

| Bloc | Events | State Immutability | Logic Location | Scoping | Verdict |
|---|---|---|---|---|---|
| AppBloc | Correct | Correct | Correct | Correct | Pass |
| MenuGroupsBloc | Correct | Correct | Correct | Correct | Pass |
| CartCountBloc | Correct | Correct | Correct | Correct | Pass |
| MenuItemsBloc | Correct | Correct | Correct | Correct | Pass |
| ItemDetailBloc | Correct | Correct | Correct | Correct | Pass |
| CartBloc | Correct | Correct | Correct | Correct | Pass |
| CheckoutBloc | Correct | Correct | Correct | Correct | Pass |
| OrderCompleteBloc | Correct | Correct | Correct | Correct | Pass |

---

## Dependency Direction

### Direction Check

```
Presentation (kiosk_app)
  -> Domain (connection_repository, menu_repository, order_repository)
  -> Data (api_client -- only in main.dart composition root)
  -> UI (very_yummy_coffee_ui)
```

- **Violations**: 0 (composition-root pattern in `main.dart` is acceptable)
- **Circular dependencies**: None detected
- No view file imports a repository that it should not have access to
- No bloc imports another feature's bloc (except `MenuItemsView` correctly uses `BlocSelector<MenuGroupsBloc>` to read the group title from the parent-provided bloc)

### Cross-Feature Import Analysis

- `menu_items/view/menu_items_view.dart` imports `menu_groups/menu_groups.dart` to access `MenuGroupsBloc` -- This is correct because `MenuGroupsBloc` is provided higher in the widget tree at `MenuGroupsPage` and `MenuItemsView` uses `BlocSelector<MenuGroupsBloc>` to read the group name for the header. This avoids duplicating the group-fetching logic.

---

## Package Structure

### Checklist

| Check | Status | Notes |
|---|---|---|
| `pubspec.yaml` exists with proper name | Pass | `very_yummy_coffee_kiosk_app` |
| `analysis_options.yaml` includes `very_good_analysis` | Pass | Includes both `bloc_lint/recommended.yaml` and `very_good_analysis` |
| `public_member_api_docs: false` for app package | Pass | Correctly disabled |
| `test/` directory exists | Pass | 20 test files covering all features |
| Single, clear responsibility | Pass | Self-service kiosk ordering app |
| UI package separate from business logic | Pass | Uses `very_yummy_coffee_ui` for shared widgets/theme |
| `l10n.yaml` configured correctly | Pass | `arb-dir: lib/l10n/arb` |
| `.gitignore` present | Pass | Standard Flutter `.gitignore` |
| `test/helpers/pump_app.dart` helper | Pass | Properly scaffolds theme, l10n, routing, and bloc mocks |

### Feature Directory Structure

Each feature follows a consistent pattern:

```
feature_name/
  feature_name.dart          # barrel export
  bloc/
    feature_bloc.dart        # bloc with part directives
    feature_event.dart       # part of bloc
    feature_state.dart       # part of bloc
    feature_bloc.mapper.dart # generated
  view/
    view.dart                # barrel export
    feature_page.dart        # provides bloc, extracts route params
    feature_view.dart        # UI, consumes bloc
```

This is consistent across all 7 features (app, home, menu_groups, menu_items, item_detail, cart, checkout, order_complete).

### App-Level Widgets

`lib/widgets/kiosk_header.dart` -- A kiosk-specific header widget placed in the app's own `widgets/` directory rather than in `very_yummy_coffee_ui`. This is correct because `KioskHeader` depends on `CartCountBloc` (a kiosk-specific bloc), so it cannot be placed in the shared UI package.

---

## UI Coding Standards Compliance

### Colors

- **No raw hex literals** (`Color(0xFFxxxxxx)`): Pass -- Zero instances in view code
- **No `Colors.xxx` from Material**: Pass -- Zero instances
- **All colors via `context.colors.xxx`**: Pass
- **One acceptable `Color()` usage**: `menu_groups_view.dart:95` uses `Color(group.color)` to construct a color from the `MenuGroup.color` int field. This is a data-driven color from the domain model, not a hardcoded design token. This is acceptable.

### EdgeInsets

- **No `EdgeInsets.fromLTRB`**: Pass -- Zero instances
- Uses `EdgeInsets.symmetric`, `EdgeInsets.only`, and `EdgeInsets.all` throughout

### Spacing and Radius

- **Uses `context.spacing.xxx`**: Pass -- All padding and gaps use spacing tokens
- **Uses `context.radius.xxx`**: Pass -- All `BorderRadius` values use radius tokens
- **[Suggestion] Raw numeric literals for sizing**: Several view files use raw numeric literals for fixed dimensions (e.g., `width: 520`, `height: 200`, `size: 64`, `fontSize: 88`). These are typically layout-specific sizes (panel widths, icon sizes, font size overrides) that do not correspond to spacing tokens. While not strictly violations (the CLAUDE.md rule says "when a spacing/radius token matches"), they could benefit from named constants if they appear in multiple places.

### Typography

- **No raw `TextStyle(fontFamily: ...)` construction**: Pass -- Zero instances
- **All text styles via `context.typography.xxx.copyWith(...)`**: Pass
- Uses `copyWith(fontSize: ...)` to adjust sizes from base styles, which is correct

### Navigation

- **All navigation via `context.go('/path')`**: Pass -- Zero instances of `context.push`, `context.pushNamed`, or `context.goNamed`
- All routes use hardcoded path strings as required

---

## Test Coverage Assessment

### Bloc Tests (8 files)

| Bloc | Test File | Coverage |
|---|---|---|
| AppBloc | `test/app/bloc/app_bloc_test.dart` | Initial state, connected, disconnected |
| MenuGroupsBloc | `test/menu_groups/bloc/menu_groups_bloc_test.dart` | Subscription success/failure |
| MenuItemsBloc | `test/menu_items/bloc/menu_items_bloc_test.dart` | Present |
| ItemDetailBloc | `test/item_detail/bloc/item_detail_bloc_test.dart` | All 7 events tested |
| CartBloc | `test/cart/bloc/cart_bloc_test.dart` | Subscription, quantity update |
| CartCountBloc | `test/cart_count/bloc/cart_count_bloc_test.dart` | Null order, sum, updates |
| CheckoutBloc | `test/checkout/bloc/checkout_bloc_test.dart` | Subscription, confirm success/failure |
| OrderCompleteBloc | `test/order_complete/bloc/order_complete_bloc_test.dart` | Subscription, back-to-menu |

### View/Widget Tests (8 files)

| View | Test File | Coverage |
|---|---|---|
| HomeView | `test/home/view/home_view_test.dart` | Renders, navigation, background image |
| MenuGroupsView | `test/menu_groups/view/menu_groups_view_test.dart` | Loading, error, success, navigation |
| MenuItemsView | `test/menu_items/view/menu_items_view_test.dart` | Loading, error, items, unavailable overlay |
| ItemDetailView | `test/item_detail/view/item_detail_view_test.dart` | Loading, detail, navigation, unavailable |
| CartView | `test/cart/view/cart_view_test.dart` | Loading, error, empty, items |
| CheckoutView | `test/checkout/view/checkout_view_test.dart` | Loading, payment card, error, navigation |
| OrderCompleteView | `test/order_complete/view/order_complete_view_test.dart` | Loading, success, tracker, back, error |
| KioskHeader | `test/widgets/kiosk_header_test.dart` | Title, subtitle, back button, cart badge |

### Test Helpers

- `pumpApp` correctly provides: `MaterialApp` with `CoffeeTheme.light`, l10n delegates, `MockGoRouter`, repository providers, and bloc providers
- `MockGoRouter` and `MockGoRouterProvider` correctly wrap `InheritedGoRouter`
- `TesterL10n` extension provides l10n access in tests

### [Suggestion] Missing Test: `AppRouter`

There is no dedicated test for `AppRouter` redirect logic (connecting -> home transition, disconnect redirect, order-complete exemption). While the redirect logic is relatively simple, edge cases around the order-complete exemption could benefit from targeted tests.

---

## Findings Summary

### Critical: 0

No critical architectural violations found.

### Important: 1

1. **[Important] `api_client` in `pubspec.yaml`** (`pubspec.yaml:11-12`) -- The app declares a direct dependency on the `api_client` data-layer package. While the import is confined to `main.dart` (composition root) and does not leak into feature code, this is technically a presentation-to-data layer dependency. This is consistent with other apps in the monorepo and is the accepted bootstrap pattern. **No action required** unless the team decides to extract composition-root wiring into a separate bootstrap package.

### Suggestions: 3

1. **[Suggestion] Raw numeric literals in views** -- Several view files use raw numbers for panel widths (`520`, `400`), icon sizes (`64`, `80`), and font size overrides (`88`, `28`, `36`, `32`). Consider extracting repeated values into named constants or additional design tokens if they appear in multiple locations.

2. **[Suggestion] Missing `AppRouter` redirect tests** -- The router redirect logic handles connecting state, disconnect redirect, and order-complete exemption. These edge cases would benefit from dedicated unit tests.

3. **[Suggestion] Duplicated `_SummaryRow` widget** -- Both `cart_view.dart` (line 304) and `checkout_view.dart` (line 198) define private `_SummaryRow` widgets with identical structure (label + formatted amount). Consider extracting this into a shared widget in `lib/widgets/` to reduce duplication.

---

## Verdict

**Architecture is clean. Ready to merge.**

The kiosk_app follows VGV architectural standards with high fidelity:

- Layer separation is respected (data layer access confined to composition root)
- All 8 blocs follow correct patterns with sealed events, immutable state, and proper scoping
- Dependency direction flows correctly: Presentation -> Domain -> Data
- Package structure is complete with analysis options, l10n, test helpers, and comprehensive tests
- UI coding standards are fully complied with (design tokens for colors, typography, spacing, radius)
- Navigation uses `context.go()` with hardcoded paths exclusively

The 1 important finding and 3 suggestions are non-blocking improvements. No violations require fixing before merge.
