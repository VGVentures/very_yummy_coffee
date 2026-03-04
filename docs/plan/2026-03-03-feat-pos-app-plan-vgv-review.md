---
title: "VGV Engineering Review: feat/pos-app plan"
date: 2026-03-03
reviewed_plan: docs/plan/2026-03-03-feat-pos-app-plan.md
---

## VGV Code Review

### Summary

The plan is architecturally sound and demonstrates a strong grasp of the existing codebase patterns. The author correctly identified the `completeOrder` status-guard issue early, correctly resolves it with `submitCurrentOrder()`, and correctly separates `MenuBloc` + `OrderTicketBloc` responsibilities for the split-panel screen. The navigation approach (`context.go` with hardcoded strings), Bloc-over-Cubit rule, shared-UI dependency constraint, and `emit.forEach` for stream subscriptions are all addressed. However, two critical issues must be resolved before implementation begins: a race condition in the receipt screen's null-order handling, and ambiguous pseudocode in the Clear handler. Several naming violations (event suffixes), a missing repository dependency in `MenuBloc`, a missing widget test event definition, and two absent dev_dependencies also need to be fixed.

---

### Critical — Must Fix Before Implementation

**[Plan, Phase 5 — `PosOrderCompleteBloc` stream handler]** — Race condition: `order == null` treated as failure before the server WS push arrives.

The plan specifies:
```dart
onData: (order) => order == null
    ? state.copyWith(status: PosOrderCompleteStatus.failure)
    : state.copyWith(order: order, status: PosOrderCompleteStatus.success),
```

`OrderTicketBloc._onCharged` calls `submitCurrentOrder()` (a fire-and-forget WS send) and immediately emits `navigateToOrderId`, which triggers `context.go('/pos-order-complete/$orderId')`. The `PosOrderCompleteBloc` then subscribes to `orderRepository.orderStream(orderId)`, which is derived from `ordersStream`. `ordersStream` uses a `BehaviorSubject` seeded with `Orders(orders: [])`, so the first event it replays is an empty list. `orderStream(orderId)` maps that to `null`. Under the plan's current handler, this instantly emits `status: failure` before the server has had a chance to acknowledge `submitCurrentOrder()` and broadcast the updated order list.

This is a real crash-class UX bug: every charge operation would briefly flash a failure state on the receipt screen.

Comparing to `mobile_app/lib/order_complete/bloc/order_complete_bloc.dart`: the existing `OrderCompleteBloc` has the identical problem in the base. The fix must be applied in `PosOrderCompleteBloc`.

Fix — treat `null` order as a loading condition until the first non-null value has been received:
```dart
onData: (order) {
  if (order == null) {
    // Remain in loading while awaiting the first server broadcast.
    // Only transition to failure if a valid order was previously received
    // and has since disappeared (should not happen in normal flow).
    return state.status == PosOrderCompleteStatus.loading
        ? state
        : state.copyWith(status: PosOrderCompleteStatus.failure);
  }
  return state.copyWith(order: order, status: PosOrderCompleteStatus.success);
},
```
Add this logic explicitly to the plan's `PosOrderCompleteBloc` specification.

---

**[Plan, Phase 4 — `OrderTicketCleared` handler, lines ~296-298]** — Non-compilable pseudocode will mislead the implementer.

The plan contains:
```dart
void _onCleared(...) {
  final orderId = _orderRepository.currentOrderId;
  if (orderId != null) _orderRepository.cancelOrder(orderId);
  _orderRepository._currentOrderId = null; // not directly accessible — see note
  // Alternative: add a clearCurrentOrder() method to OrderRepository
}
```

`_orderRepository._currentOrderId` is a private field. This snippet does not compile. The comment immediately below says to use the alternative. Having both in the plan creates a decision point where none should exist: `clearCurrentOrder()` is already identified as the correct approach and is fully defined later in the plan. The invalid snippet should be removed entirely, and the handler should show only the `clearCurrentOrder()` call:
```dart
void _onCleared(...) {
  _orderRepository.clearCurrentOrder();
}
```

---

### Important — Should Fix

**[Plan, Phase 4 — Event naming throughout `OrderTicketBloc`]** — Event names use past tense instead of the VGV imperative/requested suffix.

VGV convention: command events (initiated by user action) end with `Requested`, `Submitted`, or an imperative verb. Past-tense names (`Created`, `Charged`, `Cleared`) describe something that already happened — they are appropriate for reactive events from external sources, not UI-initiated commands.

Current plan:
- `OrderTicketOrderCreated` — reads as "an order was created externally"
- `OrderTicketCharged` — reads as "a charge happened"
- `OrderTicketCleared` — reads as "a clear happened"

Required names:
- `OrderTicketOrderCreateRequested` (user taps "New Order")
- `OrderTicketChargeRequested` (user taps "Charge")
- `OrderTicketClearRequested` (user taps "Clear")
- `OrderTicketItemRemoved` is acceptable (reactive to item removal action)

All event handler method names must also update: `_onOrderCreateRequested`, `_onChargeRequested`, `_onClearRequested`.

---

**[Plan, Phase 3 — `MenuBloc` constructor]** — `OrderRepository` dependency is not listed.

The plan states: "`MenuItemTapped` handler — delegates to `orderRepository.addItemToCurrentOrder(...)`. No orderId needed; the repository tracks it." However, the `MenuBloc` constructor snippet does not include `OrderRepository`. If `MenuBloc` dispatches to `orderRepository`, it must declare `OrderRepository` as a constructor dependency. Its test mock setup must also include a mock `OrderRepository`.

The mobile app reference (`MenuItemsBloc`) does not call `OrderRepository` directly — menu blocs in the mobile app only subscribe to menu streams and leave item-add logic to a cart bloc. The POS plan deviates from this by giving `MenuBloc` dual responsibility (menu subscription + order mutation). This is a design choice, but it must be made explicit. Either:

Option A — `MenuBloc` receives `OrderRepository` and calls `addItemToCurrentOrder()` in its `MenuItemTapped` handler. Add `OrderRepository` to the constructor.

Option B — `MenuBloc` does not know about orders. `MenuItemTapped` carries the `MenuItem` as payload. `PosOrderPage` uses a `BlocListener` that catches `MenuItemTapped` (or a new `MenuItemSelected` state flag) and dispatches an `OrderTicketItemAddRequested` event to `OrderTicketBloc`. This keeps `MenuBloc` a pure menu-display bloc.

Option B is more consistent with VGV layer separation (each bloc owns one domain), but Option A is simpler. The plan must pick one and show the correct constructor. Currently it implies Option A without declaring the dependency.

---

**[Plan, Phase 7 — `OrderTicket` widget / `OrderTicketBloc`]** — Quantity stepper referenced in UI but no corresponding event defined.

Phase 7 describes: "List of `OrderTicketLineItem` rows (item name, price, quantity stepper via `updateItemQuantity`)". Phase 4's `OrderTicketBloc` event list contains only `OrderTicketItemRemoved` — there is no `OrderTicketItemQuantityUpdated` event. The plan is internally inconsistent: the widget implies a user interaction that the bloc cannot handle.

Fix: Either add `OrderTicketItemQuantityUpdated(String lineItemId, int quantity)` as an event with a handler that calls `_orderRepository.updateItemQuantity(lineItemId, quantity)`, or remove the quantity stepper from Phase 7 scope and replace it with remove-only. The latter is recommended (see the existing simplicity review); the acceptance criteria only require that items are shown with "name, price, and quantity", not that quantity is adjustable in-place.

---

**[Plan, Phase 1 — `pubspec.yaml` dev_dependencies]** — `bloc_lint` is missing.

The kds_app (`applications/kds_app/pubspec.yaml`) includes `bloc_lint: ^0.3.6` in dev_dependencies. This enforces Bloc-specific lint rules (e.g., Bloc event/state class sealing, event handler naming). The plan's proposed pubspec does not include it. This is a VGV standard.

Fix: Add `bloc_lint: ^0.3.6` to dev_dependencies.

---

**[Plan, Phase 1 — `pubspec.yaml` dev_dependencies]** — `nested` is missing.

The kds_app includes `nested: ^1.0.0` in dev_dependencies. It is required for multi-level `RepositoryProvider`/`BlocProvider` nesting in widget tests. Since the plan requires widget tests with `pumpApp`, and `pumpApp` typically uses `nested`, it must be included.

Fix: Add `nested: ^1.0.0` to dev_dependencies.

---

**[Plan, Phase 4 — `navigateToOrderId` in `OrderTicketState`]** — Navigation flag is never reset; re-push of `PosOrderPage` will re-trigger navigation.

The plan uses `navigateToOrderId: orderId` on the state to trigger a `BlocListener`-driven `context.go`. If the same `OrderTicketBloc` instance is preserved across a `context.go` back to `/pos-order` (e.g., because it lives in the `MultiRepositoryProvider` above the router), the state still holds a non-null `navigateToOrderId`. On re-render, the listener fires again and re-navigates to the receipt screen.

This is a well-known "flag state" problem. The plan must either:

A — Add an `OrderTicketNavigationConsumed` event that resets `navigateToOrderId` to null, fired from within the `BlocListener.listener` callback immediately after `context.go`.

B — Remove `navigateToOrderId` entirely and use `OrderTicketStatus.success` as the trigger (see the simplicity review for the full recommendation). This is the cleaner solution and matches how `CheckoutBloc` drives navigation.

The plan must specify one of these approaches explicitly.

---

**[Plan, Phase 5 — `navigateToNewOrder: bool` in `PosOrderCompleteState`]** — Same navigation flag problem, acknowledged but not resolved.

Same issue as above but for `PosOrderCompleteState`. The plan notes that `context.go('/pos-order')` replaces the stack and destroys the Bloc, which prevents the re-trigger. This is correct reasoning — but it is an implicit safety assumption that must be called out explicitly in the plan, because if the navigation ever changes to `context.push` or the Bloc is hoisted above the router, the bug reappears silently.

Fix: Add an explicit callout in the plan: "This flag is safe only because `context.go` replaces the entire navigation stack, destroying this Bloc. Do not change to `context.push`."

---

**[Plan, Phase 1 — `pubspec.yaml` dependencies]** — `rxdart` version must be verified against workspace constraints.

The plan specifies `rxdart: ^0.28.0`. The workspace's shared packages (`menu_repository`, `order_repository`) also depend on `rxdart`. If the constraints in those packages differ, pub resolution will fail. Before pinning a version in the plan, confirm it matches the existing workspace constraint.

Action: Read `shared/menu_repository/pubspec.yaml` and `shared/order_repository/pubspec.yaml`, confirm the version, and use the same constraint. If `rxdart` is only used inside `MenuBloc` via `Rx.combineLatest2`, consider whether it belongs in the app layer at all (the simplicity review recommends removing it by switching to a single-stream `getMenuGroupsAndItems()` method).

---

**[Plan — State class snippets throughout]** — `@MappableClass()` annotation is absent from all state class definitions.

Every state class in the existing codebase uses `dart_mappable` (confirmed in `kds_app/lib/app/bloc/app_state.dart`, `kds_bloc.dart` reference files). The plan's state snippets show plain Dart class syntax with no `@MappableClass()` decoration, no `part` directive, and no `with XxxStateMappable` mixin. Implementers following the plan literally will produce classes that fail code generation.

Fix: Every state class snippet in the plan must include:
```dart
@MappableClass()
final class MenuState with MenuStateMappable {
  const MenuState({...});
  // fields
}
```
And every event file must include a `sealed class XxxEvent` with `@MappableClass()` on each subclass. Add a note that `dart pub run build_runner build` must be run after creating each `bloc/` directory, not just at the end of each phase.

---

**[Plan, Phase 6 — Route parameter extraction]** — Bang operator on `state.pathParameters['orderId']!` with no fallback.

The plan specifies:
```dart
final orderId = state.pathParameters['orderId']!;
```

A bang on a map lookup crashes with a `Null check operator used on a null value` error if the route is misconfigured or the key name changes. This is a 🔴 VGV null-safety violation.

Fix: Guard the extraction with a null-check and redirect fallback:
```dart
final orderId = state.pathParameters['orderId'];
if (orderId == null) return; // or context.go('/pos-order') as error recovery
```
Document this pattern in the plan.

---

### Suggestions — Nice to Have

**[Plan, Phase 3 — `MenuState.selectedGroupId: null` semantics]** — Document the null-as-sentinel invariant.

Using `null` to mean "All" is implicit. Add a code comment in the plan's state snippet: `// null means 'All' tab selected`. This prevents a future developer from interpreting null as "not yet initialized."

---

**[Plan, Phase 7 — `PosTopBar` clock stream]** — Explicitly require `StatefulWidget` with `initState`.

The plan references the `KdsTopBar` clock pattern correctly. Add a one-line callout in the plan: "Must use `StatefulWidget`; create `_clockStream` in `initState` to avoid spawning a new `Stream.periodic` on every `build()` call." This is the subtlety that distinguishes correct from incorrect clock implementations.

---

**[Plan, Phase 8 — Widget tests deferred entirely]** — Required widget test items should appear in each phase checklist.

All widget tests are in Phase 8 ("Polish & CI"). Under schedule pressure, Phase 8 is the first thing cut. At minimum, one mandatory widget test item per screen should appear in the checklist for the phase that builds that screen's view:

- Phase 5 checklist: "Widget test: `PosOrderPage` renders `CircularProgressIndicator` in loading state"
- Phase 6 checklist: "Widget test: `PosOrderCompletePage` renders order details in success state"
- Phase 7 checklist: "Widget test: `PosOrdersPage` renders empty active-orders state"

This keeps tests as a first-class deliverable in each phase rather than a cleanup afterthought.

---

**[Plan — `PosOrdersBloc` is a structural duplicate of `KdsBloc`]** — Document intentional duplication.

`PosOrdersBloc` and `KdsBloc` are near-identical (subscribe to `ordersStream`, filter by status, emit categorized lists). This is correct — extracting a shared base class would create the wrong abstraction (the two apps have different filter criteria and different UI concerns). Add a comment in the plan explicitly noting: "This bloc intentionally duplicates `KdsBloc`'s structure. Do not extract a shared base class." This prevents a well-meaning reviewer from blocking implementation to ask why the duplication was not abstracted.

---

### Simplicity Assessment

- Lines that could be removed: Approximately 5-8% of planned implementation (primarily the quantity stepper widget and the two navigation flag fields if simplified as recommended).
- Unnecessary abstractions: None. The `MenuBloc` + `OrderTicketBloc` split is justified by genuinely independent lifecycles.
- YAGNI violations: The quantity stepper (`updateItemQuantity` UI) is not required by any acceptance criterion.
- Complexity verdict: Minor tweaks needed — the navigation flag fields and the quantity stepper are the primary targets.

Note: The simplicity review at `docs/plan/2026-03-03-feat-pos-app-plan-review.md` covers these in depth and recommends a `getMenuGroupsAndItems()` single-stream approach that removes `Rx.combineLatest2` from the app layer. That recommendation stands and is complementary to this review.

---

### Testing Assessment

- New code with tests: Bloc tests planned for all 5 Blocs (AppBloc, MenuBloc, OrderTicketBloc, PosOrderCompleteBloc, PosOrdersBloc). Correct.
- Test quality: The plan does not specify which edge cases each Bloc test must cover. The following are required and must be added to the plan:

  `MenuBloc`:
  - `MenuSubscriptionRequested` emits `loading` then `success` with groups and items.
  - `MenuCategorySelected` with a group ID filters visible items.
  - `MenuCategorySelected` with `null` shows all items.
  - Stream error emits `failure`.
  - `MenuItemTapped` on an unavailable item is a no-op (confirm this is a UI guard, not a Bloc guard; if it is a Bloc guard, test it here).

  `OrderTicketBloc`:
  - `OrderTicketChargeRequested` with empty ticket is a no-op (no emit beyond current state).
  - `OrderTicketChargeRequested` with `currentOrderId == null` is a no-op.
  - `OrderTicketChargeRequested` with a valid order emits `charging` then `success`.
  - `OrderTicketClearRequested` with no current order is a no-op.
  - `OrderTicketItemRemoved` with a valid `lineItemId` calls `removeItemFromOrder`.

  `PosOrderCompleteBloc`:
  - First stream event of `null` stays in `loading` (the race condition fix from Critical section).
  - Non-null order emits `success`.
  - Subsequent `null` after `success` emits `failure`.
  - `PosOrderCompleteNewOrderPressed` triggers navigation state.

  `PosOrdersBloc`:
  - Active and terminal order filtering with mixed-status order list.
  - Empty order list emits `success` with empty arrays (not `failure`).

- Bloc test coverage: Planned but edge cases are not specified. Add the above.
- Widget test coverage: Deferred to Phase 8. This is a risk. Recommend moving at least one mandatory widget test into each page's implementation phase.
