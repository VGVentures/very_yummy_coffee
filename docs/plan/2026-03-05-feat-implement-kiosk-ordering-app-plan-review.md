---
title: "Simplicity Review: feat: implement kiosk ordering app"
date: 2026-03-05
subject: docs/plan/2026-03-05-feat-implement-kiosk-ordering-app-plan.md
---

# Simplicity Review: Kiosk Ordering App Plan

## Simplification Analysis

### Core Purpose

Create a new Flutter kiosk app (`applications/kiosk_app`) that lets customers
self-order on a landscape tablet. The app navigates a fixed 8-screen flow:
splash → menu groups → menu items → item detail → cart → checkout → order
complete. It reuses all existing shared packages and blocs with no backend
changes.

---

### Unnecessary Complexity Found

#### 1. CartCountBloc — justified but the plan's stated justification is
incorrect

The plan (lines 74–85) defends `CartCountBloc` by saying hoisting `CartBloc`
to `MenuGroupsPage` would "give all menu screens access to cart mutations."
This is technically true but not the real reason it's a problem. The actual
issue is that `CartBloc` subscribes to `currentOrderStream` and also handles
`CartItemQuantityUpdated` events — scoping it higher would leave the
subscription open across screens that don't need write access, and the Bloc
would be closed when `MenuGroupsPage` is popped, which could prematurely
cancel the stream.

`CartCountBloc` is well-justified and minimal (one event, one state field).
No change needed, but the plan's explanation should accurately reflect that
read-only separation is the correct reason.

#### 2. Group title in MenuItemsView — plan proposes accessing MenuGroupsBloc
from parent (Phase 4, line 370; Risk Analysis line 741)

The plan suggests that `MenuItemsView` get the group title by reaching up to
`MenuGroupsBloc` in the parent widget tree:

> "MenuItemsView can get the group title by subscribing to MenuGroupsBloc which
> is provided by MenuGroupsPage (parent in widget tree). Use
> BlocSelector<MenuGroupsBloc, MenuGroupsState, String?> for the group name."

This is unnecessary. `MenuItemsBloc` — which is _already_ identical to
mobile_app — already fetches the group via
`Rx.combineLatest2(getMenuGroups(), getMenuItems(groupId))` and stores it as
`MenuItemsState.group` (see `mobile_app/lib/menu_items/bloc/menu_items_state.dart:11`).

`MenuItemsView` can simply read `state.group?.name` from its own `MenuItemsBloc`
state. Cross-reading `MenuGroupsBloc` from `MenuItemsView` would couple two
sibling blocs and add unnecessary cross-bloc dependency. The plan should remove
any mention of accessing `MenuGroupsBloc` from `MenuItemsView`.

**Fix:** In the Phase 4 `MenuItemsView` layout pseudocode, change:

```dart
// WRONG (plan's suggestion):
title: state.groupName ?? '',   // from MenuGroupsBloc via context.read

// RIGHT (use own bloc state):
title: state.group?.name ?? '',  // from MenuItemsBloc.state.group
```

This is a correctness issue, not just a style issue. The cross-bloc read also
adds a hidden runtime failure mode: if `MenuGroupsBloc` hasn't loaded by the
time `MenuItemsView` builds, `context.read<MenuGroupsBloc>()` can throw if the
Bloc isn't in scope.

#### 3. `height` parameter on `KioskHeader` — premature generalization

The `KioskHeader` API includes `this.height = 100` as a configurable
parameter (plan line 141). Phase 3 immediately overrides it to `120` for
`MenuGroupsPage`.

Two different heights across the 8 screens suggests there is no stable default
— the height is always overridden at each call site. A configurable height
adds a parameter that every implementer must reason about, without a clear
rule for what value to pass.

Simpler approach: remove `height` from the constructor entirely. Let the
header size itself around its content (no fixed height), which is the standard
Flutter approach. If two screens genuinely need visual differentiation, that
comes from different padding or subtitle presence, not a hard-coded pixel
height. If pixel-perfect control is required by the design, use `const`-named
height values internal to `KioskHeader` itself rather than exposing it as a
parameter.

**Estimated LOC reduction:** 1 parameter + removal of all call-site overrides
(3–5 sites).

#### 4. `_onBackToMenu` note about `clearCurrentOrder()` being a no-op (lines
639–641)

The plan notes (correctly) that by the time the customer reaches Order
Complete, `submitCurrentOrder()` has already nulled `_currentOrderId`, so
`clearCurrentOrder()` is a no-op and is "retained as a defensive measure."

Defensive no-op calls that need inline comments explaining why they exist are
a code smell. The comment itself is the sign that the call shouldn't be there.
If the method is a no-op, remove the call. If there is a legitimate defensive
concern (e.g., a crash mid-checkout could leave `_currentOrderId` set), that
scenario is better handled in the router's reconnect guard (which the plan
already addresses in the "Reconnect" finding). The Order Complete back button
should not duplicate that concern.

**Recommendation:** Remove the `clearCurrentOrder()` call from
`_onBackToMenu`. Rely on the router's reconnect guard (already in the plan) to
handle the stale-ID scenario. Delete the defensive-comment explanation.

**Estimated LOC reduction:** 2–3 lines of call + comment.

#### 5. `subtitle` parameter on `KioskHeader` — used inconsistently

The `KioskHeader` constructor includes `this.subtitle` (plan line 135). Looking
at actual usage across the 8 screens:

- Menu Groups: `subtitle: l10n.homeWhatWouldYouLike` (used)
- Menu Items: no subtitle (uses only title)
- Item Detail: no subtitle (uses only title)
- Cart: `subtitle: l10n.cartItemCount(itemCount)` (used)
- Checkout: `subtitle: '${itemCount} items · $total'` (used)
- Order Complete: no subtitle (no KioskHeader)

That is 3 of 4 applicable screens using subtitle and 1 not — the parameter
is warranted. No change needed here.

#### 6. Phase 9 test for `cart_count_bloc_test.dart` — necessary and correct

The plan calls for a `CartCountBloc` unit test (Phase 9, line 544). This is
the only new bloc without a direct mobile_app equivalent. The test is
justified.

#### 7. Home screen background image via `Image.network` — a YAGNI concern

The plan specifies (Phase 2, lines 267–279):

```
Image.network(bgImageUrl, fit: BoxFit.cover)  // Unsplash coffee photo
```

with an `errorBuilder` falling back to solid primary color.

For a kiosk that runs in a fixed in-store environment, network image loading
adds a fragile dependency (network round-trip on app start, Unsplash CDN
availability). An asset image bundled in the app is simpler, faster, and
reliable. The `Image.network` + `errorBuilder` pattern adds code complexity
specifically to handle a failure mode that wouldn't exist with an asset.

This is a YAGNI violation: the plan adds `errorBuilder` fallback handling for
a scenario that only exists because of a previous unnecessary choice (network
image instead of bundled asset).

**Recommendation:** Use `Image.asset` with a bundled coffee photo. Remove the
`errorBuilder`. The plan should note this as a decision, or at minimum document
that the Unsplash URL approach introduces an unnecessary network dependency.

---

### Code to Remove

| Location | Reason | Estimated LOC |
|---|---|---|
| `KioskHeader` constructor `height` param + all call-site overrides | No stable default; Flutter sizes around content | -6 to -8 |
| `_onBackToMenu` `clearCurrentOrder()` call + its explanatory comment | No-op by the time it's called; router guard handles the real scenario | -3 |
| Phase 4 note about reading `MenuGroupsBloc` from `MenuItemsView` (plan doc) | Incorrect; `MenuItemsBloc.state.group` already has the data | plan doc only |
| `Image.network` errorBuilder in `HomeView` (if asset image chosen) | Eliminated by using `Image.asset` | -5 to -8 |

---

### Simplification Recommendations

#### 1. Remove `height` from `KioskHeader` API
- **Current:** `KioskHeader` accepts `this.height = 100`; Phase 3 overrides to
  `120`, other phases use different values
- **Proposed:** No `height` parameter. The header sizes to its content. All
  screens get consistent height via the same padding tokens.
- **Impact:** Removes a magic-number API surface; eliminates per-screen
  height management; ~8 LOC saved across call sites.

#### 2. Fix group title source in `MenuItemsView`
- **Current:** Plan suggests `BlocSelector<MenuGroupsBloc, ...>` or
  `context.read<MenuGroupsBloc>()` for the group name
- **Proposed:** Use `state.group?.name` from `MenuItemsBloc.state` (already
  populated by the copied-identical bloc)
- **Impact:** Removes a cross-bloc dependency; eliminates a hidden failure mode;
  0 extra LOC, just uses correct state field.

#### 3. Remove `clearCurrentOrder()` from `_onBackToMenu`
- **Current:** `_onBackToMenu` calls `clearCurrentOrder()` with a comment
  acknowledging it is a no-op
- **Proposed:** Remove the call and comment. The router reconnect guard already
  handles the stale-ID scenario.
- **Impact:** 3 fewer lines; no defensive-comment cognitive load.

#### 4. Bundle the home screen background as an asset
- **Current:** `Image.network(unsplashUrl)` + `errorBuilder`
- **Proposed:** `Image.asset('assets/images/kiosk_bg.jpg')` with asset
  registered in `pubspec.yaml`
- **Impact:** Removes network dependency; removes `errorBuilder`; ~6 fewer
  lines; more reliable on startup.

---

### YAGNI Violations

#### `Image.network` + `errorBuilder` on `HomeView`
- **Violation:** Adding fallback-handling code for a failure mode introduced
  by an unnecessary architectural choice (network image in a fixed kiosk
  environment)
- **What to do instead:** Bundle the asset. No fallback needed.

#### `height` parameter on `KioskHeader`
- **Violation:** Exposing a configuration knob for a property that doesn't
  have a single correct default and will be overridden at every call site
- **What to do instead:** Let Flutter size the widget naturally around its
  content, or define kiosk-internal height constants inside the widget itself

---

### Plan Strengths (no changes needed)

The following aspects of the plan are well-reasoned and should be kept as-is:

- **`CartCountBloc` at `MenuGroupsPage` scope.** Correct placement. The
  alternative approaches (hoist `CartBloc`, use route `extra`) are correctly
  rejected with sound reasoning.
- **User flow analysis findings.** All six findings (route ordering, order
  complete redirect exemption, `PopScope`, post-add navigation, reconnect guard,
  checkout button disabled when empty) are real bugs caught pre-implementation.
  These are valuable.
- **No shared bloc package.** Correctly rejected. The divergence between kiosk
  and mobile navigation targets means blocs would need per-app configuration,
  eliminating the benefit of sharing.
- **No `HomeBloc`.** Static splash with no state is correctly implemented as a
  `StatelessWidget`. The mobile app's `HomeBloc` subscribes to `ordersStream`
  for active order tracking — the kiosk has no such feature on its splash, so
  the bloc is genuinely unnecessary.
- **`KioskHeader` kept internal to `kiosk_app`.** Correct. It should not go
  into `very_yummy_coffee_ui` because it reads `CartCountBloc` from the widget
  tree (a domain concern), which would violate the shared UI package's
  no-repository-dependency constraint.
- **Phase ordering.** Scaffolding header/CartCountBloc before screens (Phase 1
  before Phase 2) is the correct build order given the header appears on most
  screens.
- **All 9 test files.** Coverage is appropriate and not over-specified. No
  unnecessary test helpers beyond the existing `pumpApp` pattern.

---

### Final Assessment

**Total potential LOC reduction:** ~5% of planned implementation
(concentrated in 2–3 specific decisions rather than systemic over-engineering)

**Complexity score:** Low — the plan is already minimal and closely follows
the established mobile_app pattern

**Recommended action:** Minor tweaks only. The plan is ready to implement
after addressing the `MenuItemsView` group-title source (correctness fix) and
optionally applying the `KioskHeader` height and `clearCurrentOrder` cleanup.
The network image recommendation is lower priority but worth discussing before
implementation begins.

The one issue that MUST be fixed before implementation is the cross-bloc
`MenuGroupsBloc` read in `MenuItemsView` — it is factually incorrect given
that `MenuItemsBloc.state.group` already carries the group name via the
existing `combineLatest2` in the mobile_app bloc that the kiosk will copy
verbatim.
