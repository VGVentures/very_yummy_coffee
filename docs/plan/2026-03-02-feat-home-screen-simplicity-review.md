# Simplicity Review: feat/home-screen Implementation Plan

Reviewed against the existing codebase (branch `feat/home-screen`, commit `67394c3`).
This review focuses exclusively on over-engineering, YAGNI violations, and unnecessary
complexity. For correctness and testing concerns see
`2026-03-02-feat-home-screen-plan-review.md`.

---

## Simplification Analysis

### Core Purpose

Add a `/home` landing route that shows real-time active orders with a step tracker.
Extract the existing `_StatusTracker` private widget into the shared UI package so
both Home and OrderComplete screens can use it. Add `OrderStatus.ready` to the
model and backend. Redirect post-connection navigation from `/menu` to `/home`.

---

### Unnecessary Complexity Found

**1. `List<String> labels` on `OrderStepTracker` — unsafe API for a fixed-arity widget**

Location: Plan section 2.1

The plan proposes:

```dart
class OrderStepTracker extends StatelessWidget {
  const OrderStepTracker({
    required this.status,
    required this.labels, // always length 4
    super.key,
  });
  final List<String> labels;
```

The inline comment "always length 4" is the tell: this is not actually a variable-length
list. A `List<String>` parameter accepts 0, 1, or 20 labels with no compile-time error.
The widget will silently produce broken UI if the caller passes the wrong count.

The existing `_StatusTracker` in `order_complete_view.dart` (lines 166–172) builds the
labels list inline from four `context.l10n` keys. The shared widget should accept four
named string parameters instead:

```dart
class OrderStepTracker extends StatelessWidget {
  const OrderStepTracker({
    required this.status,
    required this.placedLabel,
    required this.brewingLabel,
    required this.readyLabel,
    required this.pickedUpLabel,
    super.key,
  });
```

This removes one `List` allocation per `build` call, makes caller mistakes impossible at
compile time, and self-documents the four steps without requiring a comment.

Impact: 0 net LOC change, but meaningfully safer and clearer API surface.

---

**2. `homeActiveOrdersCount` l10n key — no widget consumes it**

Location: Plan section 6

```arb
"homeActiveOrdersCount": "{count} active",
```

The plan's `HomeView` structure (section 4.2) describes five sub-widgets: `_HomeHeader`,
`_OrderCard`, `_EmptyState`, `_ErrorState`, and `_StartNewOrderBar`. None of them
explicitly use a count badge. If no widget renders this string, adding the key now is
dead localization surface. Add it when the widget that uses it is written.

Impact: Remove ~4 lines from the final ARB file.

---

**3. `homeYourOrdersLabel` l10n key — no widget consumes it**

Location: Plan section 6

```arb
"homeYourOrdersLabel": "Your Orders",
```

The described view structure has a `_HomeHeader` with a greeting and a list body, but
no "Your Orders" section heading is described in the plan. If this label is not rendered
by a named widget in section 4.2, it is unused. Add it when the widget that renders it
is defined.

Impact: Remove ~4 lines from the final ARB file.

---

**4. `homeOrderItemCount` ARB key duplicates existing `cartItemCount`**

Location: Plan section 6 vs. `applications/mobile_app/lib/l10n/arb/app_en.arb` line 31

The plan adds:

```arb
"homeOrderItemCount": "{count} {count, plural, =1{item} other{items}}"
```

The existing ARB file already has:

```arb
"cartItemCount": "{count, plural, =1{1 item} other{{count} items}}"
```

Both strings describe a count of items with identical pluralization semantics. The only
implementation difference is the ICU template structure — and the proposed new key
actually uses a non-standard double-substitution pattern (`{count}` outside the plural
selector) that diverges from the project's established pattern.

Use `context.l10n.cartItemCount(order.items.length)` in `_OrderCard`. This eliminates
the new key entirely, keeps localization consistent, and reduces translator burden.

Impact: Remove ~6 lines from the final ARB file.

---

**5. `_greeting()` instance method on `HomeView` — wrong layer and hardcodes English**

Location: Plan section 4.2

```dart
class HomeView extends StatelessWidget {
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';    // hardcoded English
    if (hour < 18) return 'Good afternoon';  // hardcoded English
    return 'Good evening';                   // hardcoded English
  }
```

Two problems here:

First, the method returns hardcoded English strings while plan section 6 adds l10n keys
for exactly these strings. The final implementation must use `context.l10n.homeGreetingMorning`
etc., not the literals shown in the snippet. The plan is internally inconsistent on this
point and risks the implementor copying the pseudocode verbatim and shipping
non-localized text.

Second, a pure computation with no dependency on widget state should not be an instance
method on a `StatelessWidget`. Declare it as a top-level private function:

```dart
String _greetingForHour(int hour) {
  if (hour < 12) return context.l10n.homeGreetingMorning;
  if (hour < 18) return context.l10n.homeGreetingAfternoon;
  return context.l10n.homeGreetingEvening;
}
```

Or, per the existing plan review (issue 5), move the greeting computation into
`HomeBloc` as a `HomeGreeting` enum value on `HomeState`, which makes it trivially
testable without the widget layer.

Impact: No LOC change, but prevents a localization bug.

---

**6. `_ErrorState` private widget class — likely unnecessary abstraction**

Location: Plan section 4.2

The plan lists `_ErrorState` as a key sub-widget. Looking at the equivalent failure UI
in `OrderCompleteView` (lines 24–46), the error state is a centered `Column` with one
`Text` and one `BaseButton`. For the Home screen, no retry action is described in the
acceptance criteria. The stream recovers automatically via the WS subscription; there is
nothing for the user to tap.

If the failure state is just a centered text label, inlining it directly in the
`BlocBuilder` is simpler and removes the need to name, define, and test a separate class:

```dart
if (state.status == HomeStatus.failure) {
  return Center(
    child: Text(
      context.l10n.errorSomethingWentWrong,
      style: context.typography.body.copyWith(
        color: context.colors.mutedForeground,
      ),
    ),
  );
}
```

If a retry button is needed, then `_ErrorState` as a class is justified. The plan should
clarify which it is.

Impact: ~10 LOC saved if inlined.

---

### Code to Remove

| Location | Reason | Estimated LOC reduction |
|---|---|---|
| Plan section 6 — `homeActiveOrdersCount` ARB key | No widget references it | ~4 lines |
| Plan section 6 — `homeYourOrdersLabel` ARB key | No widget references it | ~4 lines |
| Plan section 6 — `homeOrderItemCount` ARB key | Duplicates `cartItemCount` | ~6 lines |
| Plan section 4.2 — `_ErrorState` class | Can be inlined if no retry needed | ~10 lines |

Total estimated LOC reduction from final implementation: ~24 lines

---

### YAGNI Violations

**`markOrderReady` backend action with no current client trigger**

Location: Plan section 1.2

The plan adds the entire `markOrderReady` server action in `server_state.dart`, then
immediately notes: "No mobile UI trigger for this ticket — barista screen is future work.
The action is added so the enum is stable."

The `OrderStatus.ready` enum value must be added — the Home screen needs to display
orders in `ready` status. That is not the issue.

The issue is the server-side `handleAction` case. It adds ~8 lines of backend code with:

- Zero mobile tests (acknowledged in the Risks table)
- Zero mobile UI to trigger it
- No integration test path until a future ticket

The `ready` string in the JSON is already handled by `dart_mappable` on the client side
the moment the enum value is added — the server can receive and persist it via any
external tool. Adding the `handleAction` case now means shipping untested code that
cannot be exercised by any current flow.

Wait until the barista screen ticket. Add the enum value now (required for the Home
screen). Defer the `markOrderReady` case to when it can be triggered and tested.

Impact: Remove ~8 lines from `server_state.dart` that have zero coverage in this ticket.

---

### Simplification Recommendations

**1. Fix `OrderStepTracker` to use four named label parameters instead of `List<String>`**

- Current: `required this.labels` — a runtime-checked list with a comment saying "always length 4"
- Proposed: `required this.placedLabel`, `required this.brewingLabel`, `required this.readyLabel`, `required this.pickedUpLabel`
- Impact: Compile-time safety, self-documenting API, no runtime list allocation

**2. Reuse `cartItemCount` instead of adding `homeOrderItemCount`**

- Current: New ARB key with identical semantics to an existing key, plus non-standard ICU template syntax
- Proposed: Call `context.l10n.cartItemCount(order.items.length)` in `_OrderCard`
- Impact: Removes ~6 lines from ARB, enforces DRY across screens, reduces translator burden

**3. Remove `homeActiveOrdersCount` and `homeYourOrdersLabel` until a widget uses them**

- Current: Two ARB keys added proactively with no described rendering location
- Proposed: Add each key only when the widget that renders it is written
- Impact: Removes ~8 lines of dead localization strings

**4. Clarify `_greeting()` must use l10n keys, not string literals**

- Current: Plan section 4.2 shows hardcoded English; plan section 6 adds l10n keys for the same strings
- Proposed: Replace all `'Good morning'` / `'Good afternoon'` / `'Good evening'` literals in the pseudocode with `context.l10n.homeGreetingMorning` etc.
- Impact: Prevents a localization bug where the implementor copies pseudocode verbatim

**5. Defer `markOrderReady` server action to the barista screen ticket**

- Current: Backend action added now, no test coverage, no mobile trigger
- Proposed: Add `OrderStatus.ready` to the enum (required now); leave `handleAction` case for the barista screen
- Impact: Removes ~8 lines of untested server code from this ticket's diff

**6. Inline the error state if no retry button is needed**

- Current: `_ErrorState` private class with unclear contents
- Proposed: Inline a `Center(child: Text(...))` directly in the `BlocBuilder` failure branch
- Impact: ~10 fewer lines, one fewer class, eliminates a naming decision

---

### Final Assessment

Total potential LOC reduction: ~50 lines across server, ARB, and view files (roughly 15–20% of the new code this feature adds).

Complexity score: **Low** — the plan follows established project patterns well. The Bloc, Page, and View structure mirrors `OrderCompleteBloc`/`OrderCompletePage`/`OrderCompleteView` exactly and requires no new patterns. The over-engineering is limited to a few unused ARB keys, a premature server action, and a minor API safety gap on `OrderStepTracker`.

Recommended action: **Proceed with simplifications** — the five issues above (ordered by impact) should be addressed before implementation begins. The most impactful are:
1. Remove `markOrderReady` from this ticket (largest YAGNI violation)
2. Remove unused ARB keys (`homeActiveOrdersCount`, `homeYourOrdersLabel`)
3. Reuse `cartItemCount` instead of `homeOrderItemCount`
4. Fix `OrderStepTracker` labels API
5. Fix `_greeting()` to use l10n keys in the plan pseudocode
