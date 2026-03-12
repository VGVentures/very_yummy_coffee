# PR Readiness Review: Shared Menu Feature

**Scope:** (1) New package `shared/menu_feature/`; (2) mobile_app and kiosk_app menu migrations (removed local blocs/views, use menu_feature).  
**Plan:** `docs/plan/2026-03-11-feat-shared-menu-feature-plan.md`  
**Date:** 2026-03-11

---

## 1. Executive summary

The shared menu feature implementation is **substantially complete** and aligned with the plan. The new package is well-structured, both apps are correctly migrated to use shared blocs and widgets, and CODE_SHARING_REPORT has been updated. **One critical fix** is required before merge: the GitHub Actions workflow path filter does not match the actual workflow filename, so the menu_feature CI would not run when the workflow file itself is updated (and may confuse the Verify Github Actions check). A few **important** items (missing fallback title when `group == null` in mobile, optional plan dependency) and **suggestions** (README for the package, workflow path alignment with repo convention) are noted below.

**Verdict:** Ready to merge after fixing the workflow path (critical). Other findings are non-blocking improvements.

---

## 2. Completeness vs plan

### Success criteria (from plan)

| Criterion | Status | Notes |
|-----------|--------|--------|
| Package exists with correct deps (no app, no go_router, no app l10n) | ✅ | `menu_repository`, `very_yummy_coffee_ui`, `bloc`, `flutter_bloc`, `dart_mappable`, `rxdart`. No `very_yummy_coffee_models` direct dep (types via menu_repository); plan listed it—see Important below. |
| Blocs: MenuGroupsBloc, MenuItemsBloc; MenuItemsState has `group` + `menuItems` only | ✅ | Implemented; no `groupName`. |
| Widgets: List/Row/Grid with data + callbacks; no context.go/l10n in package | ✅ | All use callbacks; design tokens only; no navigation/l10n in package. |
| Mobile: menu_feature for blocs/widgets; app header + MenuGroupList + MenuItemList; routes/l10n unchanged | ✅ | Pages provide blocs; views use shared widgets and `context.go` in callbacks. |
| Kiosk: same; MenuGroupRow + MenuItemGrid; `state.group?.name ?? ''` for header | ✅ | Uses BlocSelector for header title; MenuItemGrid in body. |
| Loading/error: loading UI; bloc emits failure without message; app supplies error string | ✅ | Both apps show CircularProgressIndicator and use `context.l10n.errorSomethingWentWrong`. |
| Empty/invalid: empty list; app handles `group == null` in header | ⚠️ | Kiosk handles null (BlocSelector returns ''). Mobile header shows nothing when `group == null` (no fallback title)—see Important. |
| Tests: bloc + widget tests in menu_feature; app tests removed/updated | ✅ | Bloc and widget tests present; app-level menu bloc/view tests removed. pump_app does not provide menu blocs (blocs are page-scoped); no tests found that need them. |

### Phase checklist (implementation plan)

- **Phase 1 (package):** Package scaffold, MenuGroupsBloc, MenuItemsBloc (unified state), content widgets (cards internal), public API, analysis_options, build_runner — all done. **CI:** Workflow added but path filter wrong (see Critical).
- **Phase 2 (mobile):** pubspec, local menu impl removed, pages/views use shared blocs and widgets, router unchanged — done. Tests: local menu tests removed; no remaining references to local menu blocs in tests.
- **Phase 3 (kiosk):** Same as Phase 2 with MenuGroupRow/MenuItemGrid and `state.group?.name ?? ''` — done.
- **Phase 4:** CODE_SHARING_REPORT updated (todo #1 done with completion note). Full test run: menu_feature tests pass (12 tests). Manual verification not re-run in this review.

---

## 3. Package `shared/menu_feature` — detail

### Layout and dependencies

- **Layout:** Matches plan: `lib/src/bloc/`, `lib/src/widgets/`; public API in `lib/menu_feature.dart`. Cards are internal (not exported).
- **pubspec.yaml:** Dependencies: `menu_repository`, `very_yummy_coffee_ui`, `bloc`, `flutter_bloc`, `dart_mappable`, `rxdart`. Dev: `bloc_test`, `build_runner`, `flutter_test`, `mocktail`, `test`, `very_good_analysis`, `dart_mappable_builder`. No dependency on apps, `go_router`, or app l10n.
- **analysis_options.yaml:** Uses `package:very_good_analysis/analysis_options.yaml`; `public_member_api_docs: ignore`.

### Blocs

- **MenuGroupsBloc:** Takes `MenuRepository`; `MenuGroupsSubscriptionRequested` → emit loading then `emit.forEach(getMenuGroups(), ...)`. States: initial, loading, success (menuGroups), failure. Matches plan.
- **MenuItemsBloc:** Takes `menuRepository` and `groupId`; uses `Rx.combineLatest2(getMenuGroups(), getMenuItems(_groupId))`; state has `group` (resolved by `_groupId`) and `menuItems`; no `groupName`. Events/states in `part` files; mappers generated.

### Widgets

- **MenuGroupCard / MenuItemCard:** Internal; use primitives (name, description, color for group; name, price, available for item). MenuItemCard uses `UnavailableOverlay` from very_yummy_coffee_ui. Layout variants (list/row, list/grid) via enum.
- **MenuGroupList / MenuGroupRow:** `List<MenuGroup>`, `onGroupTap`. List uses default list layout; Row passes `MenuGroupCardLayout.row`.
- **MenuItemList / MenuItemGrid:** `List<MenuItem>`, `onItemTap`. List uses default list layout; Grid uses two-column `GridView.builder`. No `context.go` or `context.l10n` in package. Design tokens (context.colors, context.spacing, context.typography, context.radius) used; no raw `EdgeInsets.fromLTRB` or `Color(0x...)` or `Colors.*`.

### Public API

- **Exports:** MenuGroupsBloc, MenuItemsBloc, MenuGroupList, MenuGroupRow, MenuItemList, MenuItemGrid. Events and states are exported via the bloc files (part of). Cards intentionally not exported. Plan also listed event/state/status names—all available through the bloc exports.

### Tests

- **Bloc:** `menu_groups_bloc_test.dart` — initial state, loading→success, loading→failure. `menu_items_bloc_test.dart` — initial, success with group+items, success with unknown groupId (group null), failure. All use mocktail and bloc_test.
- **Widget:** `menu_group_list_test.dart` — renders names, onGroupTap, empty list. `menu_item_list_test.dart` — renders names/prices, onItemTap. Both use `MaterialApp(theme: CoffeeTheme.light, ...)` for theme. No tests for MenuGroupRow or MenuItemGrid (suggestion: add if time permits).
- **Run:** `flutter test` in `shared/menu_feature` passes (12 tests). Build_runner generates mappers successfully.

---

## 4. Mobile app migration

- **Barrel files:** `menu_groups.dart` and `menu_items.dart` export only `view/view.dart` (page + view). No dead code; no references to removed blocs.
- **MenuGroupsPage:** BlocProvider creates MenuGroupsBloc with `context.read<MenuRepository>()` and dispatches `MenuGroupsSubscriptionRequested`. Child is MenuGroupsView.
- **MenuGroupsView:** App header (back, app title, cart icon) + BlocBuilder; loading/error/success; success body is `MenuGroupList(..., onGroupTap: (g) => context.go('/home/menu/${g.id}'))`. Uses `context.l10n` for title and error only.
- **MenuItemsPage:** BlocProvider creates MenuItemsBloc with `groupId: state.pathParameters['groupId']!`. Child is MenuItemsView.
- **MenuItemsView:** Header with `_Header(group: state.group)`; when `group != null` shows name and description; when `group == null` the header shows only back button (no fallback title). Success body is `MenuItemList(..., onItemTap: (i) => context.go('/home/menu/${i.groupId}/${i.id}'))`. Plan says "app header must handle group == null (e.g. fallback title)" — currently no fallback title (Important).
- **Router:** Unchanged; still uses `MenuGroupsPage.routeName`, `MenuItemsPage.routePathTemplate` and app-owned page classes. Blocs provided at page level.

---

## 5. Kiosk app migration

- **MenuGroupsPage / MenuGroupsView:** Same pattern; KioskHeader with brand/subtitle; success body is `MenuGroupRow` with `context.go('/home/menu/${g.id}')`.
- **MenuItemsPage / MenuItemsView:** Only MenuItemsBloc provided. Header uses `BlocSelector<MenuItemsBloc, MenuItemsState, String>(selector: (state) => state.group?.name ?? '', ...)` for title; back goes to `/home/menu`. Body: `MenuItemGrid` with same `context.go` pattern. Correctly handles `group == null` (empty string for title).

---

## 6. Consistency and patterns

- **State management:** Bloc used with explicit events; blocs provided at feature (page) level, not at a parent that hosts multiple features. Aligns with CLAUDE.md.
- **Navigation:** Apps use `context.go('/path')` in callbacks; no navigation inside menu_feature. Hardcoded path strings in app views.
- **UI tokens:** menu_feature and app views use `context.colors`, `context.spacing`, `context.typography`, `context.radius`; no raw hex or Material `Colors.*` in reviewed code.
- **Shared UI:** Menu cards use very_yummy_coffee_ui (UnavailableOverlay, theme). No repository dependency in very_yummy_coffee_ui; menu_feature depends on menu_repository and very_yummy_coffee_ui only (no direct very_yummy_coffee_models in pubspec; types from menu_repository).

---

## 7. Gaps and dead code

- **Dead code:** None found. Removed app bloc/event/state files are deleted; barrel files only re-export view. No leftover imports of deleted menu blocs in app tests (cart, item_detail, etc. use MenuRepository/getMenuGroupsAndItems, not menu blocs).
- **Gaps:** (1) Mobile MenuItemsView does not show a fallback title when `state.group == null`. (2) Plan success criteria listed `very_yummy_coffee_models` as a dependency; implementation relies on menu_repository for types only (acceptable but minor deviation). (3) No widget tests for MenuGroupRow and MenuItemGrid (list variants are tested). (4) No README in shared/menu_feature (suggestion).

---

## 8. Documentation

- **Plan and brainstorm:** Present and referenced. CODE_SHARING_REPORT.md updated: todo #1 marked done with completion note (Mar 2026).
- **Package:** No README in `shared/menu_feature`. Public API is clear from `menu_feature.dart`; doc comments on widgets (e.g. "Vertical list of menu group cards. Use for mobile-style menu groups."). Suggestion: add a short README with purpose, deps, and usage (one paragraph + example).

---

## 9. CI/CD and merge readiness

- **Workflow:** `.github/workflows/menu_feature.yaml` exists and runs format, analyze, and tests for `shared/menu_feature`. **Critical issue:** The workflow’s `paths` filter references `.github/workflows/menu_feature_verify_and_test.yaml`, but the actual file is `menu_feature.yaml`. As a result, when only the workflow file is changed, this workflow will not trigger (path mismatch). It may also cause the "Verify Github Actions" job to fail if that job expects generated workflow names. **Fix:** Either rename the workflow file to `menu_feature_verify_and_test.yaml` to match the path (and other packages like menu_repository), or change the path in the workflow to `.github/workflows/menu_feature.yaml`. Prefer aligning with repo convention (other workflows use `*_verify_and_test.yaml` in paths).
- **update_github_actions.sh:** Plan says to run after adding the package and commit workflow changes. The workflow was added; the filename/path mismatch should be resolved when fixing the critical item above (or by re-running the script if it generates the expected name).
- **Tests:** menu_feature tests pass. No run of full mobile/kiosk test suites in this review; recommend running them before merge.

---

## 10. Summary of findings

### Critical (must fix before merge)

- **Workflow path mismatch:** `menu_feature.yaml` triggers on path `.github/workflows/menu_feature_verify_and_test.yaml`, which does not exist. Rename workflow file to `menu_feature_verify_and_test.yaml` or update the path to `menu_feature.yaml` so CI runs when the workflow or package changes.

### Important (should address)

- **Mobile header when group is null:** Plan requires app header to handle `group == null` (e.g. fallback title). Mobile MenuItemsView shows only the back button when `group == null`; add a fallback title (e.g. empty string or a generic label) for consistency and plan compliance.
- **Plan dependency checklist:** Plan listed `very_yummy_coffee_models` in package deps; implementation uses only `menu_repository` (which exposes models). Acceptable but document or align plan for future readers.

### Suggestions (nice to have)

- **Package README:** Add `shared/menu_feature/README.md` with purpose, dependencies, and minimal usage example.
- **Widget tests for Row/Grid:** Add tests for MenuGroupRow and MenuItemGrid (structure and callbacks) to match coverage of list variants.
- **Verify app test suites:** Run full `flutter test` for mobile_app and kiosk_app before merge to catch any regressions.

---

**Conclusion:** Implementation is complete and consistent with the plan. Fix the workflow path (critical), then the change is ready to merge. Address the important and suggestion items as follow-ups or in the same PR if desired.
