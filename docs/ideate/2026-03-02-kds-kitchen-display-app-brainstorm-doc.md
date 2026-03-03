---
date: 2026-03-02
topic: kds-kitchen-display-app
---

# KDS — Kitchen Display App

## What We're Building

A new Flutter application (`applications/kds_app`) that serves as a kitchen-facing display for the Very Yummy Coffee ordering system. Staff use it on a single mounted screen (landscape, desktop-class) to see all active orders grouped into three columns — **NEW**, **IN PROGRESS**, and **READY** — and advance each order through its lifecycle with a single tap.

The KDS is a real-time, read-write view into the same order state the mobile app creates. It connects via the existing WebSocket RPC layer, subscribes to the `orders` topic, and issues new kitchen-specific actions (`startOrder`, `markOrderReady`, `completeOrder`) directly through `OrderRepository`.

---

## Design Reference

From `design.pen` → "KDS — Kitchen Display" (1920×1080):

### Top Bar (`kdsBar`)
- Dark background (`$--foreground`)
- Green "connected" dot, app title "Very Yummy Coffee — Kitchen Display"
- Flex spacer, then a queue pill showing total order count + list-ordered icon
- Separator, then a clock showing current time (HH:MM AM/PM)

### Body (`kdsBody`) — 3-column layout
| Column | Accent color | Header label | Card border | Action button |
|--------|-------------|--------------|-------------|---------------|
| NEW | `$--accent-gold` (#E7BD5A) | "NEW" | `$--border` (grey) | "Start →" (gold bg) |
| IN PROGRESS | `$--primary` (#C96B45) | "IN PROGRESS" | primary orange | "Mark Ready →" (primary bg) |
| READY | `#22C55E` (green) | "READY" | green | "Complete ✓" (green bg) |

### Order Card anatomy
1. **Header**: Order `#XXXX` (derived from UUID last 4 hex chars) + elapsed time since submission (right-aligned)
   - NEW cards show relative age ("just now", "1 min ago")
   - IN PROGRESS cards show a counting-up MM:SS timer
2. **Items list**: `qty× ItemName` with optional modifiers line (one row per line item)
3. **Footer**: flex spacer, Cancel button (muted, left-aligned), primary action button (right-aligned)
   - Cancel button added to all columns (design updated in `design.pen`)

---

## Order Status Lifecycle Extension

The current `OrderStatus` enum (`pending`, `submitted`, `completed`, `cancelled`) maps as:
- `pending` → customer building cart (not shown in KDS)
- `submitted` → maps to **NEW** column
- `completed` → order done (not shown, or briefly visible in READY before completion)
- `cancelled` → not shown

Two new statuses are needed:
- `inProgress` → **IN PROGRESS** column (kitchen tapped "Start")
- `ready` → **READY** column (kitchen tapped "Mark Ready")

A `submittedAt` timestamp (DateTime) is also added to `Order`, set server-side when `submitOrder` is handled. Both the NEW age display and the IN PROGRESS elapsed timer derive from this single field.

### New WS actions needed
| Action | Payload | Transition |
|--------|---------|------------|
| `startOrder` | `{"orderId": "<uuid>"}` | `submitted` → `inProgress` |
| `markOrderReady` | `{"orderId": "<uuid>"}` | `inProgress` → `ready` |
| `completeOrder` | already exists | `ready` → `completed` |
| `cancelOrder` | already exists | any → `cancelled` |

These require changes to:
1. `order_repository/lib/src/models/order.dart` — add `inProgress`, `ready` to `OrderStatus`; add `submittedAt` field
2. `api/lib/src/server_state.dart` — handle `startOrder`, `markOrderReady`; set `submittedAt` on `submitOrder`
3. `shared/order_repository` — add `startOrder(orderId)`, `markOrderReady(orderId)`, `completeOrder(orderId)`, `cancelOrder(orderId)` methods (orderId-based, not current-order-based)

---

## Order Number Display

Order numbers are derived from the UUID: take the last 4 characters and format as `#XXXX` (uppercase hex). Example: UUID `...a7f2` → `#A7F2`. No model changes needed; implemented as a display helper.

---

## App Structure: `kds_app`

Mirrors `mobile_app` conventions exactly:

```
applications/kds_app/
├── lib/
│   ├── main.dart                  # ApiClient + WsRpcClient + repos + runApp
│   ├── app/
│   │   ├── bloc/                  # AppBloc (connection state, same pattern)
│   │   ├── app_router/            # GoRouter — single route /kds
│   │   └── view/                  # App, _AppView (MaterialApp.router)
│   ├── l10n/
│   │   └── arb/app_en.arb         # KDS-specific strings
│   └── kds/                       # Feature module
│       ├── bloc/
│       │   ├── kds_bloc.dart      # KdsBloc
│       │   ├── kds_event.dart     # KdsSubscriptionRequested, KdsOrderStarted, etc.
│       │   └── kds_state.dart     # KdsState with newOrders, inProgressOrders, readyOrders
│       └── view/
│           ├── kds_page.dart      # BlocProvider wrapper
│           └── kds_view.dart      # Full-screen 3-column layout
├── test/
│   └── helpers/
│       └── pump_app.dart          # pumpApp helper (same pattern)
├── analysis_options.yaml          # very_good_analysis + bloc_lint
└── pubspec.yaml                   # deps: flutter_bloc, go_router, very_yummy_coffee_ui, etc.
```

### Bloc design

**KdsBloc** with:
- `KdsSubscriptionRequested` event → `emit.forEach(ordersStream)`, filters to active statuses only
- `KdsOrderStarted(orderId)` event → calls `orderRepository.startOrder(orderId)` (fire-and-forget; server broadcasts update)
- `KdsOrderMarkedReady(orderId)` event → calls `orderRepository.markOrderReady(orderId)` (fire-and-forget)
- `KdsOrderCompleted(orderId)` event → calls `orderRepository.completeOrder(orderId)` (fire-and-forget)
- `KdsOrderCancelled(orderId)` event → calls `orderRepository.cancelOrder(orderId)` (fire-and-forget)

Action events are fire-and-forget: send the WS action and let the server broadcast the state change back through `ordersStream`. No local optimistic updates.

**KdsState**:
```dart
class KdsState {
  List<Order> newOrders;       // status == submitted
  List<Order> inProgressOrders; // status == inProgress
  List<Order> readyOrders;     // status == ready
  KdsStatus status;            // initial | loading | success | failure
}
```

The view renders three columns from state — no API calls in widgets.

### Shared `very_yummy_coffee_ui` usage
- `CoffeeTheme.light` for MaterialApp
- `BaseButton` for action buttons where it fits (or custom inline buttons styled to match the design)
- Design tokens (`context.colors`, `context.typography`, `context.spacing`) throughout

---

## Key Decisions

- **Order numbers from UUID**: Last 4 hex chars of UUID, formatted `#XXXX`. No model changes.
- **New statuses in `OrderStatus`**: Add `inProgress` and `ready`. Requires coordinated changes to models, server, and repository.
- **Single page, GoRouter anyway**: Follow the same app-router pattern with a `/kds` route even though there's only one screen — consistent with project conventions.
- **orderId-based repository methods**: Add `startOrder`, `markOrderReady`, `completeOrder(orderId)`, `cancelOrder(orderId)` — all take an explicit `orderId`. These are additive; existing current-order methods stay unchanged.
- **Timer source is `submittedAt`**: Add `submittedAt` (nullable DateTime) to `Order` model. Server sets it when `submitOrder` is handled. Both NEW age display and IN PROGRESS elapsed timer derive from this field.
- **Action events are fire-and-forget**: Send WS action, server broadcasts update back via `ordersStream`. No optimistic local state changes.
- **Cancelled orders hidden**: Not displayed in any KDS column.
- **Cancel button on every card**: Added to `design.pen` — muted style, left-aligned in footer.
- **Connecting screen**: Same `AppBloc` + GoRouter redirect pattern as `mobile_app`. Show a connecting page when WS is disconnected.
- **Order notes deferred**: The card note field is ignored for now and will be added in a later iteration.
- **No menu repository**: KDS only needs `order_repository` and `connection_repository`.

---

