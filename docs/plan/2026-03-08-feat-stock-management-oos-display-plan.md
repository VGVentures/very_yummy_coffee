---
title: "feat: add stock management and out-of-stock display"
type: feat
date: 2026-03-08
---

## feat: add stock management and out-of-stock display - Extensive

## Overview

Add a complete stock availability feature: POS baristas toggle menu items in/out of stock via a dedicated Stock Management screen, with real-time out-of-stock (OOS) treatment propagated to all surfaces (POS ordering, mobile, kiosk, menu board). Carts containing items that become OOS mid-session block checkout until the customer removes them.

The backend infrastructure already exists (`MenuItem.available`, `updateMenuItemAvailability` WS action, live menu broadcasts). This feature wires UI on top and adds `menuItemId` to `LineItem` for cart-availability cross-referencing.

## Problem Statement

Baristas currently have no in-app way to mark items as out of stock. The `MenuItem.available` field and `updateMenuItemAvailability` WS action exist server-side but no UI exposes them. Customer-facing surfaces (mobile, kiosk) do not visually distinguish unavailable items, and carts have no guard against items that become unavailable mid-session.

**Consequences:**
- Customers can add OOS items to their cart and place orders the kitchen cannot fulfill
- Baristas must verbally communicate stock status or refuse orders at the counter
- Menu boards display items the shop cannot serve

## Proposed Solution

1. **Add `menuItemId` to `LineItem`** — foundational model change enabling cart-availability cross-referencing
2. **Add `menu_repository.setItemAvailability()`** — client method wrapping the existing WS action
3. **POS Stock Management screen** (`/stock-management`) — dedicated tab with all items grouped by category, each with a toggle switch
4. **OOS display across all surfaces** — dimmed/disabled treatment on item cards and detail pages
5. **Cart-level availability checking** — `CartBloc` subscribes to menu state, warns on OOS items, blocks checkout

## Technical Approach

### Architecture

#### Data Flow

```
Barista toggles item OOS on POS
  → menu_repository.setItemAvailability(itemId, false)
    → WsRpcClient.sendAction('updateMenuItemAvailability', {...})
      → Server updates _menuItems, broadcasts 'menu' topic
        → All connected clients receive updated MenuItem.available
          → Menu views re-render with OOS treatment
          → Cart blocs cross-reference LineItem.menuItemId → MenuItem.available
            → Checkout blocked if any cart item is OOS
```

#### Key Architecture Decisions

| Decision | Choice | Rationale |
|---|---|---|
| `menuItemId` on `LineItem` | Nullable `String?` | Backward compat — older orders without it are treated as available |
| Cart availability checking | `CartBloc` depends on both `OrderRepository` + `MenuRepository` | Bloc uses `Rx.combineLatest2` on order + menu streams; keeps logic testable |
| POS order ticket OOS blocking | View-layer `BlocSelector` on `MenuBloc`, not `OrderTicketBloc` change | Avoids dual-stream complexity in a second bloc; `OrderTicketBloc` stays unchanged |
| Server-side validation | **Not in v1** | Client-side guards + cart warnings are sufficient; server validation is a follow-up |
| OOS item tap on mobile | Navigates to detail with add disabled | Matches kiosk behavior; customer can still see item info |
| POS stock management layout | Full-screen (no order ticket panel) | Purpose-built for scanning; order is preserved in `OrderRepository` |
| Menu board OOS treatment | Dimmed + "Unavailable" label (not hidden) | Customers see the full menu, know what exists even if temporarily unavailable |
| Confirmation on toggle | No confirmation dialog in v1 | Instant toggle; accidental toggles are easily reversed |
| Search/filter on stock screen | Not in v1 | Grouped-by-category is sufficient for current menu size |

### Implementation Phases

#### Phase 0: Model & Repository Foundation

Add `menuItemId` to the data model and create `setItemAvailability()`.

- [ ] Add `menuItemId` field (`String?`) to `LineItem` model
  - File: `shared/order_repository/lib/src/models/line_item.dart`
  - Nullable with default `null` for backward compatibility
  - `dart_mappable` treats missing keys as `null` for nullable fields — verify with generated mapper
  - **Important:** `menuItemId` is the `MenuItem.id` (e.g., `'101'`), NOT the `LineItem.id` which is a UUID
- [ ] Update server `addItemToOrder` handler to pass through `menuItemId`
  - File: `api/lib/src/server_state.dart` (line ~134)
  - Add `'menuItemId': payload['menuItemId'] as String?` to stored line item map
- [ ] Update `OrderRepository.addItemToCurrentOrder()` to accept and send `menuItemId`
  - File: `shared/order_repository/lib/src/order_repository.dart` (line ~71)
  - Add optional `String? menuItemId` parameter, include in WS payload
- [ ] Add `void setItemAvailability(String itemId, {required bool available})` method to `MenuRepository`
  - File: `shared/menu_repository/lib/src/menu_repository.dart`
  - Returns `void` (not `Future<void>`) — `WsRpcClient.sendAction` is synchronous
  - Sends `updateMenuItemAvailability` WS action via `_wsRpcClient.sendAction`
- [ ] Update CLAUDE.md WS action docs to include `menuItemId` in `addItemToOrder` payload
- [ ] Update all `addItemToCurrentOrder` call sites to pass `menuItemId`:
  - `applications/pos_app/lib/menu/bloc/menu_bloc.dart` — POS `_onItemAdded`
  - `applications/mobile_app/lib/item_detail/bloc/item_detail_bloc.dart` — mobile `_onAddToCartRequested`
  - `applications/kiosk_app/lib/item_detail/bloc/item_detail_bloc.dart` — kiosk `_onAddToCartRequested`
- [ ] Write unit tests for `LineItem` model with and without `menuItemId` (including deserialization when key is absent from JSON)
- [ ] Write unit tests for `MenuRepository.setItemAvailability()`
- [ ] Write unit tests for `OrderRepository.addItemToCurrentOrder()` with `menuItemId`
- [ ] Run `.github/update_github_actions.sh` if any pubspec changes

**Success criteria:** `menuItemId` round-trips through WS → server → broadcast → client. `setItemAvailability` toggles server state and broadcasts.

---

#### Phase 1: Shared UI Widgets

Create reusable OOS display primitives in `very_yummy_coffee_ui`.

- [ ] Create `OutOfStockBadge` widget in `shared/very_yummy_coffee_ui/lib/src/widgets/`
  - Accepts `String label` (defaults to "Unavailable")
  - Small red/destructive chip using `context.colors.statusDestructiveBackground/Foreground`
  - No domain type dependencies (pure UI)
- [ ] Create `UnavailableOverlay` widget in `shared/very_yummy_coffee_ui/lib/src/widgets/`
  - Accepts `Widget child` and `bool isUnavailable`
  - When `isUnavailable`: renders child with `unavailableOverlay` color overlay + centered `OutOfStockBadge`
  - When available: renders child unmodified
  - Uses `context.colors.unavailableOverlay` token
- [ ] Export both from `shared/very_yummy_coffee_ui/lib/src/widgets/widgets.dart`
- [ ] Add `Semantics(label: 'Unavailable')` wrapper when OOS for accessibility
- [ ] Write widget tests for `OutOfStockBadge` and `UnavailableOverlay`

**Success criteria:** Both widgets render correctly, accessible via screen readers, and only use design tokens.

---

#### Phase 2: POS Stock Management Screen

New dedicated screen for baristas to manage item availability.

- [ ] Create `stock_management` feature directory in POS app:
  - `lib/stock_management/bloc/stock_management_bloc.dart`
  - `lib/stock_management/bloc/stock_management_event.dart`
  - `lib/stock_management/bloc/stock_management_state.dart`
  - `lib/stock_management/view/stock_management_page.dart`
  - `lib/stock_management/view/stock_management_view.dart`
  - `lib/stock_management/view/widgets/stock_item_tile.dart`
  - `lib/stock_management/stock_management.dart` (barrel)
- [ ] `StockManagementBloc`:
  - Depends on `MenuRepository`
  - Events: `StockManagementSubscriptionRequested`, `StockManagementItemToggled(String itemId, bool available)`
  - State: `StockManagementState` with `List<MenuGroup> groups`, `List<MenuItem> items`, `StockManagementStatus`
  - Subscribes to `menuRepository.getMenuGroupsAndItems()` for live updates
  - On toggle: calls `menuRepository.setItemAvailability(itemId, available: !current)`
- [ ] `StockManagementPage` — provides `StockManagementBloc` via `BlocProvider(create: ..., child: StockManagementView())` so it is automatically closed when the page is popped
- [ ] `StockManagementView` — vertical scrollable list grouped by `MenuGroup` headers
  - Each group header shows group name and count of available/total items
  - Each item row: item name, price, `Switch` toggle (on = in stock, off = OOS)
  - OOS items shown with dimmed text
- [ ] `StockItemTile` — extracted widget for each item row with toggle
- [ ] Add `/stock-management` route to POS `AppRouter`
  - File: `applications/pos_app/lib/app/app_router/app_router.dart`
- [ ] Update `PosTopBar` to add "Stock" navigation button
  - File: `applications/pos_app/lib/ordering/view/widgets/pos_top_bar.dart`
  - Add as an additional `actionWidget` to the left of the existing "View Orders" button
  - Only shown when `showBackButton` is `false` (i.e., on the ordering screen)
  - Navigates to `/stock-management` via `context.go('/stock-management')`
- [ ] Add l10n keys: `posStockManagement`, `posStockInStock`, `posStockOutOfStock`, `posStockItemCount`
- [ ] Write bloc tests for `StockManagementBloc` (subscription, toggle success/failure)
- [ ] Write widget tests for `StockManagementPage`, `StockManagementView`, `StockItemTile`

- [ ] **Verify POS ordering grid OOS treatment** (already partially implemented):
  - Audit `applications/pos_app/lib/menu/view/widgets/menu_item_card.dart` for OOS treatment
  - Migrate to shared `UnavailableOverlay` widget if not already using it
  - Update any raw `theme.colorScheme.*` / `theme.textTheme.*` usage to `context.colors.*` / `context.typography.*` design tokens
  - Add `Semantics` for screen reader accessibility
  - Verify/add widget tests for OOS state on POS menu item card

**Success criteria:** Barista can navigate to Stock Management, see all items by category, toggle availability, and see real-time updates. POS ordering grid shows dimmed, non-interactive cards for OOS items using shared widgets.

---

#### Phase 3: OOS Display on Mobile App

Add OOS treatment to mobile menu list and item detail.

- [ ] Update `_MenuItemCard` in `applications/mobile_app/lib/menu_items/view/menu_items_view.dart`
  - Wrap card content with `UnavailableOverlay(isUnavailable: !item.available, child: ...)`
  - Item remains tappable (navigates to detail) but visually dimmed
- [ ] Update mobile `ItemDetailView` / `ItemDetailBloc`
  - File: `applications/mobile_app/lib/item_detail/view/item_detail_view.dart`
  - File: `applications/mobile_app/lib/item_detail/bloc/item_detail_bloc.dart`
  - Show `OutOfStockBadge` on item detail when `!item.available`
  - Disable "Add to Cart" button when `!item.available`
  - Guard `_onAddToCartRequested` to reject if item is unavailable
- [ ] Add l10n key: `itemUnavailable` (if not already present)
- [ ] Write widget tests for mobile menu item card OOS state
- [ ] Write widget tests for mobile item detail OOS state
- [ ] Write bloc tests for `ItemDetailBloc` rejecting add when OOS

**Success criteria:** Mobile users see dimmed OOS items in the menu list, can view details but cannot add OOS items to cart.

---

#### Phase 4: OOS Display on Kiosk App

Kiosk item detail already handles OOS. Add treatment to kiosk menu items grid.

- [ ] Audit kiosk `ItemDetailPage` — confirm existing OOS treatment is complete
  - File: `applications/kiosk_app/lib/item_detail/view/item_detail_view.dart`
- [ ] Update kiosk menu items grid/list to show OOS treatment
  - Find the kiosk menu items view widget
  - Wrap item cards with `UnavailableOverlay(isUnavailable: !item.available, child: ...)`
  - Items remain tappable (navigate to detail with OOS overlay)
- [ ] Write widget tests for kiosk menu item card OOS state

**Success criteria:** Kiosk users see dimmed OOS items in the grid, detail page shows OOS overlay with add disabled.

---

#### Phase 5: OOS Display on Menu Board

Change menu board from hiding OOS items to showing them dimmed.

- [ ] Update `MenuDisplayBloc`/`MenuDisplayState` to stop filtering by `i.available`
  - File: `applications/menu_board_app/lib/menu_display/bloc/menu_display_state.dart`
  - Remove the `i.available` filter in `_groupEntriesFor`. Keep the `.where((entry) => entry.$2.isNotEmpty)` filter since it handles groups with no items at all — groups with only-OOS items will now correctly display
  - Also update `featuredLeft` and `featuredRight` getters which filter by `.available` — show OOS featured items with dimmed treatment instead of skipping them
- [ ] Update `MenuColumn` widget to show OOS items with dimmed treatment
  - Wrap OOS items with `UnavailableOverlay` or equivalent visual
  - Show "Unavailable" label below item name/price
- [ ] Update `FeaturedItemPanel` to handle OOS featured items
  - Show dimmed treatment with "Unavailable" label instead of hiding
- [ ] Add l10n key: `menuBoardItemUnavailable` (if not already present via `notAvailable`)
- [ ] Write widget tests for menu board OOS display

**Success criteria:** Menu board shows all items; OOS items are visually dimmed with "Unavailable" label.

---

#### Phase 6: Cart Availability Checking

Add menu awareness to cart blocs and block checkout when OOS items are present.

**Stream combination strategy:** Modify the `CartSubscriptionRequested` handler to use `Rx.combineLatest2` on `orderRepository.currentOrderStream` and `menuRepository.getMenuGroupsAndItems()`, then `emit.forEach` on the combined stream. The `onData` callback computes `unavailableLineItemIds` by cross-referencing `LineItem.menuItemId` against `MenuItem.available`. No new event class is needed — just modify the existing handler. `CartBloc` must properly cancel its `MenuRepository` subscription on close to avoid ref-count leaks.

- [ ] Update mobile `CartBloc` to depend on `MenuRepository`
  - File: `applications/mobile_app/lib/cart/bloc/cart_bloc.dart`
  - Add `MenuRepository` constructor parameter
  - In `_onSubscriptionRequested`: use `Rx.combineLatest2(orderRepository.currentOrderStream, menuRepository.getMenuGroupsAndItems(), (order, menuData) => ...)` as the single stream for `emit.forEach`
  - Derive `Set<String> unavailableMenuItemIds` from menu items where `!available`
  - Add `List<String> unavailableLineItemIds` to `CartState` — line items whose `menuItemId` is in the unavailable set (items with `null` `menuItemId` are treated as available)
  - Add `bool get hasUnavailableItems` getter to `CartState`
- [ ] Update mobile `CartView` to show OOS warnings
  - File: `applications/mobile_app/lib/cart/view/cart_view.dart`
  - On affected line items: show `OutOfStockBadge` or red "Unavailable" indicator
  - Disable checkout button when `state.hasUnavailableItems`
  - Show explanatory text: "Remove unavailable items to proceed"
- [ ] Update mobile `CartPage` to provide `MenuRepository` to `CartBloc`
- [ ] Update kiosk `CartBloc` with same `Rx.combineLatest2` pattern
  - File: `applications/kiosk_app/lib/cart/bloc/cart_bloc.dart`
- [ ] Update kiosk `CartView` with same OOS warning treatment
  - File: `applications/kiosk_app/lib/cart/view/cart_view.dart`
- [ ] POS order ticket OOS blocking — **view-layer approach, no `OrderTicketBloc` change**:
  - In POS `OrderTicketView`, use `BlocSelector<MenuBloc, MenuState, Set<String>>` to derive the set of unavailable `menuItemId`s from the already-provided `MenuBloc`
  - Cross-reference order line items against this set to show OOS warnings
  - Disable charge button when any line item is OOS
  - This avoids adding `MenuRepository` to `OrderTicketBloc` and keeps the bloc unchanged
- [ ] Update POS `OrderTicketView` to show OOS line item warnings
- [ ] Disable quantity increment on OOS cart items (decrement/remove stays enabled)
- [ ] Add l10n keys: `cartItemUnavailable`, `cartRemoveUnavailableToCheckout`
- [ ] Write bloc tests for `CartBloc` with unavailable items, including `null` `menuItemId` treated as available (mobile + kiosk)
- [ ] Write widget tests for cart OOS warning display (mobile + kiosk + POS)

**Success criteria:** When an item becomes OOS while in a customer's cart, a warning appears on the line item and checkout is blocked until the item is removed.

## Alternative Approaches Considered

### Cart availability: auto-remove OOS items
Instead of blocking checkout, automatically remove OOS items and show a snackbar. Rejected because it's surprising — the customer added the item intentionally and should decide whether to remove it, wait for restocking, or find an alternative.

### Stock management: inline toggles on ordering grid
Embed toggle switches directly on POS menu item cards. Rejected because it clutters the ordering UI and risks accidental toggles during order-taking.

### Stock management: bottom sheet overlay
A quick-access bottom sheet from the ordering screen. Rejected because it doesn't provide a full view of all items and adds complexity to the ordering screen.

### Server-side validation of OOS on add/submit
The server could reject `addItemToOrder` for OOS items and reject `submitOrder` with OOS line items. Deferred to a follow-up — client-side guards and cart warnings handle the common case. Server validation would be a safety net for race conditions but adds server complexity.

## Acceptance Criteria

### Functional Requirements

- [ ] POS barista can navigate to Stock Management from the top bar
- [ ] Stock Management shows all menu items grouped by category with toggle switches
- [ ] Toggling an item sends `updateMenuItemAvailability` WS action
- [ ] All surfaces update in real-time when availability changes
- [ ] OOS items on POS ordering grid are dimmed and cannot be added to orders
- [ ] OOS items on mobile menu list are dimmed; tapping navigates to detail with add disabled
- [ ] OOS items on kiosk menu grid are dimmed; detail page shows OOS overlay with add disabled
- [ ] OOS items on menu board are dimmed with "Unavailable" label (not hidden)
- [ ] Cart line items show warning when their `menuItemId` maps to an OOS `MenuItem`
- [ ] Checkout is blocked when cart contains OOS items
- [ ] Removing OOS items from cart re-enables checkout
- [ ] `menuItemId` is stored on `LineItem` for all new orders
- [ ] Orders created before the model change (null `menuItemId`) are treated as available

### Non-Functional Requirements

- [ ] All new views use design tokens (`context.colors`, `context.spacing`, `context.typography`, `context.radius`)
- [ ] No raw `Color(0xFF...)`, `Colors.*`, `EdgeInsets.fromLTRB`, or inline `TextStyle` with `fontFamily`
- [ ] Screen reader announces "Unavailable" on OOS items (`Semantics` widget)
- [ ] Real-time updates arrive within normal WS latency (no additional delay)

### Quality Gates

- [ ] All new blocs have complete bloc tests (subscribe, success, failure, edge cases)
- [ ] All new widgets have widget tests using `pumpApp`
- [ ] All shared widgets (`OutOfStockBadge`, `UnavailableOverlay`) have widget tests
- [ ] CI passes (`.github/update_github_actions.sh` run if pubspec changed)
- [ ] No lint warnings from `very_good_analysis` or `bloc_lint`
- [ ] Final verification: `dart format` and `dart fix --apply` across all affected packages

## Dependencies & Prerequisites

| Dependency | Status | Notes |
|---|---|---|
| `MenuItem.available` field | Exists | `shared/very_yummy_coffee_models/lib/src/models/menu_item.dart` |
| `updateMenuItemAvailability` WS action | Exists | `api/lib/src/server_state.dart:100` |
| `unavailableOverlay` color token | Exists | `shared/very_yummy_coffee_ui/lib/src/colors/app_colors.dart` |
| `statusDestructive*` color tokens | Exist | For `OutOfStockBadge` styling |
| `WsRpcClient.sendAction` | Exists | `shared/api_client/lib/src/ws_rpc_client.dart:75` |
| POS app top bar (`PosTopBar`) | Exists | `applications/pos_app/lib/ordering/view/widgets/pos_top_bar.dart` |
| Kiosk OOS on ItemDetailPage | Exists | Already dims and disables add button |
| Menu board featured panel OOS | Exists (partial) | Shows "Not available" text; needs change to dimmed display |

## Risk Analysis & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Race condition: customer adds OOS item between UI render and WS action | Low | Medium | Cart-level warning catches it after the fact; server validation is a follow-up |
| `menuItemId` backward compat: old orders crash on deserialize | Low | High | Make `menuItemId` nullable (`String?`); null treated as available |
| Cart bloc complexity from dual-stream subscription | Medium | Medium | Well-tested with `blocTest`; use `Rx.combineLatest2` pattern |
| POS order ticket loses context when navigating to stock management | Low | Low | Order preserved in `OrderRepository._currentOrderId`; rehydrates on return |
| Menu board visual degradation when many items OOS | Low | Low | Dimmed items still fill space; better than empty gaps from hiding |

## Future Considerations

- **Server-side validation**: Reject `addItemToOrder` and `submitOrder` for OOS items as a safety net against race conditions
- **Batch toggle**: "Mark all in category as OOS" for end-of-day scenarios
- **Search/filter on stock management**: Useful when the menu grows beyond a single scrollable list
- **Toggle confirmation dialog**: "This item is in X active carts" warning before toggling OOS
- **Stock quantity tracking**: Replace boolean `available` with integer `stockCount` for automatic OOS at zero
- **Toggle history/audit log**: Track who toggled what and when for accountability

## References & Research

### Internal References

- Brainstorm: [2026-03-08-stock-management-oos-display-brainstorm-doc.md](docs/ideate/2026-03-08-stock-management-oos-display-brainstorm-doc.md)
- LineItem model: [line_item.dart](shared/order_repository/lib/src/models/line_item.dart)
- MenuItem model: [menu_item.dart](shared/very_yummy_coffee_models/lib/src/models/menu_item.dart)
- Server state: [server_state.dart](api/lib/src/server_state.dart) — `updateMenuItemAvailability` (line ~100), `addItemToOrder` (line ~134)
- MenuRepository: [menu_repository.dart](shared/menu_repository/lib/src/menu_repository.dart)
- OrderRepository: [order_repository.dart](shared/order_repository/lib/src/order_repository.dart) — `addItemToCurrentOrder` (line ~71)
- POS router: [app_router.dart](applications/pos_app/lib/app/app_router/app_router.dart)
- POS top bar: [pos_top_bar.dart](applications/pos_app/lib/ordering/view/widgets/pos_top_bar.dart)
- POS menu item card: [menu_item_card.dart](applications/pos_app/lib/menu/view/widgets/menu_item_card.dart) — already has OOS treatment
- Mobile menu items: [menu_items_view.dart](applications/mobile_app/lib/menu_items/view/menu_items_view.dart) — no OOS treatment
- Mobile cart: [cart_bloc.dart](applications/mobile_app/lib/cart/bloc/cart_bloc.dart) — no menu dependency
- Kiosk item detail: [item_detail_view.dart](applications/kiosk_app/lib/item_detail/view/item_detail_view.dart) — has OOS treatment
- Menu board state: [menu_display_state.dart](applications/menu_board_app/lib/menu_display/bloc/menu_display_state.dart) — filters OOS items
- UI colors: [app_colors.dart](shared/very_yummy_coffee_ui/lib/src/colors/app_colors.dart) — `unavailableOverlay` token
- Shared widgets: [widgets.dart](shared/very_yummy_coffee_ui/lib/src/widgets/widgets.dart)

### Related Work

- Design: `design.pen` (check for stock management / OOS frames)
- Branch: `feat/stock-management-oos-display`
