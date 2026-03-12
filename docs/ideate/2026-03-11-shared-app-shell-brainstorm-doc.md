---
date: 2026-03-11
topic: shared-app-shell
---

# Shared App Shell (TODO 4) — Brainstorm

## What We're Building

**Goal:** Complete TODO 4 from the Code Sharing Report: reduce duplication of app bootstrap and connection UX across all five apps by sharing a connecting view/page and shared app/connection flow.

**Current state:** Each app has its own:
- **ConnectingPage** — nearly identical (spinner + optional "Connecting…" text); only mobile_app omits the message. menu_board_app already uses `context.spacing` and `context.typography` from the UI package; others use raw `SizedBox(height: 16)` and unscoped `Text`.
- **AppBloc** — identical in all five apps: subscribes to `ConnectionRepository.isConnected`, emits `AppState(status: connected | disconnected)`, single event `AppStarted`.
- **App bootstrap** — each app has its own `App` widget that creates `AppBloc`, provides it, builds `MaterialApp.router` with app-specific `AppRouter` (which uses `ConnectingPage.routeName`, redirect logic, and app-specific home route).

**Constraint (from project rules):** `very_yummy_coffee_ui` must remain repository-agnostic (no dependency on `connection_repository`, `api_client`, or any app). Any shared **logic** (e.g. AppBloc) must live in a separate package that is allowed to depend on `connection_repository`.

---

## Why This Approach

Two scopes were considered:

**Scope A — Shared connecting view (first step)**  
Add a reusable **ConnectingView** to `very_yummy_coffee_ui` that takes an optional `message` (e.g. `String?`) and uses design tokens (`context.spacing`, `context.typography`, `context.colors`). Each app keeps a thin **ConnectingPage** (route + Scaffold) that uses the shared **ConnectingView** as the body and passes `context.l10n.connecting`. No new package; UI package stays repo-agnostic.

- **Pros:** Minimal change, no new dependencies, immediate removal of five duplicate connecting UIs; aligns all apps to the same design tokens.
- **Cons:** AppBloc and redirect logic remain duplicated until Scope B.

**Scope B — Shared app shell package (same initiative)**  
Add **`shared/app_shell`** that depends on `connection_repository` and `very_yummy_coffee_ui`. This package provides:
- Shared **AppBloc** (and **AppState** / **AppEvent**) used by all apps.
- A **connecting route path constant** and/or **redirect helper** so apps don’t duplicate the “if not connected → /connecting; if connected and on /connecting → home” logic. The plan will specify the exact API (e.g. route constant only, redirect callback only, or both).

Apps depend on `app_shell`, use the shared bloc and shared **ConnectingView** from UI, and retain only app-specific routing (e.g. home route) and `App` wiring (BlocProvider + GoRouter).

- **Pros:** Removes duplication of AppBloc and centralizes connection-driven redirect behavior; single place to evolve connection UX.
- **Cons:** New package to maintain; apps must migrate to shared bloc and possibly shared redirect helper.

**Recommendation:** Implement **Scope A** (ConnectingView in `very_yummy_coffee_ui`), then **Scope B** (shared `app_shell` with AppBloc and redirect helper) in the same initiative.

---

## Key Decisions

- **ConnectingView + ConnectingPage naming:** We use view/page, not “screen”. The UI package exposes **ConnectingView** (content only; uses theme/spacing/typography tokens, optional `message`). Each app keeps a thin **ConnectingPage** (route + Scaffold) that uses **ConnectingView** as the body. Route name and `pageBuilder` stay in each app so routers remain app-owned.
- **No repository dependency in UI:** `very_yummy_coffee_ui` does not depend on `connection_repository` or any app/repository package. Shared AppBloc lives in `app_shell` (Scope B).
- **Scope B in same initiative:** Shared AppBloc and redirect helper are part of this initiative, not a later follow-up.
- **Mobile app matches others:** mobile_app shows the same connecting message as the other apps (pass `context.l10n.connecting`); no spinner-only behavior.
- **One source of truth for connecting UI:** All apps use the same **ConnectingView** and design tokens so the connecting experience is consistent.

---

## Open Questions

- None; open questions have been resolved.

---

## Notes for planning

- **App_shell routing API:** Decide whether `app_shell` exports a route path constant, a redirect helper (e.g. function apps call from GoRouter `redirect`), or both.
- **Test migration:** Each app’s `pump_app` and AppBloc tests will need updates when migrating to shared `app_shell`; account for this in the plan.
