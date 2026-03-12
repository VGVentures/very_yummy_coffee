# Architecture Review: Shared Menu Feature

**Scope:** Shared menu feature package (`shared/menu_feature/`), consumer apps (mobile_app, kiosk_app), and related layer boundaries (menu_repository, very_yummy_coffee_ui).  
**Date:** 2026-03-11.

---

## 1. Layer Separation

### 1.1 Data → Domain → Presentation

- **Data:** `api_client` and similar live under shared/ or packages; they are not depended on by presentation or UI packages.
- **Domain:** `menu_repository` depends on `api_client`, `very_yummy_coffee_models`, `rxdart`. It does not depend on any other repository, bloc, or UI package. **Clean.**
- **Design system / UI:** `very_yummy_coffee_ui` depends only on `flutter`. It does **not** depend on `menu_repository`, `order_repository`, `api_client`, or any other domain/data package. **Clean — UI package is repository-agnostic.**
- **Feature (presentation):** `menu_feature` depends on:
  - `menu_repository` (domain) ✓
  - `very_yummy_coffee_ui` (design system) ✓
  - `bloc`, `flutter_bloc`, `rxdart`, `dart_mappable`, `flutter` (standard) ✓  
  It does **not** depend on `api_client`, `order_repository`, or any app package. **Clean.**

### 1.2 Imports Within `shared/menu_feature/`

- **Blocs:** Import only `bloc`, `dart_mappable`, `menu_repository` (and `rxdart` in menu_items_bloc). No presentation or data-layer imports. **Clean.**
- **Widgets:**
  - `MenuGroupCard`, `MenuItemCard`: Import only `flutter` and `very_yummy_coffee_ui`; accept primitives (`String name`, `String description`, `int color` / `name`, `price`, `available`). **Clean.**
  - `MenuGroupList`, `MenuGroupRow`, `MenuItemList`, `MenuItemGrid`: Import `menu_repository` for types `MenuGroup` and `MenuItem`, plus `menu_feature` internal cards and `very_yummy_coffee_ui`. This is correct: the feature package is presentation that uses domain types; the dependency is feature → domain, not UI package → repository. **Clean.**

### 1.3 Violations

- **Violations found: 0**
- All checked files respect Data → Domain → Presentation. The UI package (`very_yummy_coffee_ui`) remains repository-agnostic.

---

## 2. Bloc/Cubit Assessment

### 2.1 MenuGroupsBloc

| Check | Result |
|-------|--------|
| Event naming | **Correct.** Discrete: `MenuGroupsSubscriptionRequested`. |
| State immutability | **Correct.** `MenuGroupsState` has `final` fields and `copyWith` (via dart_mappable). |
| Business logic location | **Correct.** Subscription and stream handling in bloc; no logic in widgets. |
| Repository access | **Correct.** Bloc holds `MenuRepository`, widgets never touch repository. |
| BlocProvider usage | **Correct.** Apps use `BlocProvider(create: ...)` in `MenuGroupsPage` / `MenuItemsPage`. |
| Event handlers | **Correct.** One handler per event (`_onSubscriptionRequested`), `async` with `emit.forEach`. |

### 2.2 MenuItemsBloc

| Check | Result |
|-------|--------|
| Event naming | **Correct.** Discrete: `MenuItemsSubscriptionRequested`. |
| State immutability | **Correct.** `MenuItemsState` has `final` fields and `copyWith`. |
| Business logic location | **Correct.** Combine logic and stream handling in bloc. |
| Repository access | **Correct.** Bloc uses `MenuRepository`; widgets use only state. |
| BlocProvider usage | **Correct.** Provided at page level with `create`. |
| Event handlers | **Correct.** One handler per event, `async` with `emit.forEach`. |

### 2.3 Summary

- **MenuGroupsBloc:** Correct.  
- **MenuItemsBloc:** Correct.  
- No Bloc/Cubit violations.

---

## 3. Dependency Direction

- **Presentation (apps) → Feature → Domain / UI**
  - `mobile_app` and `kiosk_app` depend on `menu_feature` and `menu_repository` (and `very_yummy_coffee_ui`). They do **not** depend on each other. **No app-to-app coupling.**
- **Feature → Domain / UI only**
  - `menu_feature` → `menu_repository`, `very_yummy_coffee_ui`; no dependency on `api_client`, `order_repository`, or app packages.
- **UI package**
  - `very_yummy_coffee_ui` has no dependency on any repository or api_client. **Stays repository-agnostic.**

**Direction violations: 0.** Dependency graph is acyclic and flows in the intended direction.

---

## 4. Package Structure

### 4.1 `shared/menu_feature/`

| Item | Status |
|------|--------|
| `pubspec.yaml` with correct name and deps | ✓ |
| `analysis_options.yaml` includes `very_good_analysis` | ✓ |
| `test/` directory with bloc and widget tests | ✓ |
| Single responsibility (menu groups + items blocs and content widgets) | ✓ |
| Layout `lib/src/` with `bloc/` and `widgets/` | ✓ |

**Export surface (`lib/menu_feature.dart`):**

- Exports: `MenuGroupsBloc`, `MenuItemsBloc`, `MenuGroupList`, `MenuGroupRow`, `MenuItemGrid`, `MenuItemList`.
- Does **not** export: `MenuGroupCard`, `MenuItemCard` (internal implementation details). This is a reasonable public API.

### 4.2 Consumer Apps

- **mobile_app:** Depends on `menu_feature`, `menu_repository`, `very_yummy_coffee_ui`; provides `MenuGroupsBloc` / `MenuItemsBloc` at page level via `BlocProvider(create: ...)` with `context.read<MenuRepository>()`. No reference to kiosk_app.
- **kiosk_app:** Same pattern; no reference to mobile_app.

**Package structure: Complete.** No missing structural elements.

---

## 5. Verdict

**Architecture is clean.** No critical or important violations.

- Layer separation is correct; `very_yummy_coffee_ui` stays repository-agnostic; `menu_feature` depends only on `menu_repository` and `very_yummy_coffee_ui` (plus standard packages).
- Bloc usage follows VGV patterns (discrete events, immutable state, repository in bloc, BlocProvider with create).
- Dependency direction is correct; no app-to-app coupling.
- Package layout (`lib/src`), export surface, and tests are in place.

**Suggestions (non-blocking):**

1. **Export surface:** Keeping `MenuGroupCard` and `MenuItemCard` internal is appropriate. If the plan is to never expose them, a brief comment in `menu_feature.dart` or the package README that “card widgets are internal” can help future maintainers.
2. **State types:** Bloc states expose `MenuGroup` and `MenuItem` from `menu_repository`. Apps that need these types will depend on `menu_repository` (e.g. for `context.read<MenuRepository>()` and type references). This is acceptable; no change required unless you later introduce a feature-specific DTO layer.

---

**Reviewer:** Architecture review agent (VGV standards).  
**Artifacts checked:** `shared/menu_feature/` (pubspec, lib, tests), `applications/mobile_app` and `applications/kiosk_app` (menu feature usage, pubspec), `shared/very_yummy_coffee_ui` and `shared/menu_repository` (pubspec, layer boundaries).
