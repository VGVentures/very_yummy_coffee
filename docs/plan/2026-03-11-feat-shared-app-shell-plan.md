---
title: "feat: shared app shell and connecting UX"
type: feat
date: 2026-03-11
---

## feat: shared app shell and connecting UX

## Overview

Reduce duplication of app bootstrap and connection UX across all five apps by (Scope A) adding a shared **ConnectingView** to `very_yummy_coffee_ui` and (Scope B) adding **`shared/app_shell`** with shared AppBloc, route constant, and redirect helper. Each app keeps a thin ConnectingPage and app-specific router; all use the same connecting UI and connection flow.

**Brainstorm:** `docs/ideate/2026-03-11-shared-app-shell-brainstorm-doc.md`

## Background and motivation

Every app has its own `ConnectingPage` (spinner ± "Connecting…" text), `AppBloc` (identical: `ConnectionRepository.isConnected` → `AppState`), and redirect logic. The Code Sharing Report (TODO 4) calls for a shared connecting screen and optional shared app shell. The brainstorm decided: (1) UI package exposes **ConnectingView** (view/page naming; no "screen"); (2) mobile_app shows the same message as others; (3) Scope B (shared AppBloc + redirect) is part of the same initiative.

## Success criteria

- [ ] **Scope A:** `very_yummy_coffee_ui` exports **ConnectingView** (optional `message`, design tokens only). All five apps use it inside a thin **ConnectingPage** (route + Scaffold) and pass `context.l10n.connecting` (mobile_app adds l10n key and shows message).
- [ ] **Scope B:** `shared/app_shell` exists with shared **AppBloc**, **AppState**, **AppEvent**, a connecting route path constant, and a redirect helper. All five apps depend on `app_shell`, use the shared bloc and helper, and remove their local app/bloc copies.
- [ ] Redirect behavior is unchanged: disconnected (or initial) → `/connecting`; connected and on `/connecting` → app home. POS keeps exemption for `/order-complete/`; Kiosk for paths containing `/confirmation/`; others no exemption.
- [ ] All existing tests pass or are updated (pump_app, AppBloc tests, app_router tests); no regressions in connection or navigation flows.

## Technical considerations

### UI package constraint

`very_yummy_coffee_ui` must **not** depend on `connection_repository`, `api_client`, or any app. **ConnectingView** takes only primitives (e.g. `String? message`); no Bloc or repository types.

### App_shell routing API (from brainstorm "Notes for planning")

- **Route constant:** `app_shell` exports a connecting route path constant (e.g. `AppShellRoutes.connecting == '/connecting'`) so apps and redirect logic use one value.
- **Redirect helper:** `app_shell` exports a function that apps call from their GoRouter `redirect` callback. Treat `AppStatus.initial` as not connected (same as disconnected). **Allowed when disconnected:** current path is allowed if it **contains** any of the given substrings (e.g. POS `/order-complete/`, Kiosk `/confirmation/`).

Concrete API (to implement in Phase 2):

- `AppShellRoutes.connecting` → `'/connecting'`
- `AppShellRedirect.redirect(BuildContext context, GoRouterState state, {required String connectedHomePath, List<String> allowedWhenDisconnected = const []})` → `String?`  
  Logic: read `context.read<AppBloc>().state.status`. If status != connected and current path != connecting and path is not allowed (current path does not contain any of `allowedWhenDisconnected`) → return connecting path; if status == connected and current path == connecting → return `connectedHomePath`; else `null`.

### Allowed when disconnected (flow analysis)

- **POS:** Allow when path contains `/order-complete/`. Pass `allowedWhenDisconnected: ['/order-complete/']`.
- **Kiosk:** Allow when path contains `/confirmation/`. Pass `allowedWhenDisconnected: ['/confirmation/']`.
- **Mobile, menu_board, kds:** No exemption; pass default `[]`.

### Deep link / reconnect behavior

When user is on `/connecting` and becomes connected, redirect goes to **app home** only (no restoration of previous or deep-linked path). This matches current behavior and is in scope; improving deep-link restoration is out of scope.

### Design tokens and accessibility

- **ConnectingView** uses `context.spacing`, `context.typography`, `context.colors` only. When `message` is non-null, use it for the visible text and set `Semantics(label: message)` so the connecting state is announced; give the **spinner** an appropriate semantic role (e.g. progress) so screen readers get both the label and progress.

### Test migration (from brainstorm)

- Each app’s **pump_app** provides or mocks `AppBloc`; after Scope B, apps use `AppBloc` from `app_shell`, so pump_app must provide the shared type (or a mock that implements it).
- **AppBloc tests** move to `app_shell` (single test file for the shared bloc); apps remove their local `app/bloc/app_bloc_test.dart` and may add a small integration test that app provides AppBloc and redirect works, or rely on router tests.
- **App router tests** in each app continue to test redirect behavior using shared AppBloc (or mock) and shared redirect helper; update expectations to use `AppShellRoutes.connecting` and shared types.

### Out of scope

- Timeout or "Unable to connect" / retry UI when connection never establishes.
- Restoring previous route or deep link after reconnect (always redirect to home).
- A single "App shell" widget that builds BlocProvider + router; apps keep current App + router setup.

## Implementation plan

### Phase 1: Scope A — ConnectingView and app migration

#### 1.1 — ConnectingView in `very_yummy_coffee_ui`

- [ ] **New file:** `shared/very_yummy_coffee_ui/lib/src/widgets/connecting_view.dart`
- [ ] **API:** `message` (`String?`). When non-null, show `Text(message, style: context.typography.body.copyWith(color: context.colors.mutedForeground))` below the spinner; when null, show only the spinner. Use `context.spacing.lg` between spinner and text. Center content in a Column with `mainAxisSize: MainAxisSize.min`. Use `CircularProgressIndicator()`. When `message != null`, apply `Semantics(label: message)` to the message and give the spinner an appropriate semantic role (e.g. progress) for screen readers.
- [ ] Export from `shared/very_yummy_coffee_ui/lib/src/widgets/widgets.dart` and from `very_yummy_coffee_ui.dart`.
- [ ] **Tests:** `shared/very_yummy_coffee_ui/test/src/widgets/connecting_view_test.dart` — renders spinner only when message is null; renders spinner + text when message is set; uses theme (e.g. spacing/typography) when present.

#### 1.2 — Migrate each app’s ConnectingPage to use ConnectingView

- [ ] **All five apps:** Set ConnectingPage body to `Center(child: ConnectingView(message: context.l10n.connecting))`. Remove local spinner/column/text where present. Keep `routeName`, `pageBuilder`, and key `connecting_page` where used. Import `very_yummy_coffee_ui`.
- [ ] **mobile_app only:** Add l10n key `connecting` to `applications/mobile_app/lib/l10n/arb/app_en.arb` (and any other ARBs) with value e.g. "Connecting…". Run l10n codegen.
- [ ] Run all app tests that touch ConnectingPage or app_router (redirect to connecting); fix any snapshot or structure expectations.

### Phase 2: Scope B — app_shell package and migration

#### 2.1 — Create `shared/app_shell` package

- [ ] **New package:** `shared/app_shell/` with `pubspec.yaml` depending on `connection_repository`, `bloc`, `flutter_bloc`, `go_router`, `flutter`. Use `path` for `connection_repository`. Dev deps: `mocktail`, `bloc_test`, `test`, `flutter_test`, `very_good_analysis`. Do **not** depend on `very_yummy_coffee_ui` or `dart_mappable` (AppState is not serialized; use plain `final class` with `copyWith` if needed).
- [ ] **Layout:** Put implementation under `lib/src/` only. Add `analysis_options.yaml` with `include: package:very_good_analysis/analysis_options.yaml`.
- [ ] **AppBloc, AppState, AppEvent:** Copy structure from e.g. `applications/mobile_app/lib/app/bloc/` into `shared/app_shell/lib/src/bloc/`. Use same logic: `AppBloc({required ConnectionRepository connectionRepository})`, `on<AppStarted>(_onStarted)`, `emit.forEach(connectionRepository.isConnected, ...)`. Keep `AppStatus` (initial, connected, disconnected), `AppState(status)`, sealed `AppEvent`, `AppStarted`. Use a plain `final class` for `AppState` (no dart_mappable).
- [ ] **Route constant:** `shared/app_shell/lib/src/app_shell_routes.dart`: `abstract class AppShellRoutes { static const String connecting = '/connecting'; }`.
- [ ] **Redirect helper:** `shared/app_shell/lib/src/app_shell_redirect.dart`: `String? redirect(BuildContext context, GoRouterState state, {required String connectedHomePath, List<String> allowedWhenDisconnected = const []})`. Read `context.read<AppBloc>().state.status`; treat `initial` as not connected. If not connected and path != `AppShellRoutes.connecting` and path does not contain any of `allowedWhenDisconnected` → return `AppShellRoutes.connecting`. If connected and path == `AppShellRoutes.connecting` → return `connectedHomePath`. Else `null`.
- [ ] **Public API:** `lib/app_shell.dart` exports: `AppBloc`, `AppState`, `AppEvent`, `AppStatus`, `AppShellRoutes`, `AppShellRedirect`.
- [ ] **Tests:** `shared/app_shell/test/app_bloc_test.dart` — same cases as current app-level AppBloc tests (initial state, connects, disconnects). `shared/app_shell/test/app_shell_redirect_test.dart` — use a small Flutter widget test with `BlocProvider<AppBloc>` and a shell that invokes the redirect helper to get a real `BuildContext`; cover disconnected → connecting, connected and on connecting → home, allowed path when disconnected → null.
- [ ] Run `.github/update_github_actions.sh` after adding the package; commit workflow changes.

#### 2.2 — Migrate each app to use app_shell

- [ ] **Add dependency:** In each app’s `pubspec.yaml`, add `app_shell: path: ../../shared/app_shell` (or correct relative path).
- [ ] **App widget:** Replace import of local `AppBloc`/`AppState`/`AppEvent`/`AppStatus` with `package:app_shell/app_shell.dart`. Keep `BlocProvider(create: (_) => AppBloc(connectionRepository: context.read<ConnectionRepository>())..add(const AppStarted()))`. Remove local `lib/app/bloc/` directory (app_bloc.dart, app_event.dart, app_state.dart, app_bloc.mapper.dart).
- [ ] **AppRouter:** Use **`AppShellRoutes.connecting`** as the single path for the connecting route (path in route definition and `initialLocation`). Each app’s ConnectingPage can set `static const routeName = AppShellRoutes.connecting` (or equivalent). Replace inline redirect logic with `redirect: (context, state) => AppShellRedirect.redirect(context, state, connectedHomePath: <home>, allowedWhenDisconnected: <list>)`. Use `GoRouterRefreshStream(appBloc.stream)` as today; type of `appBloc` is now from app_shell. Route definition: path `AppShellRoutes.connecting`, pageBuilder builds `ConnectingPage.pageBuilder(context, state)` (ConnectingPage still app-owned, using ConnectingView).

| App | connectedHomePath | allowedWhenDisconnected |
|-----|-------------------|-------------------------|
| mobile_app | `HomePage.routeName` | `[]` |
| kiosk_app | `HomePage.routeName` | `['/confirmation/']` |
| pos_app | `OrderingPage.routeName` | `['/order-complete/']` |
| menu_board_app | `MenuDisplayPage.routeName` | `[]` |
| kds_app | `KdsPage.routeName` | `[]` |

- [ ] **Other references:** Replace any `AppStatus`, `AppBloc`, `AppState`, `AppEvent` imports (e.g. in top bars, menu_display_view) with `app_shell`. Update **pump_app**: import `AppBloc`, `AppEvent`, `AppState` from `package:app_shell/app_shell.dart`; provide `AppBloc` (or a mock implementing it, e.g. `MockBloc<AppEvent, AppState>` implementing `AppBloc`) so router/redirect tests keep working. Update or remove app-level `app/bloc/app_bloc_test.dart` (behavior covered by app_shell tests).
- [ ] **Router tests:** Update expectations to use `AppShellRoutes.connecting` where path is asserted; ensure redirect tests still pass with shared redirect helper.

### Phase 3: Regressions and cleanup

- [ ] Run full test suite for `very_yummy_coffee_ui`, `app_shell`, and all five applications.
- [ ] Manually verify: cold start shows ConnectingView then home; disconnect sends to connecting; reconnect sends to home; POS stays on order-complete when disconnected; Kiosk stays on confirmation when disconnected.
- [ ] Remove any dead code (old app bloc files already removed in 2.2). Update **CODE_SHARING_REPORT.md** todo list: mark TODO 4 (Shared app shell) as done and add a short completion note.

## Dependencies and risks

| Dependency | Notes |
|------------|--------|
| connection_repository | app_shell depends on it; apps already provide it. |
| very_yummy_coffee_ui | Already used by all apps; ConnectingView adds one widget. |
| go_router, flutter_bloc | Already in use; redirect helper composes with existing router. |

| Risk | Mitigation |
|------|------------|
| Redirect behavior differs per app | Document POS/Kiosk allowed paths; unit-test redirect helper with all combinations. |
| Test breakage after removing local AppBloc | Move bloc tests to app_shell; update pump_app and router tests to use shared types. |
| mobile_app l10n | Add `connecting` key to ARB and regenerate; ensure all locales if multiple. |

## Out of scope / follow-up

- Timeout or "Unable to connect" / retry UI.
- Deep link or route restoration when reconnecting from `/connecting`.
- Single reusable "AppShell" widget that builds BlocProvider + router; apps keep current structure.
