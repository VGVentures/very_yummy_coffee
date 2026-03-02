# Simplification Analysis: checkout and order-complete flow plan

Reviewed: `docs/plan/2026-03-02-feat-checkout-order-complete-flow-plan.md`
Date: 2026-03-02

---

## Core Purpose

Allow a user to proceed from a populated cart, review their order, place it, and
watch a 4-step real-time status tracker update until the order is ready. This
requires: one new server action, one new repository method, two new screens with
their Blocs, router wiring, and a CTA on the existing Cart screen.

---

## Unnecessary Complexity Found

### 1. Dual-status object in CheckoutState (Critical)

**File:** Plan, Phase 3 — "Revised CheckoutState"

The plan starts with a single `CheckoutStatus` enum covering the full lifecycle
of the screen, then revises it mid-section to a state object carrying **two
separate status enums**:

```dart
// Final plan shape
final CheckoutLoadStatus loadStatus;      // loading | success | failure
final CheckoutSubmitStatus submitStatus;  // initial | submitting | success | failure
```

This is the most significant complexity issue in the plan. Two parallel status
fields in one state object is hard to reason about — the UI must test two
independent booleans to decide what to render, and illegal combinations (e.g.
`loadStatus.failure` + `submitStatus.submitting`) become possible.

The existing `ItemDetailBloc` solves exactly this same shape — a loading phase
followed by a mutation phase — with a **single flat enum**:

```dart
// From item_detail_state.dart (already in the codebase)
enum ItemDetailStatus { loading, idle, adding, added, failure }
```

The Checkout screen has the same structure: load the order for display, then
submit it. A single enum is sufficient:

```dart
enum CheckoutStatus { loading, initial, submitting, success, failure }
```

`loading` — waiting for `currentOrderStream` to emit
`initial` — order loaded, button enabled
`submitting` — button disabled, spinner
`success` — navigate away
`failure` — inline error, button re-enabled

This removes one entire enum definition, eliminates the dual-status mental model,
and keeps `CheckoutState` consistent with every other Bloc in the project.

**Estimated LOC reduction:** ~10 lines of enum + state fields, plus simpler
builder logic in `CheckoutView`.

---

### 2. CheckoutSubscriptionRequested is named inconsistently with the rest of the plan (Minor)

**File:** Plan, Phase 3 — "Revised CheckoutBloc events"

The plan introduces `CheckoutSubscriptionRequested` as a second event in the
same revision block that introduces the dual-status state. If the dual-status
state is collapsed into a single enum (recommendation 1 above), the event itself
is fine — it matches the pattern used by `CartBloc` and `OrderCompleteBloc`
exactly. The issue is purely that the plan presents the single-event design,
then partially revises it in a "Note" block, leaving the reader to reconcile two
inconsistent designs in the same document. The final plan should commit to the
two-event design (`CheckoutSubscriptionRequested` + `CheckoutConfirmed`) and
remove the dead first draft.

**Estimated LOC reduction:** 0 in code, but significant reduction in document
ambiguity.

---

### 3. CheckoutView reads order data from the Bloc but the Bloc must read it from the repository (Minor)

**File:** Plan, Phase 3 — `_OrderSummarySection` note

The plan notes: "Alternatively, the total can be passed from CartView as route
extra — but CLAUDE.md prohibits using `extra`. Therefore `CheckoutBloc`
subscribes to `currentOrderStream` for display."

This reasoning is sound and the decision is correct. However, the plan should
also note that `CartBloc` is still alive and holds the same `currentOrderStream`
subscription when the user is on the Checkout screen (it was created on the cart
route which is a parent). `CheckoutBloc` opening its own `emit.forEach` on
`currentOrderStream` is still correct (it is idempotent — `BehaviorSubject`
replays), but it is worth noting explicitly that this does NOT open a second WS
connection because `OrderRepository._initOrdersIfNeeded` guards against that.
The plan mentions this for `OrderCompleteBloc` but not for `CheckoutBloc`.
Consistency here avoids a future "why does CheckoutBloc subscribe if CartBloc is
already open?" question.

**Estimated LOC reduction:** 0 in code; documentation gap only.

---

### 4. `completeCurrentOrder()` retained "for barista use" — YAGNI violation (Minor)

**File:** Plan, Phase 1 — OrderRepository section

```
- [ ] Keep `completeCurrentOrder()` as-is (for future barista screen or direct testing)
```

`completeCurrentOrder()` is not called anywhere in the mobile app after this
feature lands. The plan itself describes `submitOrder` as the new user-facing
action; `completeOrder` is a server-side barista action that the mobile app has
no UI to trigger. Keeping a public method on `OrderRepository` solely because it
might be useful in a hypothetical future barista screen is a YAGNI violation.

Two options, in order of preference:

1. Leave `completeCurrentOrder()` in the repository — it costs nothing and
   removing it would mean a separate PR when the barista screen arrives. This is
   acceptable because it is not new code being added by this plan.
2. If the preference is strict YAGNI, remove it now since no screen calls it.

The plan should not describe keeping it as an active decision. The correct framing
is: the method already exists, this plan does not touch it, and it is neither
added nor removed.

---

### 5. `orderId` field on `CheckoutState` is only populated on success, but the state transitions away on success (Minor)

**File:** Plan, Phase 3 — `CheckoutState` shape

```dart
final String? orderId;  // populated on success
```

The `orderId` is placed in `CheckoutState` so the `BlocConsumer` listener can
read it when navigating on success. However, navigation happens in the listener
and is a one-shot side effect — `CheckoutState` never needs to hold `orderId`
for rendering. The view needs `orderId` only to construct the route string at the
moment of navigation, which it can get directly from the event handler result
or from `state.orderId` transiently.

This is a small but real coupling: the state shape is influenced by the
navigation mechanism rather than by what the UI needs to display. An alternative
is to have the `BlocConsumer` listener call `orderRepository.currentOrderId`
directly from the widget at the moment `success` is emitted — but that couples
the view to the repository.

The cleanest option is to keep `orderId` in the state but acknowledge it is
navigation scaffolding, not display data. No LOC change, but the plan should
call this out explicitly so the implementer does not treat it as a display field.

---

### 6. Step 4 ("Picked Up") — described as "always unfilled, never set active by server" (Clarity)

**File:** Plan, Phase 2 / Phase 4 — tracker spec

The plan correctly notes Step 4 is a visual terminal state the server never sets.
However, the `_StatusTracker` spec describes the active-step mapping as index-based
(`activeStepIndex`) and mentions "Steps with index <= activeStepIndex are rendered
as completed/filled". Step 4 at index 3 would then be completed/filled if
`activeStepIndex` were 3 — but no status maps to 3. This is not a bug, but the
spec should make explicit that the maximum `activeStepIndex` reachable from the
server is 2 (`completed`), and Step 4 is purely decorative. A comment or note in
the plan would prevent an implementer from wondering whether Step 4 should ever
light up.

---

## Code to Remove

These items exist in the plan but should not be implemented:

| Plan section | Item | Reason |
|---|---|---|
| Phase 3, Revised CheckoutState | `CheckoutLoadStatus` enum | Collapse into single `CheckoutStatus` enum |
| Phase 3, Revised CheckoutState | `CheckoutSubmitStatus` enum | Collapse into single `CheckoutStatus` enum |
| Phase 3, CheckoutState fields | `loadStatus` + `submitStatus` as separate fields | Replace with single `status: CheckoutStatus` field |
| Phase 3, first CheckoutState draft | Initial single-status design | Remove the dead draft; document only the final design |

**Estimated LOC reduction:** ~10-15 lines in `checkout_bloc.dart`

---

## Simplification Recommendations

### 1. Use a single flat `CheckoutStatus` enum (Most impactful)

**Current plan:**
```dart
@MappableEnum()
enum CheckoutLoadStatus { loading, success, failure }

@MappableEnum()
enum CheckoutSubmitStatus { initial, submitting, success, failure }

@MappableClass()
class CheckoutState with CheckoutStateMappable {
  const CheckoutState({
    this.loadStatus = CheckoutLoadStatus.loading,
    this.submitStatus = CheckoutSubmitStatus.initial,
    this.order,
    this.orderId,
    this.errorMessage,
  });
  final CheckoutLoadStatus loadStatus;
  final CheckoutSubmitStatus submitStatus;
  final Order? order;
  final String? orderId;
  final String? errorMessage;
}
```

**Proposed:**
```dart
@MappableEnum()
enum CheckoutStatus { loading, initial, submitting, success, failure }

@MappableClass()
class CheckoutState with CheckoutStateMappable {
  const CheckoutState({
    this.status = CheckoutStatus.loading,
    this.order,
    this.orderId,
    this.errorMessage,
  });
  final CheckoutStatus status;
  final Order? order;
  final String? orderId;
  final String? errorMessage;
}
```

The state machine is strictly linear: load -> initial -> submitting -> success
(or failure -> initial). There are no concurrent phases. A single enum captures
this perfectly, matching the precedent set by `ItemDetailStatus` in the same
codebase.

**Impact:** Removes 2 enum definitions (~8 lines), removes 1 state field, makes
the builder `switch` on a single value instead of two, removes all illegal
state combinations.

---

### 2. Consolidate the plan document to remove the mid-section revision (Documentation)

**Current plan:** Presents an initial `CheckoutBloc` design with one event and
one status enum, then in the middle of Phase 3 says "Revised CheckoutBloc events"
and replaces both. A reader must discard the first design mentally.

**Proposed:** The plan should only present the final design — two events
(`CheckoutSubscriptionRequested`, `CheckoutConfirmed`) and one flat status enum.
Remove the "Note on order data" paragraph and the first draft of events and state
that it supersedes.

**Impact:** Reduces document length by ~25 lines, eliminates design ambiguity.

---

### 3. Clarify `completeCurrentOrder()` status (Documentation)

**Current plan:** "Keep `completeCurrentOrder()` as-is (for future barista screen
or direct testing)" — framed as an active decision.

**Proposed:** "This plan does not modify `completeCurrentOrder()`." No active
decision is needed; the method already exists and is not in scope.

**Impact:** 1 line change in the plan; eliminates YAGNI framing.

---

## YAGNI Violations

### Retaining `completeCurrentOrder()` as a stated design decision

`completeCurrentOrder()` exists and works. This plan does not need to take a
position on it. Describing it as "kept for future barista screen" frames a
non-existent future requirement as a present design decision. The correct posture
is silence: existing code that is out of scope is simply not mentioned.

---

## What the Plan Gets Right

The following decisions in the plan are well-reasoned and should be kept as-is:

- Using `orderStream(orderId)` instead of subscribing to `order:<id>` WS topic.
  The Alternative Approaches section documents this clearly and correctly.

- Optimistic success in `CheckoutBloc` (no server acknowledgment wait). The plan
  documents the trade-off and calls out when to revisit it.

- `PopScope(canPop: false)` on Order Complete. The stale-checkout problem is real
  and this is the right fix.

- Sticky footer placement for the Cart CTA. Consistent with the existing design
  pattern.

- Nesting `CheckoutPage` and `OrderCompletePage` as `GoRoute` children of
  `CartPage`. This is the correct `go_router` pattern and matches the existing
  `ItemDetailPage` nesting under `MenuItemsPage`.

- All four phases are correctly ordered. Server and repository must exist before
  the UI can call them.

- The 4-step tracker mapping is correct and the "Picked Up" never-activated step
  is a legitimate UX decision, not a bug.

- Using `context.go('/hardcoded/path')` throughout. Consistent with CLAUDE.md.

---

## Final Assessment

Total potential LOC reduction: ~5% of the planned new code (the dual-status
enums and their field duplication)

Complexity score: Low-Medium — one real complexity issue (dual-status state), one
YAGNI framing issue, and two documentation clarity gaps. The architecture itself
is sound.

Recommended action: Minor revisions before implementation

The plan is nearly ready. The one code-level change required before implementation
begins is collapsing the two `CheckoutStatus`-related enums into a single flat
enum, consistent with the `ItemDetailStatus` pattern already established in the
codebase. The document-level revisions (removing the dead first draft, fixing the
`completeCurrentOrder` framing) should also be done before the plan is handed to
an implementer to avoid confusion. All other decisions in the plan are correct.
