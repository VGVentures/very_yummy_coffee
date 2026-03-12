# Code Simplicity Review: Shared Menu Feature

**Scope:** `shared/menu_feature/` (blocs, widgets); `applications/mobile_app` and `applications/kiosk_app` menu_groups/menu_items pages and views.

---

## Simplification Analysis

### Core Purpose

- **shared/menu_feature:** Provide reusable menu groups and menu items Blocs plus list/row/grid widgets and internal cards so mobile and kiosk can show menu groups and items with minimal app-specific code.
- **Apps:** Compose shared Blocs and widgets, provide BlocProviders, app-specific headers/chrome, and navigation.

---

### Unnecessary Complexity Found

1. **Event/State serialization (dart_mappable on Events)**  
   - **Where:** `menu_groups_event.dart`, `menu_items_event.dart` — sealed event classes use `@MappableClass()`.  
   - **Why unnecessary:** Events are never sent over the wire or persisted. Only one event type per Bloc (`*SubscriptionRequested`). Mappers add ~200 LOC per Bloc (generated) and cognitive load; `toMap`/`fromMap`/`toJson` are unused.  
   - **Suggested simplification:** Remove `@MappableClass()` from Events (and from the single event subclass). Use plain classes; if equality is needed in tests, rely on `const` or add a minimal `equatable` or manual `==`/`hashCode`. Keep mappable only where serialization is required (e.g. State if ever persisted; currently only `copyWith` is used from the mapper).

2. **MenuItemsBloc subscribes to two streams and combines them**  
   - **Where:** `menu_items_bloc.dart` — `Rx.combineLatest2(getMenuGroups(), getMenuItems(_groupId), ...)` and `groups.where((g) => g.id == _groupId).firstOrNull`.  
   - **Why unnecessary:** Repository already exposes `getMenuGroupsAndItems()` for “screens that need both,” with a single ref-counted subscription. Combining two separate streams is more complex and duplicates subscription logic.  
   - **Suggested simplification:** Subscribe to `getMenuGroupsAndItems()`, map to `(group: group for _groupId, items: items for group)`, and emit. Removes `rxdart` from the Bloc’s public API surface (still used inside repository) and aligns with the repo’s intended API.

3. **Duplicate status-handling UI in four views**  
   - **Where:** `mobile_app` and `kiosk_app` `menu_groups_view.dart` and `menu_items_view.dart` — each has the same `switch (state.status)` with `initial | loading` → `CircularProgressIndicator`, `failure` → `Text(error)`, `success` → shared widget.  
   - **Why redundant:** Same pattern repeated in four places; any change (e.g. retry button, different loading widget) must be done four times.  
   - **Suggested simplification:** Extract a small shared widget in `menu_feature`, e.g. `MenuContentBuilder<T>` or `SubscriptionStatusContent` that takes `status`, `loading`, `error`, and `child` (success content). Each view passes its Bloc state and success widget. Reduces duplication and keeps behavior consistent.

4. **MenuGroupRow padding logic**  
   - **Where:** `menu_group_row.dart` — `asMap().entries.map` with `index == 0` / `index == groups.length - 1` to conditionally remove left/right padding.  
   - **Why more complex than needed:** Same effect can be achieved with a single `ListView.separated` (horizontal) and `SizedBox(width: spacing.md)` as separator, or `Wrap` with spacing, avoiding index checks.  
   - **Suggested simplification:** Use `ListView.separated` with `scrollDirection: Axis.horizontal` and a fixed separator width, or a row of `Expanded` children with a single `Padding(padding: EdgeInsets.symmetric(horizontal: spacing.md))` and no padding on the row’s edges (e.g. via `Padding` only on inner cards). Simplifies the code and makes the layout intent clearer.

5. **MenuItemCard / MenuGroupCard layout enums**  
   - **Where:** `MenuItemCardLayout` (list vs grid), `MenuGroupCardLayout` (list vs row).  
   - **Assessment:** Two call sites each (list vs grid, list vs row). Inlining would mean two separate card widgets per type (e.g. `MenuItemListCard` and `MenuItemGridCard`) and more files. The current single card with a layout parameter is a reasonable, minimal abstraction.  
   - **Verdict:** Acceptable; no change required unless you prefer two widgets over one enum.

6. **Sealed base class for single-event hierarchies**  
   - **Where:** `MenuGroupsEvent` / `MenuItemsEvent` sealed with one implementation each.  
   - **Why borderline YAGNI:** Sealed is useful for exhaustive switching when there are multiple event types. With only one event per Bloc, a single concrete class is enough.  
   - **Suggested simplification:** Replace with a single event class per Bloc (e.g. `MenuGroupsSubscriptionRequested` only) unless you expect more events soon. Reduces boilerplate and mapper surface.

---

### Code to Remove

| Location | Reason | Estimated LOC |
|----------|--------|---------------|
| `@MappableClass()` (and generated mappers) for `MenuGroupsEvent` / `MenuGroupsSubscriptionRequested` | Events not serialized; copyWith/equality unused for events | ~200 (generated) |
| `@MappableClass()` (and generated mappers) for `MenuItemsEvent` / `MenuItemsSubscriptionRequested` | Same as above | ~200 (generated) |
| `Rx.combineLatest2` + `firstOrNull` in `MenuItemsBloc` | Replace with single `getMenuGroupsAndItems()` subscription | ~5 (replace with fewer lines) |

No recommendation to remove the internal cards or list/row/grid widgets; they are used and avoid duplication across apps.

---

### Simplification Recommendations

1. **Use `getMenuGroupsAndItems()` in MenuItemsBloc (high impact)**  
   - **Current:** Two streams combined with `Rx.combineLatest2`, then group resolved with `firstOrNull`.  
   - **Proposed:** Single subscription to `getMenuGroupsAndItems()`, map to `(group: groups.where(...).firstOrNull, items: items.where((i) => i.groupId == _groupId).toList())` (or use repo’s `itemsForGroup` if exposed).  
   - **Impact:** Simpler Bloc, one subscription, no rxdart in this Bloc, aligns with repository design.

2. **Drop dart_mappable from Events (high impact)**  
   - **Current:** Events are sealed + mappable; large generated mappers.  
   - **Proposed:** Plain `const` event classes; remove `part '*.mapper.dart'` and `@MappableClass()` from event files. Regenerate mappers (or remove event mappers from build_runner).  
   - **Impact:** Significant generated LOC removed; clearer that events are in-memory only.

3. **Extract shared status-content widget (medium impact)**  
   - **Current:** Four views repeat the same loading/failure/success switch.  
   - **Proposed:** In `menu_feature`, add a small widget that takes a status enum, loading widget, error message builder, and success child. Views pass state and success content.  
   - **Impact:** One place to change behavior; fewer duplicated branches.

4. **Simplify MenuGroupRow layout (low impact)**  
   - **Current:** `asMap().entries` and conditional padding per index.  
   - **Proposed:** Horizontal `ListView.separated` or symmetric padding on inner items only.  
   - **Impact:** Fewer lines, easier to read.

5. **Optional: Single event class per Bloc (low impact)**  
   - **Current:** Sealed base + one subclass per Bloc.  
   - **Proposed:** One concrete event class per Bloc (e.g. only `MenuGroupsSubscriptionRequested`).  
   - **Impact:** Slightly less boilerplate and mapper code if Events stay mappable; if Events lose mappable, this is a natural follow-up.

---

### YAGNI Violations

- **Event/State serialization for Events:** Serialization (toMap/fromMap/toJson) is not used for menu Events anywhere. Keeping it “in case” we persist or send events is YAGNI; remove until there is a concrete requirement.  
- **Sealed event hierarchy with one subtype:** Extensibility for “future events” without a concrete second event is YAGNI; a single class is enough until a second event exists.  
- **combineLatest2 instead of getMenuGroupsAndItems():** The repository already provides the right primitive; using two streams and combining them is unnecessary complexity.

---

### Final Assessment

- **Total potential LOC reduction:** ~5–10% in hand-written code; ~400 LOC in generated mappers if Event mappable is removed.  
- **Complexity score:** Medium (localized complexity in Events/mappers and MenuItemsBloc stream choice).  
- **Recommended action:** Proceed with simplifications: (1) MenuItemsBloc → `getMenuGroupsAndItems()`, (2) Remove mappable from Events and regenerate, (3) Extract status-content helper for the four views, (4) Simplify MenuGroupRow. Optional: collapse to single event class per Bloc.

---

## Summary Table

| Category | Count |
|----------|--------|
| Critical (unnecessary complexity that should be fixed) | 2 |
| Important (clear redundancy or simpler alternative) | 2 |
| Suggestions (nice-to-have simplifications) | 3 |

**Critical:** Event mappable unused; MenuItemsBloc should use `getMenuGroupsAndItems()`.  
**Important:** Duplicate status UI in four views; MenuGroupRow padding logic.  
**Suggestions:** Single event class per Bloc; consider keeping State mappable only for copyWith; layout enums are acceptable as-is.
