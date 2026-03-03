# Simplicity Review: feat — implement kds kitchen display app

**Plan file:** `docs/plan/2026-03-02-feat-implement-kds-kitchen-display-app-plan.md`
**Reviewer date:** 2026-03-02

---

## Simplification Analysis

### Core Purpose

Build a landscape Flutter app (`kds_app`) that displays active orders in three columns (NEW, IN PROGRESS, READY), lets kitchen staff tap one button per order to advance its status, and shows elapsed time. Enable this by adding `inProgress` to `OrderStatus`, `submittedAt` to `Order`, a `startOrder` server handler, and corresponding repository methods. Fix the WS re-subscription gap as a prerequisite.

---

### Unnecessary Complexity Found

**1. `@MappableClass()` on KDS event classes (Section 2.4, `kds_event.dart`)**

Every event class in the plan is annotated with `@MappableClass()`. Looking at the existing `mobile_app` code, event classes (`AppEvent`, `AppStarted`, `HomeSubscriptionRequested`, etc.) use plain Dart sealed/final classes with no `dart_mappable` annotations — see `applications/mobile_app/lib/app/bloc/app_event.dart` and `home_event.dart`. Events are never serialized; they are created, dispatched, and discarded in memory. Generating mapper code for events adds generated files and build-time noise with no benefit.

Suggested simplification: remove `@MappableClass()` from all event classes. Follow the existing pattern: sealed class with no annotation, final subclasses with no annotation. This also eliminates `kds_bloc.mapper.dart` (the mapper file is only needed for the state, not events).

**2. `@MappableClass()` and `@MappableEnum()` on `KdsState` and `KdsStatus` (Section 2.4, `kds_state.dart`)**

The `KdsState` carries three `List<Order>` fields and a status enum. These are never serialized to/from JSON. Comparing with `HomeState` in `mobile_app` (`home_state.dart`), `HomeState` does use `@MappableClass()` because the project standard requires it for `copyWith` generation — so this annotation is valid and consistent. Keep `@MappableClass()` on `KdsState` and `@MappableEnum()` on `KdsStatus`.

The issue is only with the event annotations, not the state.

**3. Pre-sorting inside `_onSubscriptionRequested` in `KdsBloc` (Section 2.4, `kds_bloc.dart`)**

The plan sorts all orders by `submittedAt` before filtering into three lists. The sort comparator contains four branches to handle nullable `submittedAt`. This is correct but somewhat verbose in the bloc. An acceptable simplification is to define the comparator as a top-level or static function with a descriptive name rather than an anonymous inline lambda. This is a minor readability improvement, not a structural change. The plan's current approach is not wrong, just slightly dense.

**4. `completeOrder` and `cancelOrder` as new repository methods (Section 1.3)**

The plan adds `completeOrder(String orderId)` and `cancelOrder(String orderId)` as new orderId-based methods on `OrderRepository`. However, the existing `OrderRepository` already has `completeCurrentOrder()` and (implicitly, via the server) a cancel path. The plan explicitly states the KDS needs these orderId-based variants and that existing methods are untouched — this is correct because the mobile app uses current-order–scoped helpers, while the KDS needs to operate on any arbitrary orderId. The duplication of names (`completeCurrentOrder` vs `completeOrder`) may cause confusion in tests and usage.

Suggested simplification: rename the new methods to make the distinction clear:
- `completeOrder(String orderId)` is fine
- `cancelOrder(String orderId)` is fine

These are additive and unambiguous. No change needed — the plan is already correct here. This is noted for awareness, not as a required change.

**5. `_KdsTopBar` clock using `StreamBuilder<DateTime>` (Section 2.5)**

The plan uses `StreamBuilder<DateTime>` on `Stream.periodic(Duration(seconds: 1), (_) => DateTime.now())` for the clock in the top bar. This is a reasonable pattern, but the stream is created inside `build`, which means a new `Stream.periodic` is created on every rebuild. This should be created once in `initState` of a `StatefulWidget` and stored, or it will recreate the subscription on every parent rebuild.

Suggested simplification: make `_KdsTopBar` a `StatefulWidget`, create the `Stream.periodic` once in `initState`, and store a reference. Alternatively, use a `Timer.periodic` directly and call `setState`. Either way, the plan should specify this clearly, since creating `Stream.periodic` inside `build` is a subtle resource issue.

**6. Ambiguity about `_ElapsedWidget` disable-button behavior (Section 2.5)**

The plan introduces `_ElapsedWidget` as a `StatefulWidget` with a `Timer.periodic`. It then separately says the action button should be disabled between tap and server round-trip, with the note: "track with a local `_pendingActionId` state in `StatefulWidget` or simply rely on server round-trip being fast enough — for v1, trust the server."

This is an unresolved design decision left in the plan. For v1, the plan should commit to one approach rather than leaving it open. "Trust the server" (no local disable) is the simpler path and consistent with the fire-and-forget principle already established. A half-sentence leaving both options open creates implementation uncertainty.

Suggested simplification: commit explicitly to "no local disable state for v1; the server round-trip is fast enough." Remove the mention of `_pendingActionId`. This eliminates a potential `StatefulWidget` where a `StatelessWidget` would suffice.

**7. App layer duplication instruction: "copy AppBloc pattern from mobile_app exactly" (Section 2.3)**

The plan says to copy `AppBloc` from `mobile_app`. After reading both apps, `AppBloc`, `AppEvent`, `AppState`, and `GoRouterRefreshStream` are byte-for-byte identical in purpose and near-identical in code. This is acceptable because moving them to a shared package would require `connection_repository` in `very_yummy_coffee_ui`, which violates the UI package constraint, and there is no other shared app-logic package. The plan correctly handles this as a copy — this is not over-engineering, it is a correct trade-off given the project's package constraints.

No change needed here. Noted only for clarity.

**8. `ageHoursMinutesAgo` ARB string has zero confirmed use cases (Section 2.2)**

The plan includes `"ageHoursMinutesAgo": "{hours}h {minutes}m ago"` in the ARB file. Looking at the acceptance criteria, the age display threshold table shows this fires for orders 60+ minutes old. In a coffee shop context, a KDS order being 60+ minutes old is a failure condition, not a normal operation. This string will almost never appear in practice. However, it is a single ARB entry with no associated code complexity, so the cost of including it is trivially low. Retaining it is fine for correctness. This is flagged as a YAGNI-adjacent observation, not a required removal.

---

### Code to Remove

- **`@MappableClass()` on all five KDS event classes** (`KdsSubscriptionRequested`, `KdsOrderStarted`, `KdsOrderMarkedReady`, `KdsOrderCompleted`, `KdsOrderCancelled`) — these annotations are inconsistent with the existing event pattern in `mobile_app` and generate unnecessary mapper code.
  - Estimated LOC reduction: ~10 annotations removed + eliminates mapper regeneration for event classes (the mapper file `kds_bloc.mapper.dart` can be scoped to state only, or the event file can be a `part of` with no mapping).

- **`_pendingActionId` mention** in `kds_order_card.dart` description — remove the ambiguous dual-option text and commit to the simpler "no local disable" path.
  - Estimated LOC reduction: 0 from implementation (prevents addition of ~15 lines of unnecessary `StatefulWidget` state).

---

### Simplification Recommendations

**1. Remove `@MappableClass()` from all KDS event classes**

- Current: each of the 5 event classes is annotated `@MappableClass()`, requiring `dart run build_runner build` to generate event mappers.
- Proposed: follow the `mobile_app` pattern — sealed/final event classes with no annotations, no generated mapper code for events.
- Impact: eliminates ~5–10 generated LOC per event class; removes one source of build confusion; consistent with existing codebase convention.

**2. Fix `Stream.periodic` clock construction site**

- Current: plan says `StreamBuilder<DateTime>` on `Stream.periodic(...)` inside `build`.
- Proposed: specify that the stream must be created once, either in `initState` of a `StatefulWidget` or via a class-level field. Add this note explicitly to the `_KdsTopBar` description in the plan.
- Impact: prevents a subtle resource/rebuild bug; no extra files needed.

**3. Commit to no-disable-button for v1 in `kds_order_card`**

- Current: "track with `_pendingActionId` state OR trust the server."
- Proposed: "For v1, trust the server. No local disable state on the action button."
- Impact: `KdsOrderCard` stays a `StatelessWidget`; no local timer or pending state to manage; simpler test setup.

---

### YAGNI Violations

**None critical.** The plan is well-scoped. Future considerations are correctly deferred to the "Future Considerations" section and do not appear in the implementation plan. The `ageHoursMinutesAgo` string is borderline but harmless.

The status transition guards on the server (Section 1.5) may appear defensive but are explicitly motivated by a real race condition between two KDS clients — this is a correct, justified addition, not premature defense.

---

### Final Assessment

Total potential LOC reduction: less than 1% — the issues found are annotation correctness and a plan-text ambiguity, not structural over-engineering.

Complexity score: Low. The plan maps cleanly onto the existing codebase patterns. Phase sequencing is logical. The data model changes are minimal and additive. The KDS bloc mirrors `HomeBloc` closely.

Recommended action: **Proceed with simplifications** — specifically remove `@MappableClass()` from event classes and commit explicitly to the no-local-disable-state decision before implementation begins. All other sections are ready to implement as written.

The most important correction is the event annotation issue: if a developer follows the plan as written, they will generate mapper code for events that the rest of the codebase never generates, and they will likely discover the inconsistency mid-implementation when comparing with `mobile_app`. Fix this in the plan before handing it to an implementer.
