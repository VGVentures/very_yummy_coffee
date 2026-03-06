# Test Quality Review -- kiosk_app

**Date**: 2026-03-05
**Reviewer**: Claude Opus 4.6 (automated)
**Branch**: `feat/kiosk-app`

---

## Coverage Summary

- **Test run**: PASS (74/74 tests pass, 0 failures)
- **Coverage**: Not computed (coverage collection failed due to tool permission; tests pass cleanly)
- **Test files**: 16 test files found
- **Source files with tests**: 16/16 testable units have corresponding test files

### Testable Unit Inventory

| Unit | Test File | Status |
|------|-----------|--------|
| `AppBloc` | `test/app/bloc/app_bloc_test.dart` | Has tests |
| `CartCountBloc` | `test/cart_count/bloc/cart_count_bloc_test.dart` | Has tests |
| `MenuGroupsBloc` | `test/menu_groups/bloc/menu_groups_bloc_test.dart` | Has tests |
| `MenuItemsBloc` | `test/menu_items/bloc/menu_items_bloc_test.dart` | Has tests |
| `ItemDetailBloc` | `test/item_detail/bloc/item_detail_bloc_test.dart` | Has tests |
| `CartBloc` | `test/cart/bloc/cart_bloc_test.dart` | Has tests |
| `CheckoutBloc` | `test/checkout/bloc/checkout_bloc_test.dart` | Has tests |
| `OrderCompleteBloc` | `test/order_complete/bloc/order_complete_bloc_test.dart` | Has tests |
| `KioskHeader` | `test/widgets/kiosk_header_test.dart` | Has tests |
| `HomeView` | `test/home/view/home_view_test.dart` | Has tests |
| `MenuGroupsView` | `test/menu_groups/view/menu_groups_view_test.dart` | Has tests |
| `MenuItemsView` | `test/menu_items/view/menu_items_view_test.dart` | Has tests |
| `ItemDetailView` | `test/item_detail/view/item_detail_view_test.dart` | Has tests |
| `CartView` | `test/cart/view/cart_view_test.dart` | Has tests |
| `CheckoutView` | `test/checkout/view/checkout_view_test.dart` | Has tests |
| `OrderCompleteView` | `test/order_complete/view/order_complete_view_test.dart` | Has tests |

### Missing Test Files

| File | Reason |
|------|--------|
| `lib/app/view/app.dart` (`App`, `_AppView`) | No test. Contains `BlocListener` that calls `orderRepository.clearCurrentOrder()` on `connected` -- this critical behavior is untested. |
| `lib/app/view/connecting_page.dart` | No test. Trivial widget (renders `CircularProgressIndicator`), low priority. |
| `lib/app/app_router/app_router.dart` | No test. Contains redirect logic, order-complete exemption, and route ordering (cart before `:groupId`). |
| `lib/home/view/home_page.dart` | No test. Thin page wrapper, low priority. |
| `lib/menu_groups/view/menu_groups_page.dart` | No test. Thin page with bloc provision, low priority. |
| `lib/menu_items/view/menu_items_page.dart` | No test. Thin page wrapper, low priority. |
| `lib/item_detail/view/item_detail_page.dart` | No test. Thin page wrapper, low priority. |
| `lib/cart/view/cart_page.dart` | No test. Thin page wrapper, low priority. |
| `lib/checkout/view/checkout_page.dart` | No test. Thin page wrapper, low priority. |
| `lib/order_complete/view/order_complete_page.dart` | No test. Thin page wrapper, low priority. |

---

## Pattern Compliance

### Correct Patterns (Good)

| Pattern | Compliance | Notes |
|---------|------------|-------|
| `blocTest` from `bloc_test` | All bloc tests use `blocTest` | No manual stream subscriptions |
| `mocktail` for mocks | All mocks use `mocktail` | No `mockito` usage |
| `pumpApp` helper | All widget tests use the shared `pumpApp` helper | Provides theme, l10n, routing, bloc scaffolding |
| `MockGoRouter` for navigation | Consistent across all view tests | Navigation assertions use `verify` on mock |
| `setUp`/`tearDown` | Used consistently in all test files | Shared setup is not duplicated |
| `group()` organization | All test files use top-level `group` and nested `group` for events | Clean structure |
| Seeded states | `ItemDetailBloc` tests correctly use `seed` for non-initial states | Good practice |

### Helper Infrastructure

The `pumpApp` helper in `test/helpers/pump_app.dart` is well-structured:
- Wraps widget in `MaterialApp` with `CoffeeTheme.light`
- Provides l10n delegates
- Provides `RepositoryProvider` for both `MenuRepository` and `OrderRepository`
- Provides `BlocProvider` for `AppBloc`
- Wraps in `MockGoRouterProvider` for navigation testing
- Calls `await pump()` after `pumpWidget` to settle the first frame

---

## Bloc/Cubit Test Quality

### `app_bloc_test.dart` -- Pass with Minor Gap

**Good:**
- Tests initial state correctly
- Tests both `connected` and `disconnected` emissions from `AppStarted`
- Uses `blocTest` with proper `build`/`act`/`expect` pattern

**Gap:**
- Missing: No test for stream error handling. `AppBloc._onStarted` uses `emit.forEach` without `onError`. If `connectionRepository.isConnected` emits an error, the bloc will throw. While the production code lacks error handling too, a test documenting this behavior would be valuable.

### `menu_groups_bloc_test.dart` -- Pass

**Good:**
- Initial state test
- Success path: emits `[loading, success]` with menu group data
- Failure path: emits `[loading, failure]` on stream error
- Uses meaningful test data with named constants

### `menu_items_bloc_test.dart` -- Pass

**Good:**
- Initial state test covers both `getMenuGroups` and `getMenuItems` mocks
- Success path tests `combineLatest2` behavior correctly
- Failure path covers stream error

**Minor note:** Only tests error on `getMenuGroups`. Does not test what happens when `getMenuItems` alone errors. Since `Rx.combineLatest2` propagates either error, this is acceptable but could be more thorough.

### `item_detail_bloc_test.dart` -- Pass (Best Test File)

**Good:**
- Comprehensive event coverage: `SubscriptionRequested`, `SizeSelected`, `MilkSelected`, `QuantityIncremented`, `QuantityDecremented`, `AddToCartRequested`
- Success and failure paths for `AddToCartRequested`
- Edge case: `QuantityDecremented` when quantity is 1 correctly expects empty emissions (min clamp)
- Uses `seed` for non-initial states
- Tests both "new order" path (`currentOrderId == null` triggers `createOrder`)

**Gap:**
- Missing: No test for `ItemDetailExtraToggled` event (toggle on and toggle off). The production code at `item_detail_bloc.dart:59-69` has add/remove logic for extras that is completely untested.
- Missing: No test for `AddToCartRequested` when `item` is null (line 92-95 of production code). This early-return-to-failure path is uncovered.
- Missing: No test for `AddToCartRequested` when `currentOrderId` is already set (skips `createOrder`). Only the "new order" path is tested.

### `cart_bloc_test.dart` -- Pass with Gap

**Good:**
- Initial state test
- `CartSubscriptionRequested` success and failure paths
- `CartItemQuantityUpdated` verifies repository interaction

**Gap:**
- Missing: No test for `CartItemQuantityUpdated` failure path. Production code at `cart_bloc.dart:36-38` catches exceptions and emits failure state, but this is untested.
- The `CartItemQuantityUpdated` test uses `verify` to check repository call but has empty `expect` -- it verifies interaction but not state transitions. This is acceptable for a fire-and-forget action, but the error path should be tested.

### `checkout_bloc_test.dart` -- Pass

**Good:**
- Initial state test
- `CheckoutSubscriptionRequested` success and failure paths
- `CheckoutConfirmed` success `[submitting, success]` and failure `[submitting, failure]` paths
- Proper use of `seed` for seeded state

**Gap:**
- Missing: No test for `CheckoutConfirmed` when `state.order` is null (line 36-39 of production code). This guard emits failure directly, bypassing `submitting`.
- Missing: No test for `CheckoutSubscriptionRequested` when order stream emits `null` (line 25-27). The production code treats null order as failure, but this path is untested.

### `order_complete_bloc_test.dart` -- Pass

**Good:**
- Initial state test
- `OrderCompleteSubscriptionRequested` success and failure paths
- `OrderCompleteBackToMenuRequested` correctly tests both state emission and repository interaction (`clearCurrentOrder` verified)
- Uses `seed` for seeded state

**Gap:**
- Missing: No test for `OrderCompleteSubscriptionRequested` when order stream emits `null` (line 25-26). Production code treats this as failure.

### `cart_count_bloc_test.dart` -- Pass (Very Good)

**Good:**
- Tests null order (emits 0 count)
- Tests quantity summation across multiple items
- Tests order update propagation (stream emitting multiple values)
- Good edge case coverage: item with explicit `quantity: 2` and item with default quantity

---

## Widget Test Quality

### `home_view_test.dart` -- Pass with Repetition Issue

**Good:**
- Tests brand name, tagline, start order button rendering
- Tests navigation on tap
- Tests background image rendering

**Issue:**
- Every single test repeats the same viewport setup boilerplate (6 lines: `physicalSize`, `devicePixelRatio`, `addTearDown`). This should be extracted to a shared helper or `setUp`. This is code duplication that makes tests harder to maintain.

### `menu_groups_view_test.dart` -- Pass

**Good:**
- Loading, failure, and success states tested
- Navigation on card tap verified
- Multiple groups rendered and verified

**Gap:**
- Missing: Does not test the `CartCountBloc` interaction (cart badge visible, tap navigates to cart). The view always shows `showCartBadge: true` on the `KioskHeader`, and `onCartTapped` calls `context.go('/home/menu/cart')`, but this is not tested.

### `menu_items_view_test.dart` -- Pass

**Good:**
- Loading, failure, and success states tested
- Unavailable item overlay tested
- Grid renders multiple items

**Gaps:**
- Missing: No test for navigation on item card tap. `_ItemCard` calls `context.go('/home/menu/$groupId/${item.id}')` on tap but this is never verified.
- Missing: No test that unavailable items are not tappable (`onTap: isAvailable ? ... : null`).
- Missing: No test for `BlocSelector<MenuGroupsBloc>` rendering the group name in the header.

### `item_detail_view_test.dart` -- Pass

**Good:**
- Loading state (item null) test
- Success state with split pane rendering
- Navigation on `added` status via `whenListen`
- Unavailable item disabling

**Gaps:**
- Missing: No test for size/milk/extras selection interactions (tap dispatches events to bloc).
- Missing: No test for quantity selector (increment/decrement buttons).
- Missing: No test for the `adding` status (loading indicator on button).
- Missing: No test for back button navigation.

### `cart_view_test.dart` -- Pass

**Good:**
- Loading, failure, empty cart, and populated cart states tested
- Empty cart shows "Your cart is empty" and "Browse Menu"

**Gaps:**
- Missing: No test for "Browse Menu" button tap navigation.
- Missing: No test for "Proceed to Checkout" button tap navigation.
- Missing: No test for quantity controls (increment, decrement, delete).
- Missing: No test for order summary panel rendering (subtotal, tax, total).

### `checkout_view_test.dart` -- Pass

**Good:**
- Loading state test
- Idle state shows fake payment card
- Place order button rendering
- Error state with order shows error message
- Success state navigates to confirmation via `whenListen`

**Gaps:**
- Missing: No test for "Place Order" button tap dispatching `CheckoutConfirmed` event.
- Missing: No test for submitting state (button shows loading indicator).
- Missing: No test for back button navigation to `/home/menu/cart`.

### `order_complete_view_test.dart` -- Pass (Best Widget Test File)

**Good:**
- Loading, success, failure states all tested
- Success state verifies hero panel ("Order Placed!") and order tracker steps
- Back to menu button dispatches `OrderCompleteBackToMenuRequested` event
- Navigation on `navigatingBack` status
- Error state has back button
- Uses viewport helper `setKioskViewport` (good pattern, should be shared)

**Minor:**
- Does not test cancelled order state (the view renders "Order was cancelled" text when `order.status == OrderStatus.cancelled`).

### `kiosk_header_test.dart` -- Pass (Very Good)

**Good:**
- Title rendering
- Subtitle rendering
- Back button absent by default
- Back button visible and tappable
- Cart badge with count
- Cart badge absent when `showCartBadge` is false
- Cart badge tap callback

This is the most thorough widget test file in the suite.

---

## Anti-Patterns Found

### 1. [Important] Missing `ItemDetailExtraToggled` test coverage

**File:** `test/item_detail/bloc/item_detail_bloc_test.dart`
**Issue:** The `ItemDetailExtraToggled` event is completely untested. This event has toggle logic (add if not present, remove if present) that could easily regress.
**Production code** (`item_detail_bloc.dart:59-69`):
```dart
void _onExtraToggled(ItemDetailExtraToggled event, Emitter<ItemDetailState> emit) {
  final extras = List<DrinkExtra>.from(state.selectedExtras);
  if (extras.contains(event.extra)) {
    extras.remove(event.extra);
  } else {
    extras.add(event.extra);
  }
  emit(state.copyWith(selectedExtras: extras));
}
```
**Fix:** Add two `blocTest` calls: one for toggling an extra ON, one for toggling it OFF.

### 2. [Important] No test for `App`/`_AppView` BlocListener behavior

**File:** Missing -- no `test/app/view/app_test.dart`
**Issue:** `_AppView` has a `BlocListener<AppBloc, AppState>` that calls `orderRepository.clearCurrentOrder()` when status becomes `connected`. This is a critical side effect (clears the kiosk order on reconnect) with zero test coverage.
**Fix:** Add a widget test for `_AppView` that verifies `clearCurrentOrder()` is called when `AppBloc` emits `connected`.

### 3. [Important] No test for `AppRouter` redirect logic

**File:** Missing -- no `test/app/app_router/app_router_test.dart`
**Issue:** `AppRouter` contains three important redirect rules:
1. Redirect to `/connecting` when disconnected (unless on order complete)
2. Redirect to `/home` when connected and on `/connecting`
3. Order complete screen exemption from disconnect redirect
These are tested nowhere. A bug in the redirect logic would break the entire app navigation.
**Fix:** Add unit tests for `AppRouter` redirect logic with mock `AppBloc` states.

### 4. [Important] Widget tests lack interaction coverage

**Files:** `cart_view_test.dart`, `item_detail_view_test.dart`, `menu_items_view_test.dart`, `checkout_view_test.dart`
**Issue:** Most widget tests only verify rendering (what is displayed), but do not test user interactions (tap, dispatch events). For example:
- `CartView`: No test taps the delete button, quantity +/- buttons, or "Proceed to Checkout"
- `ItemDetailView`: No test taps size/milk/extras options or quantity buttons
- `MenuItemsView`: No test taps an item card to navigate
- `CheckoutView`: No test taps "Place Order" button
**Fix:** Add `testWidgets` that tap interactive elements and verify the expected bloc event is dispatched or navigation occurs.

### 5. [Suggestion] Duplicated viewport setup in `home_view_test.dart`

**File:** `test/home/view/home_view_test.dart`
**Issue:** Every test repeats 6 lines of viewport configuration:
```dart
tester.view.physicalSize = const Size(1366, 1024);
tester.view.devicePixelRatio = 1.0;
addTearDown(() {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
});
```
Meanwhile `order_complete_view_test.dart` already has a `setKioskViewport` helper but it is local to that file.
**Fix:** Extract `setKioskViewport` to `test/helpers/` and reuse across all view tests that need the kiosk viewport.

### 6. [Suggestion] Missing error-path tests in `CartBloc` and `CheckoutBloc`

**File:** `test/cart/bloc/cart_bloc_test.dart`, `test/checkout/bloc/checkout_bloc_test.dart`
**Issue:**
- `CartBloc.CartItemQuantityUpdated`: The `catch` block emitting failure is untested
- `CheckoutBloc.CheckoutConfirmed`: The null-order guard is untested
- `CheckoutBloc.CheckoutSubscriptionRequested`: The null-order-from-stream path is untested
**Fix:** Add `blocTest` with error-throwing mocks for these edge cases.

### 7. [Suggestion] `CartView` does not test order summary rendering

**File:** `test/cart/view/cart_view_test.dart`
**Issue:** The `_OrderSummaryPanel` shows subtotal, tax, total, and a "Proceed to Checkout" button. None of these elements are verified in the test.
**Fix:** Add assertions for order summary values and checkout button rendering.

### 8. [Suggestion] `CheckoutView` tests do not verify failure-without-order state

**File:** `test/checkout/view/checkout_view_test.dart`
**Issue:** Production code at `checkout_view.dart:29-35` renders a different failure UI when `state.order == null` vs when `state.order != null`. Only the `order != null` failure path is tested (line 68-78). The `order == null` failure path (bare error text without retry) is untested.
**Fix:** Add a test with `CheckoutState(status: CheckoutStatus.failure)` (no order) and verify it renders `errorSomethingWentWrong`.

---

## Test Helpers Assessment

### `pump_app.dart` -- Good

The helper is well-designed and follows VGV conventions:
- Wraps in `MultiRepositoryProvider` and `MultiBlocProvider`
- Uses `MaterialApp` with proper theme (`CoffeeTheme.light`)
- Includes all l10n delegates
- Wraps in `MockGoRouterProvider` for navigation testing
- Defaults to mock implementations when not provided

**One improvement:** The `AppBloc` mock defaults to `_MockAppBloc()` with no default state. Tests that do not pass an `appBloc` get a mock that returns `null` for `state`. This could cause issues if any widget reads `AppBloc` state. Since no current tests hit this path, it is not a bug today, but could become one.

### `go_router.dart` -- Good

Clean `MockGoRouter` and `MockGoRouterProvider` implementation using `InheritedGoRouter`.

### `l10n.dart` -- Good

Extracts `AppLocalizations` from the `MaterialApp` for assertion purposes.

---

## Recommendations

### Critical Priority

1. **Add `ItemDetailExtraToggled` bloc tests** -- This is the only event handler in any bloc with zero test coverage. The toggle-on/toggle-off logic is a common source of bugs.

2. **Add `App`/`_AppView` test** -- The `clearCurrentOrder()` on reconnect behavior is a kiosk-critical feature. If it breaks, users will see stale orders after a network blip.

3. **Add `AppRouter` redirect tests** -- The router redirect logic controls the entire app navigation flow including the order-complete exemption from disconnect. A regression here is catastrophic.

### Important Priority

4. **Add interaction tests to widget tests** -- Most widget tests only verify rendering. Add tap tests for: cart quantity controls, item card navigation, checkout place order button, menu item card tap, size/milk/extras selection.

5. **Add error-path bloc tests** -- Cover `CartBloc.CartItemQuantityUpdated` failure, `CheckoutBloc.CheckoutConfirmed` null-order guard, and `CheckoutBloc.CheckoutSubscriptionRequested` null-order stream.

### Nice-to-Have

6. **Extract `setKioskViewport` helper** to `test/helpers/` to reduce duplication.

7. **Test cancelled order state** in `OrderCompleteView` (the production code renders a cancelled message that is untested).

8. **Add failure-without-order test** for `CheckoutView`.

---

## Verdict

**Needs work before merging.** The test suite has a solid foundation -- all 8 blocs and all 8 views plus the KioskHeader widget have test files with passing tests. Pattern compliance with VGV standards (`blocTest`, `mocktail`, `pumpApp`, `group` organization) is excellent.

However, there are **3 critical gaps** that should be addressed:
1. `ItemDetailExtraToggled` event handler has zero test coverage
2. `App`/`_AppView` BlocListener behavior (`clearCurrentOrder` on reconnect) is untested
3. `AppRouter` redirect logic is untested

And **2 important gaps**:
4. Widget tests largely verify rendering but not user interactions
5. Several bloc error paths are uncovered

**Estimated effort to reach quality bar:** 2-4 hours to add the critical tests; a full day to bring interaction coverage up to standard.
