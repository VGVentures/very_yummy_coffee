# Very Yummy Coffee — Code Sharing Report

A breakdown of **shared** vs **app-specific** Dart code in the monorepo, for presentation use.

---

## Summary


| Category                        | Lib (production) | Test   | Total      |
| ------------------------------- | ---------------- | ------ | ---------- |
| **Shared packages**             | **5,816**        | 2,546  | 8,362      |
| **Backend (API)**               | 306              | 162    | 468        |
| **Applications (app-specific)** | **21,910**       | 10,210 | 32,120     |
| **Total**                       | **28,032**       | 12,918 | **40,950** |


- **Shared (lib)** = code in `shared/` used by multiple apps: **5,816 lines**  
- **App-specific (lib)** = code in each app’s `lib/`: **21,910 lines**  
- **Share of production code that is shared:** **5,816 / (5,816 + 21,910) ≈ 21.0%**

So about **1 in 5 lines** of app-facing production code lives in shared packages and is reused across apps.

---

## Shared Packages (used by multiple apps)

All under `shared/`. Lib = production code; test = tests for that package.


| Package                      | Lib       | Test      | Total     | Purpose                                                    |
| ---------------------------- | --------- | --------- | --------- | ---------------------------------------------------------- |
| **very_yummy_coffee_ui**     | 2,260     | 372       | 2,632     | Design system, widgets (buttons, cards, theme, typography, **OrderCard**, **OrderLineItemRow**, **StatusBadge**) |
| **very_yummy_coffee_models** | 1,739     | 610       | 2,349     | Domain models, RPC protocol (menu, orders, actions)        |
| **order_repository**         | 1,227     | 727       | 1,954     | Order domain, WebSocket-synced mutations                   |
| **api_client**               | 409       | 588       | 997       | HTTP + WebSocket client, `WsRpcClient`                     |
| **menu_repository**          | 158       | 211       | 369       | Menu domain, ref-counted WS subscription                   |
| **connection_repository**    | 23        | 38        | 61        | Connection state                                           |
| **Shared total**             | **5,816** | **2,546** | **8,362** |                                                            |


*Note: `very_yummy_coffee_ui` includes the gallery app (design system showcase) under `lib/`.*

---

## Backend (API)

Dart Frog API in `api/`: routes, RPC handler, server state. Single backend used by all apps.


| Area    | Lib | Test | Total |
| ------- | --- | ---- | ----- |
| **API** | 306 | 162  | 468   |


---

## Applications (app-specific code)

Each row is one deployable app. Lib = that app’s own `lib/`; test = that app’s `test/`.


| Application        | Lib        | Test       | Total      | Role                                    |
| ------------------ | ---------- | ---------- | ---------- | --------------------------------------- |
| **mobile_app**     | 6,961      | 3,132      | 10,093     | Customer mobile (order, cart, checkout) |
| **kiosk_app**      | 6,884      | 2,427      | 9,311      | Kiosk ordering                          |
| **pos_app**        | 4,866      | 2,541      | 7,407      | POS (ordering, orders, stock)           |
| **menu_board_app** | 1,622      | 1,252      | 2,874      | Menu / order status display             |
| **kds_app**        | 1,577      | 858        | 2,435      | Kitchen display                         |
| **Apps total**     | **21,910** | **10,210** | **32,120** |                                         |


---

## Narrative for the presentation

1. **Shared vs app-specific**
  - **5,816 lines** of production code are in shared packages.
  - **21,910 lines** are app-specific across 5 apps.
  - So **~21%** of app-facing production code is shared.
2. **What’s shared**
  - **UI**: theme, spacing, typography, buttons, cards, top bar, modifier selectors, **order card**, **line item row**, **status badge**, etc. (`very_yummy_coffee_ui`).
  - **Domain**: menu and order models, RPC types (`very_yummy_coffee_models`).
  - **Data layer**: menu and order repositories, API/WebSocket client (`api_client`, `menu_repository`, `order_repository`, `connection_repository`).
3. **Duplication avoided**
  - Without shared packages, each of the 5 apps would need its own copy of that logic and UI.
  - A naive “copy-paste” would mean **5 × 5,816 ≈ 29,080** lines of duplicated code instead of **5,816** shared — so the monorepo avoids on the order of **~23,000** lines of duplication.
4. **Per-app view**
  - Each app stays focused on its own flows (e.g. KDS ~1.6k lib lines, mobile ~7k).
  - They all rely on the same **5,816** lines of shared code for models, repositories, API client, and UI primitives.

---

## Suggestions to increase shared code (raise the percentage)

Below are concrete ways to move more logic and UI into shared packages so the shared percentage grows well above 21%. Each suggestion is scoped so that `very_yummy_coffee_ui` stays repository-agnostic (per project rules).

---

### Ranked by code saving (highest impact first)

| Rank | Suggestion | Est. lines saved (moved to shared or removed) |
|------|------------|-------------------------------------------------|
| 1 | Shared feature packages (menu, cart, checkout, order-complete) | **5,000–8,000** |
| 2 | Order status / order ticket reuse (shared order list & detail UI) | **2,000–4,000** *(partially done: OrderCard, OrderLineItemRow, StatusBadge; POS + KDS migrated)* |
| 3 | Shared app shell and connection UX | **1,500–2,000** |
| 4 | Shared localization (base ARB / shared l10n) | **1,000–1,500** |
| 5 | More shared widgets in UI package (+ order card, line item, etc.) | **1,500–3,000** *(order card, line item row, status badge done)* |
| 6 | Shared router / navigation conventions | **~500** *(app shell connecting route + redirect done)* |

---

### Todo list (in recommended order)

- [x] **1. Shared menu feature** — Create `shared/menu_feature`. Move `MenuGroupsBloc`, `MenuItemsBloc`, and shared menu group/item views from mobile_app and kiosk_app. Wire both apps to use the package. *(Largest single win; do first.)* **Done (Mar 2026):** `shared/menu_feature` created with MenuGroupsBloc, MenuItemsBloc, MenuGroupList, MenuGroupRow, MenuItemList, MenuItemGrid (cards internal). Mobile and kiosk migrated; both use shared blocs and widgets.
- [ ] **2. Shared ordering feature** — Create `shared/ordering_feature` (or `cart_feature`). Move `CartBloc`, `CheckoutBloc`, `OrderCompleteBloc`, and shared cart/checkout/order-complete views from mobile_app and kiosk_app. Wire both apps to use the package.
- [x] **3. Shared order list/detail widgets** — Add reusable order card, line item row, and status badge to `very_yummy_coffee_ui` (or a shared feature package). Migrate pos_app order_ticket/order_history, menu_board_app order_status, and kds_app order views to use them. **Done (Mar 2026):** `OrderCard`, `OrderLineItemRow`, and `StatusBadge` added to `very_yummy_coffee_ui`; pos_app order history and order ticket and kds_app `KdsOrderCard` migrated; menu_board continues to use `OrderStatusCard` as-is.
- [x] **4. Shared app shell** — Add `ConnectingView` (and optional message) to `very_yummy_coffee_ui`. Add `shared/app_shell` with shared `AppBloc`, `AppShellRoutes.connecting`, and `redirect()` helper. All five apps use `ConnectingView`, depend on `app_shell`, and removed local app bloc. **Done (Mar 2026).**
- [ ] **5. Shared localization** — Create a shared base ARB package or shared l10n package for common strings. Have each app depend on it and extend/override for app-specific copy.
- [ ] **6. More shared UI primitives** — Add parameterized widgets (order complete screen, cart line item, summary row, etc.) to `very_yummy_coffee_ui`. Refactor mobile, kiosk, and pos to use them.
- [ ] **7. Shared route constants / builders** — Define shared route name constants and optional `pageBuilder` helpers in shared feature packages. Update app routers to use them.

*Do 1–2 first for maximum code saving; 3–4 next; then 5–7 to push shared % toward 40–50%.*

### 1. **Shared feature packages (menu, cart, checkout, order-complete)**

**What’s duplicated today:** `menu_groups`, `menu_items`, `cart`, `checkout`, and `order_complete` are implemented separately in **mobile_app** and **kiosk_app** with nearly identical Blocs and very similar views (e.g. `MenuGroupsBloc` is the same 32-line implementation in both). POS has its own `menu` and `order_complete` with overlapping behavior.

**Suggestion:** Introduce shared *feature* packages that depend on `very_yummy_coffee_ui`, `menu_repository`, `order_repository`, and `very_yummy_coffee_models`:

- **`shared/menu_feature`** — Shared `MenuGroupsBloc` / `MenuItemsBloc` (or a single “menu” bloc), plus shared menu list/group views that take callbacks or domain types. Apps keep only routing and any app-specific layout (e.g. kiosk vs mobile shell).
- **`shared/ordering_feature`** or **`shared/cart_feature`** — Shared `CartBloc`, `CheckoutBloc`, `OrderCompleteBloc`, and shared cart/checkout/order-complete views parameterized by theme and callbacks. Again, apps only wire routes and top-level shell.

**Impact:** A large chunk of the ~12.4k lines in the duplicated areas (menu_groups, menu_items, cart, checkout, order_complete across mobile + kiosk, and parts of pos) could become one shared implementation plus thin app-specific wiring. Moving on the order of **5,000–8,000** lines from apps into shared is realistic, which would significantly increase the shared percentage (e.g. toward **35–40%+**).

---

### 2. **Shared app shell and connection UX**

**What’s duplicated today:** Every app has its own `AppBloc`, `ConnectingPage`, and app-level view/router setup. The connecting experience is almost the same (e.g. spinner + optional “Connecting…” text); only the package import and sometimes l10n differ.

**Suggestion:**

- Add a **shared connecting screen** in `very_yummy_coffee_ui` (e.g. `ConnectingView` with optional message and optional key/route name), so all apps use the same widget and only pass in localized strings.
- If connection/init logic is the same across apps, consider a small **`shared/app_shell`** (or similar) package that provides a reusable `AppBloc` (or base) and a standard “connecting → ready” flow. Apps would depend on it and plug in their routes and home screen.

**Impact:** Removes duplicated “app bootstrap” and connecting UI across five apps (~2,170 lines in app/ today), replacing it with one shared implementation and thin app wiring.

---

### 3. **Shared localization (l10n)**

**What’s duplicated today:** Each app has its own ARB files and generated `app_localizations_*.dart`. Many strings are the same (e.g. “Connecting”, “Cart”, “Checkout”, “Order complete”, button labels, errors).

**Suggestion:**

- Introduce a **shared base ARB** (or a shared package that exports a base `AppLocalizations`-like interface) for common strings. Apps can depend on this package and extend/override for app-specific copy.
- Alternatively, use a single shared Flutter project or package that generates one set of base localizations; apps then add their own ARB files that extend or override keys.

**Impact:** Reduces duplicated string definitions and generated l10n code across five apps (today ~2,880+ lines in app l10n), and keeps one source of truth for shared copy.

---

### 4. **More shared widgets in `very_yummy_coffee_ui`**

**What’s duplicated today:** Views that are “same structure, different styling or labels” (e.g. order complete screen, cart line item, order status card) are reimplemented per app.

**Suggestion:**

- For any screen or list item that is layout-heavy and reusable, add a **parameterized widget** in `very_yummy_coffee_ui` that takes primitives (e.g. title, subtitle, price, status, callbacks) and uses `context.colors`, `context.typography`, etc. No dependency on repositories; apps pass data from their Blocs.
- Expand the design system in the UI package (e.g. more list tiles, status chips, summary rows) so apps compose these instead of building custom layouts.

**Update (Mar 2026):** Order-related widgets are now shared: **OrderCard**, **OrderLineItemRow**, and **StatusBadge** live in `very_yummy_coffee_ui`; POS order history and order ticket and KDS order cards use them. Menu board still uses `OrderStatusCard` as-is.

**Impact:** Shrinks app-specific view code and grows the shared UI surface, which also makes it easier to add new apps that look and behave consistently.

---

### 5. **Shared router / navigation conventions**

**What’s duplicated today:** Each app defines its own `GoRouter` and route names (e.g. `/connecting`, `/home/menu`, `/cart`, `/checkout`, `/order-complete`). Structure is similar across mobile and kiosk.

**Suggestion:**

- Define **shared route name constants** (and optionally shared route path builders) in a small shared package or in a shared feature package. Apps still own their `GoRouter` instance but use the same path names and optionally shared `pageBuilder` functions that live in the feature package.
- This goes hand-in-hand with (1): once menu/cart/checkout/order-complete are in shared feature packages, those packages can export standard route segments and builders; apps just compose them.

**Impact:** Less duplicated routing code and fewer “copy-paste” route definitions when adding or changing flows.

---

### 6. **Order status / order ticket reuse**

**What’s duplicated today:** POS has `order_ticket` and `order_history`; menu_board has `order_status`; KDS has order-focused views. There is overlap in “show a list of orders” and “show one order’s lines/status”.

**Suggestion:**

- Extract **shared order list and order detail widgets** (e.g. order card, line item row, status badge) into `very_yummy_coffee_ui` or a shared feature package, taking primitive data (order id, status, line items, callbacks). POS, menu_board, and KDS would use these and only supply app-specific actions or layout.
- If the *logic* (e.g. “subscribe to order”, “subscribe to orders list”) is the same, that can live in a shared feature bloc or repository usage; views stay parameterized.

**Done (Mar 2026):** **OrderCard**, **OrderLineItemRow**, and **StatusBadge** were added to `very_yummy_coffee_ui`. POS order history and order ticket now use them (with app-level mapping from `Order`/`LineItem`); KDS **KdsOrderCard** was refactored to use **OrderCard**. Menu board continues to use **OrderStatusCard** unchanged. The UI package remains repository-agnostic; apps pass primitives only.

**Impact:** Reduces duplication in the ~2k–4k lines of order-related views across pos_app, menu_board_app, and kds_app.

---

### 7. **Rough impact on the shared percentage**

If you implement the highest-leverage items:

| Change | Approx. lines moved to shared | Effect |
|--------|-------------------------------|--------|
| Shared menu + cart + checkout + order-complete (1) | ~5,000–8,000 | Big jump in shared lib |
| Shared app shell / connecting (2) | ~1,500–2,000 | Fewer app-specific lines |
| Shared l10n base (3) | ~1,000–1,500 | Less duplication per app |
| More shared widgets (4) + order UI (6) | ~1,500–3,000 | Apps get thinner |

**Illustrative “after” scenario:** If ~8,000 lines move from apps to shared (and tests move with them), shared lib might go from **5,816** to ~**13,800** and app-specific from **21,910** to ~**13,900**. Then:

**Shared % ≈ 13,800 / (13,800 + 13,900) ≈ 50%.**

So a realistic target is **on the order of 40–50% shared** by lifting duplicated features and app shell into shared packages and shared UI.

---

## How the counts were done

- **Scope:** All `.dart` files under `shared/`, `api/`, and `applications/`.
- **Lib:** Files under each package’s or app’s `lib/` (and for API, `routes/` and `main.dart`).
- **Test:** Files under each package’s or app’s `test/`.
- **Excluded:** Generated output (e.g. `.dart_frog/`) and tooling (e.g. `.dart_tool/`) from the totals; API line count uses hand-written source only.
- **Date:** March 2025 (run `find` + `wc -l` on the repo to refresh). *Updated Mar 2026: shared order list/detail widgets (OrderCard, OrderLineItemRow, StatusBadge) implemented; POS and KDS migrated.*

