---
date: 2026-03-11
topic: shared-menu-feature
---

# Shared Menu Feature (Todo #1)

## What We're Building

A **shared menu feature package** (`shared/menu_feature`) that consolidates the duplicated menu flow used by **mobile_app** and **kiosk_app**: menu groups list and menu items list, including blocs and reusable view building blocks. Both apps currently implement nearly identical `MenuGroupsBloc` and `MenuItemsBloc` (same logic; kiosk’s `MenuItemsState` uses `groupName` while mobile’s uses `group`). Views differ in layout (e.g. list vs horizontal row for groups, list vs grid for items) and in headers (mobile uses a custom header; kiosk uses `KioskHeader`). The goal is to remove duplication and raise the shared-code percentage, while keeping each app’s shell and navigation intact.

**Scope:** Mobile and kiosk only. POS has a different menu flow (`MenuBloc` for ordering); menu_board has `menu_display` for a different use case. They stay out of this initiative.

## Lightweight Research Summary

- **MenuGroupsBloc:** Identical in both apps (~32 lines); subscribes to `menuRepository.getMenuGroups()` and exposes loading/success/failure + list of groups.
- **MenuItemsBloc:** Same pattern in both; takes `menuRepository` and `groupId`, combines `getMenuGroups()` and `getMenuItems(groupId)` (kiosk uses `groupName` in state, mobile uses `group`). Unifying on a single state shape (e.g. `group` + `menuItems`) is straightforward.
- **Views:**  
  - **Menu groups:** Mobile = vertical list of cards + app header (back, title, cart). Kiosk = horizontal row of category cards + `KioskHeader`.  
  - **Menu items:** Mobile = list of item cards + header showing group name/description from state. Kiosk = grid of item cards + `KioskHeader` with `state.groupName`.  
  Both use `context.l10n`, `context.go(...)`, and design tokens from `very_yummy_coffee_ui`; both use `UnavailableOverlay` for items.
- **Pages:** Both apps have almost identical `MenuGroupsPage` / `MenuItemsPage` (BlocProvider + create bloc + dispatch initial event + child View). Only the View widget differs.
- **Existing pattern:** `shared/app_shell` is a good template: small shared package, clear exports, apps depend on it and keep their own routing and top-level UI.

## Approaches Considered

### 1. Blocs only — **Not recommended**

Create `shared/menu_feature` with only `MenuGroupsBloc`, `MenuItemsBloc`, and their events/states. Apps keep their existing views and pages; they just switch to importing blocs from the shared package.

- **Pros:** Smallest change, no view API design, each app keeps full control of layout and copy.
- **Cons:** Saves only bloc + event/state code (~200–300 lines); the large duplicate surface (views) remains. Shared percentage gain is modest.
- **Best when:** You want a minimal first step and plan to add shared views later.

### 2. Blocs + shared content widgets — **Recommended**

Create `shared/menu_feature` with the two blocs (and unified state) plus **shared content widgets** that take data and callbacks only (no app-specific headers or routes):

- **Blocs:** `MenuGroupsBloc`, `MenuItemsBloc` (single `MenuItemsState` shape, e.g. `group` + `menuItems`).
- **Widgets:** Two widgets per concept: `MenuGroupList`, `MenuGroupRow`, `MenuItemList`, `MenuItemGrid`, plus shared card widgets (`MenuGroupCard`, `MenuItemCard`) that the list/row/grid widgets use. Cards take primitives and use `context.colors` / `context.typography`; list/row/grid take data and callbacks (`onGroupTap`, `onItemTap`). No dependency on app l10n or GoRouter; apps pass callbacks that call `context.go(...)` with their own paths.

Apps keep their own **Page** (BlocProvider + route params), their own **header** (e.g. `KioskHeader` or custom), and compose: e.g. `Column(header, Expanded(child: MenuGroupList(...)))`. Mobile uses `MenuGroupList` + `MenuItemList`; kiosk uses `MenuGroupRow` + `MenuItemGrid`.

- **Pros:** Removes bloc duplication and a large share of view duplication; stays consistent with “UI takes primitives and callbacks” (like `OrderCard` in `very_yummy_coffee_ui`). Clear boundary: menu_feature depends on `menu_repository`, `very_yummy_coffee_ui`, `very_yummy_coffee_models`; no app packages.
- **Cons:** Requires agreeing on a small widget API (list vs grid, card content) and one `MenuItemsState` shape.
- **Best when:** You want a real increase in shared code while keeping app-specific shells and navigation.

### 3. Blocs + full shared screens with slots

Same blocs, but add full-screen “views” (e.g. `MenuGroupsView`, `MenuItemsView`) that take a **header slot** and **callbacks** (onBack, onGroupTap, onItemTap, onCartTap). Apps pass `KioskHeader` or a custom header and route-building callbacks.

- **Pros:** Maximum reuse; both apps could use the same screen structure.
- **Cons:** More complex API (slots + many callbacks); list vs grid and other layout differences either require more parameters or a second “variant” screen. Higher design and maintenance cost.
- **Best when:** You are sure both apps will converge on the same screen structure and are willing to maintain a richer shared API.

## Why This Approach (2)

- **YAGNI:** Shared content widgets (lists/cards + callbacks) give most of the line savings without full-screen slots and many callbacks. We can add full-screen views later if needed.
- **Consistency:** Matches the existing pattern (shared primitives in UI package; feature package composes them and exposes blocs + content widgets). Aligns with `app_shell`: feature package, apps wire routes and shell.
- **Right-sized:** One state shape and a small set of widgets (group list/row, item list/grid, and the cards they use) are enough to delete most duplicated view code while keeping mobile vs kiosk layout differences explicit in the app layer.

## Key Decisions

- **Package name and location:** `shared/menu_feature`. Dependencies: `menu_repository`, `very_yummy_coffee_ui`, `very_yummy_coffee_models`, `bloc`, `flutter_bloc`, `dart_mappable`, `rxdart` (for MenuItemsBloc). No dependency on any app package or on `go_router` / app l10n.
- **Single MenuItemsState shape:** Use `group` (e.g. `MenuGroup?`) and `menuItems` in shared state so both “group name in header” and “group details” are available. Kiosk can use `state.group?.name ?? ''`; no need for a separate `groupName` field.
- **Views stay app-owned for shell:** Each app keeps its own `MenuGroupsPage` / `MenuItemsPage` (BlocProvider + routing) and its own header. They use shared blocs and shared content widgets only for the list/grid and cards.
- **Navigation and copy:** Shared widgets do not call `context.go` or `context.l10n`. Apps pass `onGroupTap`, `onItemTap`, etc., and supply localized strings (e.g. error message) from the app when building the screen.
- **POS and menu_board:** Out of scope for this todo; no change to their menu flows.

## Key Decisions (continued)

- **List vs grid / one vs two widgets:** Use **two widgets per concept** (option (a)): `MenuItemList`, `MenuItemGrid`, `MenuGroupList`, `MenuGroupRow`. Each app uses the one it needs; simpler API per widget, no layout enum inside the shared package.
- **Card widgets in package:** The shared list/row/grid widgets use shared card widgets (`MenuGroupCard`, `MenuItemCard`) that live in `menu_feature`, take primitives (name, description, price, available, etc.), and use theme. Apps do not supply their own card builders for these flows.

## Open Questions

- **Route path coupling:** Apps will still use paths like `/home/menu` and `/home/menu/:groupId`. Should `menu_feature` export route path constants (e.g. `MenuFeatureRoutes.groups`, `MenuFeatureRoutes.items`) for apps to use, or leave routing fully in the app? Optional; can be added in planning if we want consistency with `app_shell`.
- **Tests and migration:** Bloc and widget tests move into `menu_feature`; app tests (e.g. `pump_app`, router tests) will need to provide or mock the shared blocs. Migration order (mobile first, kiosk first, or both) to be decided in the implementation plan.
