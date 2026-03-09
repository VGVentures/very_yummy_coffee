---
title: "feat: add live order status board to menu board app"
type: feat
date: 2026-03-09
---

## feat: add live order status board to menu board app

## Overview

Add a real-time order status panel to the menu board app that shows customers whether their order is being prepared or ready for pickup. The panel replaces the right featured panel (320px) in the existing layout, subscribes to the `orders` WebSocket topic, and filters to `inProgress` and `ready` statuses. When no orders exist, the original featured panel is shown as a fallback.

Related: [#33](https://github.com/VGVentures/very-yummy-coffee/issues/33), [#31](https://github.com/VGVentures/very-yummy-coffee/issues/31), [#32](https://github.com/VGVentures/very-yummy-coffee/issues/32)

Brainstorm: `docs/ideate/2026-03-09-order-status-board-brainstorm-doc.md`

## Problem Statement / Motivation

Customers currently have no way to see their order status in the shop without checking their phone or asking a barista. A wall-mounted menu board is the natural place to display this — it's already visible to everyone in the shop and runs a dedicated Flutter app.

## Proposed Solution

### Phase 1: Dependency wiring and shared widget

Wire `order_repository` into the menu board app and create the shared `OrderStatusCard` widget.

**1.1 — Add `order_repository` dependency**

- [ ] Add `order_repository` path dependency to `applications/menu_board_app/pubspec.yaml`
  ```yaml
  order_repository:
    path: ../../shared/order_repository
  ```
- [ ] In `applications/menu_board_app/lib/main.dart`, create `OrderRepository(wsRpcClient: wsRpcClient)` and add it to the `MultiRepositoryProvider` (same pattern as `MenuRepository`)
- [ ] Run `.github/update_github_actions.sh` and commit the generated workflow changes

**1.2 — Create `OrderStatusCard` shared widget**

New file: `shared/very_yummy_coffee_ui/lib/src/widgets/order_status_card.dart`

- [ ] Create `OrderStatusCard` widget accepting primitive params:
  - `displayName` (`String`) — customer name or order number
  - `statusBackgroundColor` (`Color`) — e.g., `context.colors.statusWarningBackground`
  - `statusForegroundColor` (`Color`) — e.g., `context.colors.statusWarningForeground`
  - `statusLabel` (`String`) — e.g., "Preparing" or "Ready"
- [ ] Use `context.typography.label` for the display name (20px, bold — readable from distance)
- [ ] Use `context.typography.caption` for the status label
- [ ] Use `context.spacing` and `context.radius` tokens — no raw literals
- [ ] Export from `shared/very_yummy_coffee_ui/lib/src/widgets/widgets.dart`
- [ ] Add widget tests in `shared/very_yummy_coffee_ui/test/src/widgets/order_status_card_test.dart`:
  - Renders `displayName` text
  - Renders `statusLabel` text
  - Applies `statusBackgroundColor` to the status chip/container
  - Applies `statusForegroundColor` to the status label text
  - Handles long `displayName` with text overflow (ellipsis)
  - Uses design tokens for spacing and radius (no raw literals)

### Phase 2: OrderStatusBloc

New feature folder: `applications/menu_board_app/lib/order_status/`

**2.1 — Create bloc files**

Follow the `KdsBloc` pattern at `applications/kds_app/lib/kds/bloc/kds_bloc.dart:28-65`.

- [ ] `order_status/bloc/order_status_bloc.dart` — read-only bloc, single event handler
- [ ] `order_status/bloc/order_status_event.dart`:
  - `OrderStatusSubscriptionRequested` — triggers `emit.forEach` on `ordersStream`
- [ ] `order_status/bloc/order_status_state.dart`:
  ```
  @MappableEnum()
  OrderStatusStatus { initial, loading, success, failure }

  @MappableClass()
  OrderStatusState:
    status: OrderStatusStatus
    inProgressOrders: List<Order>  // filtered + sorted (full list)
    readyOrders: List<Order>       // filtered + sorted (full list)
  ```
  Annotate with `@MappableClass()` / `@MappableEnum()` and add `part 'order_status_state.mapper.dart'`. The `dart_mappable`-generated equality deduplicates emissions automatically (no manual `distinct` needed). Run `build_runner` after creating the files.
- [ ] `order_status/order_status.dart` — barrel file

> **Note:** The bloc stores the full filtered/sorted lists. The view handles capping (`.take(maxVisible)`) and computing the "+X more" count. This keeps display logic in the view and simplifies the bloc state.

**2.2 — Bloc implementation details**

- [ ] Subscribe to `ordersStream` via `emit.forEach`
- [ ] Sort all orders by `submittedAt` (oldest first, nulls pushed to end — same as KDS pattern at `kds_bloc.dart:36-44`)
- [ ] Filter: `inProgress` orders for "Preparing", `ready` orders for "Ready for Pickup"
- [ ] Store the full filtered/sorted lists in state (capping is done in the view)
- [ ] Handle `onError: (_, _) => state.copyWith(status: OrderStatusStatus.failure)`

**2.3 — Bloc tests**

- [ ] `test/order_status/bloc/order_status_bloc_test.dart` using `blocTest` + `mocktail`
- [ ] Test: emits loading then success on subscription
- [ ] Test: filters to only `inProgress` and `ready` (excludes `pending`, `submitted`, `completed`, `cancelled`)
- [ ] Test: sorts by `submittedAt` oldest first
- [ ] Test: full filtered lists stored in state (no capping at bloc level)
- [ ] Test: handles null `submittedAt` (pushed to end)
- [ ] Test: handles empty orders list (both lists empty)
- [ ] Test: emits failure on stream error

### Phase 3: Order status panel UI

New files in `applications/menu_board_app/lib/order_status/view/`.

**3.1 — `OrderStatusPanel` widget**

File: `order_status/view/order_status_panel.dart`

- [ ] Reads `OrderStatusBloc` from context (provided by `MenuDisplayPage` — see Phase 4.2)
- [ ] `BlocBuilder<OrderStatusBloc, OrderStatusState>` renders the panel content
- [ ] Panel background uses a subtle card-like container (320px width, full height)
- [ ] Two sections stacked vertically:
  - "Preparing" section header + list of `OrderStatusCard` widgets (warning tokens)
  - "Ready for Pickup" section header + list of `OrderStatusCard` widgets (success tokens)
- [ ] Section headers use `context.typography.subtitle` with appropriate foreground colors
- [ ] Each section is hidden when its order list is empty
- [ ] Cap visible orders per section using `.take(maxVisiblePerSection)` (constant, start with **5**)
- [ ] "+X more" indicator below each section when `list.length > maxVisiblePerSection`
- [ ] Import `package:order_repository/order_repository.dart` directly for `OrderDisplayHelpers.orderNumber` extension (extension methods require direct import — re-exports don't suffice)
- [ ] Map `order.customerName ?? order.orderNumber` for `displayName`
- [ ] Handle long customer names with `Text` overflow `ellipsis`

**3.2 — l10n strings**

File: `applications/menu_board_app/lib/l10n/arb/app_en.arb`

- [ ] Add keys:
  - `orderStatusPreparing` → "Preparing"
  - `orderStatusReady` → "Ready for Pickup"
  - `orderStatusMoreCount` → "+{count} more" (parameterized with ICU placeholders):
    ```json
    "orderStatusMoreCount": "+{count} more",
    "@orderStatusMoreCount": {
      "placeholders": {
        "count": { "type": "int" }
      }
    }
    ```
- [ ] Run `flutter gen-l10n`

### Phase 4: Layout integration

**4.1 — Update `MenuDisplayView`**

File: `applications/menu_board_app/lib/menu_display/view/menu_display_view.dart`

- [ ] Replace the right `FeaturedItemPanel` (lines 72-79) with a new extracted widget (e.g., `_RightPanel`) that contains its own `BlocBuilder<OrderStatusBloc, OrderStatusState>` — this isolates the order status rebuild scope from the `MenuDisplayBloc` builder, preventing unnecessary rebuilds
- [ ] Inside `_RightPanel`, use `AnimatedSwitcher` to swap between:
  - `OrderStatusPanel` (when `state.inProgressOrders.isNotEmpty || state.readyOrders.isNotEmpty`)
  - `FeaturedItemPanel` (fallback when both lists are empty)
- [ ] Ensure `OrderStatusPanel` and `FeaturedItemPanel` have different runtime types (they do) so `AnimatedSwitcher` detects the change — or use `ValueKey` if needed
- [ ] This is the **single animation point** — no additional `AnimatedSwitcher` inside `OrderStatusPanel`

**4.2 — Update `MenuDisplayPage`**

File: `applications/menu_board_app/lib/menu_display/view/menu_display_page.dart`

- [ ] Add `BlocProvider<OrderStatusBloc>` to a `MultiBlocProvider` alongside the existing `MenuDisplayBloc` provider
- [ ] Inject `OrderRepository` via `context.read<OrderRepository>()`
- [ ] Fire `OrderStatusSubscriptionRequested` on creation

**4.3 — Update test helper**

File: `applications/menu_board_app/test/helpers/pump_app.dart`

- [ ] Add optional `OrderRepository? orderRepository` parameter
- [ ] Add `RepositoryProvider<OrderRepository>` to the `MultiRepositoryProvider`
- [ ] Create `_MockOrderRepository` class

### Phase 5: Widget tests

**5.1 — `OrderStatusPanel` widget tests**

File: `test/order_status/view/order_status_panel_test.dart`

- [ ] Test: renders "Preparing" section with in-progress orders
- [ ] Test: renders "Ready for Pickup" section with ready orders
- [ ] Test: hides "Preparing" section when no in-progress orders
- [ ] Test: hides "Ready for Pickup" section when no ready orders
- [ ] Test: shows customer name when available
- [ ] Test: shows order number when customer name is null
- [ ] Test: shows "+X more" indicator when orders exceed cap
- [ ] Test: renders loading state

**5.2 — `MenuDisplayView` integration tests**

File: `test/menu_display/view/menu_display_view_test.dart` (update existing)

- [ ] Test: shows `OrderStatusPanel` when orders exist
- [ ] Test: shows right `FeaturedItemPanel` when no orders exist (fallback)
- [ ] Test: transitions between `OrderStatusPanel` and `FeaturedItemPanel` when orders appear/disappear (pump through `AnimatedSwitcher` with `pumpAndSettle`)
- [ ] Verify existing menu display tests still pass

**5.3 — `MenuDisplayPage` tests**

File: `test/menu_display/view/menu_display_page_test.dart` (update existing)

- [ ] Verify `OrderStatusBloc` is provided

## Technical Considerations

**Architecture**: The `OrderStatusBloc` is scoped to `MenuDisplayPage` (its feature level), not at the app level. It's read-only — no action handlers needed. The bloc is destroyed when the router navigates away to `/connecting` on disconnect and recreated fresh on reconnect.

**WebSocket reconnection**: Verified safe. `WsRpcClient` automatically re-subscribes all topics on `Reconnected` (`ws_rpc_client.dart:105-111`). The `BehaviorSubject` in `OrderRepository` persists across reconnections and replays the last value to new subscribers.

**Shared UI constraint**: `OrderStatusCard` in `very_yummy_coffee_ui` accepts only primitive params (`String`, `Color`). The mapping from `Order` domain type to display values happens in the menu board app's view layer.

**Performance**: The `ordersStream` emits the full order list on every change. Filtering and sorting happen in the bloc's `onData` callback. For a coffee shop's order volume (tens of orders, not thousands), this is negligible.

## Acceptance Criteria

- [ ] Menu board subscribes to `ordersStream` and filters to `inProgress` and `ready`
- [ ] "Preparing" section displays all `inProgress` orders with customer name or order number
- [ ] "Ready for Pickup" section displays all `ready` orders with customer name or order number
- [ ] `pending`, `submitted`, `completed`, and `cancelled` orders are not shown
- [ ] Layout does not obscure the existing menu content (right panel swap only)
- [ ] Orders update in real time via WebSocket without manual refresh
- [ ] `AnimatedSwitcher` transitions when orders appear or disappear
- [ ] Empty sections are hidden; when both empty, right `FeaturedItemPanel` shown as fallback
- [ ] Visible count capped per section with "+X more" indicator
- [ ] Uses design tokens throughout (`context.colors`, `context.spacing`, `context.radius`, `context.typography`)
- [ ] `OrderStatusCard` shared widget in `very_yummy_coffee_ui` with tests
- [ ] `OrderStatusBloc` unit tests cover filtering, sorting, capping, overflow, empty state, and error
- [ ] Widget tests cover panel rendering, section visibility, name/number display, overflow indicator
- [ ] All existing menu board tests remain green
- [ ] GitHub Actions workflows regenerated after pubspec change

## Success Metrics

- Customers can see their order status on the wall display without asking a barista
- Order transitions appear within 1 second of the status change on KDS/POS
- No regressions to existing menu display functionality

## Dependencies & Risks

| Dependency | Status | Risk |
|---|---|---|
| `order_repository` package | Exists, well-tested | None — just needs wiring |
| `ordersStream` WebSocket topic | Already used by KDS/POS | None |
| Design tokens (`statusWarning*`, `statusSuccess*`) | Already defined in `AppColors` | None |
| `OrderDisplayHelpers.orderNumber` extension | Exists in `order_repository` | Must import directly in view files |

**Risks:**
- Visible cap of 5 per section may need adjustment after seeing it on actual hardware — this is easy to change (single constant)
- Long customer names need `Text` overflow handling (`ellipsis`) — standard Flutter pattern

## References & Research

### Internal References

- KDS bloc pattern: `applications/kds_app/lib/kds/bloc/kds_bloc.dart:28-65`
- Order model: `shared/order_repository/lib/src/models/order.dart`
- Menu display layout: `applications/menu_board_app/lib/menu_display/view/menu_display_view.dart:45-81`
- WsRpcClient reconnection: `shared/api_client/lib/src/ws_rpc_client.dart:105-111`
- Design tokens: `shared/very_yummy_coffee_ui/lib/src/colors/app_colors.dart`
- Shared widgets barrel: `shared/very_yummy_coffee_ui/lib/src/widgets/widgets.dart`
- Test helper: `applications/menu_board_app/test/helpers/pump_app.dart`

### Related Issues

- #33 — this feature
- #31 — pending orders (defines the full status flow)
- #32 — customer names (primary identifier on the status board)
