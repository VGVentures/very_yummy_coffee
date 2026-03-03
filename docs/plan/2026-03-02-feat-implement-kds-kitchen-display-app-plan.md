# ✨ feat: implement kds kitchen display app

**Date:** 2026-03-02
**Branch:** `feat/kds-kitchen-display-app`
**Type:** Enhancement — new application

---

## Background & Motivation

Very Yummy Coffee currently has a customer-facing mobile app for ordering but no kitchen-side tooling. Baristas must verbally communicate or rely on ad-hoc printed tickets. This feature introduces a dedicated Kitchen Display System (`kds_app`) — a Flutter application for a mounted landscape screen that shows all active orders in real time and lets kitchen staff advance each order through its lifecycle with a single tap.

The KDS connects to the same WebSocket RPC layer the mobile app uses, subscribing to the `orders` topic and issuing new kitchen actions (`startOrder`, `markOrderReady`). It is the first application to introduce two new order statuses (`inProgress`, `ready` — note: `ready` already exists in the enum but is not currently reachable via any action), which requires coordinated changes across the shared model, server, repository, and mobile app.

---

## Acceptance Criteria

- [ ] `OrderStatus` enum includes `inProgress` (additive; `ready` already exists)
- [ ] `Order` model includes a nullable `submittedAt: DateTime?` field
- [ ] Server handles `startOrder` action: `submitted → inProgress`, sets `submittedAt` on `submitOrder`
- [ ] `OrderRepository` exposes `startOrder(orderId)`, `markOrderReady(orderId)`, `markOrderCompleted(orderId)`, `cancelOrder(orderId)` (all orderId-based; existing current-order methods untouched)
- [ ] `applications/kds_app` compiles and passes `flutter analyze` with `very_good_analysis`
- [ ] KDS app shows connecting screen while WS is disconnected; navigates to `/kds` when connected
- [ ] `/kds` displays three columns: NEW (submitted), IN PROGRESS (inProgress), READY (ready)
- [ ] Tapping "Start →" moves an order from NEW → IN PROGRESS
- [ ] Tapping "Mark Ready →" moves an order from IN PROGRESS → READY
- [ ] Tapping "Complete ✓" removes an order from READY
- [ ] Tapping "Cancel" on any column removes the order
- [ ] NEW cards show relative age from `submittedAt` ("just now", "X min ago")
- [ ] IN PROGRESS cards show a live MM:SS counting-up timer from `submittedAt`
- [ ] Orders are sorted oldest-first (ascending `submittedAt`) within each column
- [ ] Columns are vertically scrollable when order count exceeds screen height
- [ ] `HomeBloc` in `mobile_app` correctly treats `inProgress` orders as active
- [ ] All new public methods/Blocs/repositories have tests
- [ ] `.github/update_github_actions.sh` is run after pubspec changes; updated workflows committed

---

## Technical Considerations

### Critical Gaps Identified (User-Flow Analysis)

The following gaps were identified during pre-planning analysis and **must** be addressed as part of this feature:

1. **`startOrder` missing from server** — `server_state.dart` has no `case 'startOrder':`. Sending the action currently silently no-ops. The server must be updated before any KDS testing is possible.

2. **`inProgress` missing from `OrderStatus`** — The enum has `pending, submitted, ready, completed, cancelled`. `inProgress` must be added and `dart_mappable` code regenerated (`dart run build_runner build` in `shared/order_repository`).

3. **`submittedAt` missing from `Order` model** — Required for age display (NEW column) and elapsed timer (IN PROGRESS). The `submitOrder` server handler must stamp `DateTime.now().toUtc().toIso8601String()` when processing.

4. **WS re-subscription after reconnect** — `WsRpcClient.subscribe` sends the subscribe message exactly once. After a WebSocket reconnect, the server has no record of this client's subscriptions and will not push updates. The KDS (and mobile app) will go stale after every network drop. The fix must be implemented in `WsRpcClient` (re-subscribe all tracked topics when connection is re-established).

5. **No status transition guards on server** — All action handlers in `server_state.dart` set status unconditionally. A race condition between two KDS clients could push an order backward. Add guards (e.g., only apply `startOrder` if current status is `submitted`).

6. **`HomeBloc` filter must be verified; `home_view.dart` exhaustive switches will compile-fail** — After adding `inProgress` to the enum, two exhaustive `switch` expressions in `mobile_app/lib/home/view/home_view.dart` (`_StatusPill` and `OrderStepTracker.activeStep`) will become non-exhaustive, causing a **compile error**. Both must be updated in Phase 1 alongside the enum change. The `HomeBloc` filter logic is already correct by exclusion (only excludes `completed` and `cancelled`), but the docstring must be updated.

### Design Decisions Inherited from Brainstorm

- **Fire-and-forget actions**: Send WS action → let server broadcast state change back. No optimistic local updates. Disable action button between tap and next `ordersStream` emission to prevent double-taps.
- **orderId-based repository methods**: Additive; existing current-order methods stay unchanged.
- **Timer source is `submittedAt`**: Both NEW age display and IN PROGRESS elapsed timer derive from this single server-set timestamp.
- **Cancel button on every card**: Left-aligned, muted style — no confirmation dialog for v1 (deferred).
- **Order notes deferred**: `LineItem.options` field is present in the model but not displayed.
- **No menu repository**: KDS only needs `order_repository` and `connection_repository`.
- **Green for READY**: Use `const Color(0xFF22C55E)` directly (brighter design green, distinct from `context.colors.success` which is `0xFF5A9E6F`).

### Age Display Thresholds (NEW column)

| Elapsed | Display |
|---|---|
| < 60s | "just now" |
| 1–59 min | "X min ago" |
| 60+ min | "Xh Xm ago" |

### Column Sort Order

All columns sorted ascending by `submittedAt` (oldest/most urgent first). `submittedAt` is the only available timestamp across all statuses. For the READY column, a `readyAt` field is deferred to a future iteration.

---

## Model Changes

### ERD

```mermaid
erDiagram
    Order {
        String id PK
        List~LineItem~ items
        OrderStatus status
        DateTime submittedAt "nullable, set by server on submitOrder"
    }

    OrderStatus {
        pending
        submitted
        inProgress "NEW - add this"
        ready
        completed
        cancelled
    }

    LineItem {
        String id PK
        String name
        int price
        String options
        int quantity
    }

    Order ||--o{ LineItem : contains
    Order }o--|| OrderStatus : has
```

---

## Implementation Plan

### Phase 1: Shared Layer Updates

**No app-level changes in this phase. All changes are additive.**

#### 1.1 Extend `OrderStatus` enum

**File:** `shared/order_repository/lib/src/models/order.dart`

```dart
@MappableEnum()
enum OrderStatus {
  pending,
  submitted,
  inProgress, // NEW
  ready,
  completed,
  cancelled,
}
```

After editing, regenerate mappers:
```sh
cd shared/order_repository
dart run build_runner build --delete-conflicting-outputs
```

#### 1.2 Add `submittedAt` to `Order` model

**File:** `shared/order_repository/lib/src/models/order.dart`

```dart
@MappableClass()
class Order with OrderMappable {
  const Order({
    required this.id,
    required this.items,
    required this.status,
    this.submittedAt,  // NEW - nullable, set server-side
  });

  final String id;
  final List<LineItem> items;
  final OrderStatus status;
  final DateTime? submittedAt;  // NEW
  // ... computed getters unchanged
}
```

Regenerate mappers (same command as 1.1).

#### 1.3 Add KDS repository methods to `OrderRepository`

**File:** `shared/order_repository/lib/src/order_repository.dart`

Add four new methods (all orderId-based, no changes to existing methods). Note: the KDS method is named `markOrderCompleted` to avoid ambiguity with the existing `completeCurrentOrder()` which clears the tracked customer order ID.

```dart
/// Transitions order from submitted → inProgress on the server.
void startOrder(String orderId) {
  _wsRpcClient.sendAction('startOrder', {'orderId': orderId});
}

/// Transitions order from inProgress → ready on the server.
void markOrderReady(String orderId) {
  _wsRpcClient.sendAction('markOrderReady', {'orderId': orderId});
}

/// Transitions a specific order to completed (KDS-facing, orderId-based).
///
/// Distinct from [completeCurrentOrder] which clears the customer's tracked
/// order ID. Use this method when completing orders by explicit ID (e.g., KDS).
void markOrderCompleted(String orderId) {
  _wsRpcClient.sendAction('completeOrder', {'orderId': orderId});
}

/// Cancels a specific order by orderId.
void cancelOrder(String orderId) {
  _wsRpcClient.sendAction('cancelOrder', {'orderId': orderId});
}
```

**Tests:** `shared/order_repository/test/src/order_repository_test.dart` — add test groups for each new method following the existing `submitCurrentOrder` test pattern (verify `sendAction` is called with correct action name and payload).

#### 1.4 Fix WS re-subscription after reconnect

**File:** `shared/api_client/lib/src/ws_rpc_client.dart`

The `WsRpcClient` must re-send all active topic subscriptions when the underlying WebSocket reconnects. Investigate the `web_socket_client` `Reconnected` state event and re-send `{"type": "subscribe", "topic": X}` for each key in `_controllers` (the map of active topics).

> **Note:** This is a cross-cutting fix that benefits both `mobile_app` and `kds_app`. Coordinate with any in-flight mobile_app work.

**Tests (new file):** `shared/api_client/test/src/ws_rpc_client_test.dart`

This is a non-trivial change to a foundational shared class and **must** be covered by tests:
- `subscribe` sends the subscribe message to the server on first call
- `subscribe` returns the same stream for the same topic without sending a duplicate subscribe message (idempotency)
- On `Reconnected` state, all active topic subscriptions are re-sent to the server
- `sendAction` dispatches the action with the correct JSON format
- `close` tears down all stream controllers and the connection

#### 1.5 Server updates

**File:** `api/lib/src/server_state.dart`

1. **Add `startOrder` handler:**

```dart
case 'startOrder':
  final orderId = payload['orderId'] as String;
  final order = _orders[orderId];
  if (order != null && order['status'] == 'submitted') {
    _orders[orderId] = <String, dynamic>{...order, 'status': 'inProgress'};
    broadcast('orders', snapshotForTopic('orders'));
    broadcast('order:$orderId', _orders[orderId]!);
  }
```

2. **Stamp `submittedAt` in `submitOrder` handler:**

```dart
case 'submitOrder':
  final orderId = payload['orderId'] as String;
  final order = _orders[orderId];
  if (order != null) {
    _orders[orderId] = <String, dynamic>{
      ...order,
      'status': 'submitted',
      'submittedAt': DateTime.now().toUtc().toIso8601String(),  // NEW
    };
    broadcast('orders', snapshotForTopic('orders'));
    broadcast('order:$orderId', _orders[orderId]!);
  }
```

3. **Retrofit status transition guards to ALL action handlers** (including existing `markOrderReady`, `completeOrder`, `cancelOrder` that currently have no guards):

| Handler | Guard condition | Change? |
|---|---|---|
| `startOrder` | `order['status'] == 'submitted'` | NEW handler |
| `markOrderReady` | `order['status'] == 'inProgress'` | ADD guard to existing handler |
| `completeOrder` | `order['status'] == 'ready'` | ADD guard to existing handler |
| `cancelOrder` | `order['status'] != 'completed' && order['status'] != 'cancelled'` | ADD guard to existing handler |

> Guards are being **retrofitted** to all existing handlers, not only the new `startOrder` handler. Without this, the other handlers remain vulnerable to race conditions.

#### 1.6 Fix `home_view.dart` exhaustive switches + update docstring

**File:** `applications/mobile_app/lib/home/view/home_view.dart`

Adding `inProgress` to `OrderStatus` will cause **two compile errors** in exhaustive switch expressions. Both must be fixed:

1. `OrderStepTracker.activeStep` switch — add `OrderStatus.inProgress => 2` (or the appropriate step index for "order being prepared")
2. `_StatusPill` switch — add `OrderStatus.inProgress => (context.l10n.inProgress, context.colors.primary)` (reuse primary orange, same as cart/checkout in-progress states)

**File:** `applications/mobile_app/lib/home/bloc/home_state.dart`

Update the comment on `HomeState.orders`:

```dart
/// Active orders only (pending, submitted, inProgress, ready).
/// Completed and cancelled are filtered out by [HomeBloc].
final List<Order> orders;
```

No filter logic change needed — the existing filter already correctly includes `inProgress` by exclusion.

---

### Phase 2: Create `applications/kds_app`

The KDS app mirrors `mobile_app` structure exactly. All file paths are relative to `applications/kds_app/`.

#### 2.1 Package scaffold

**`pubspec.yaml`:**
```yaml
name: very_yummy_coffee_kds_app
description: "Very Yummy Coffee Kitchen Display App"
publish_to: "none"
version: 0.1.0

environment:
  sdk: ^3.11.0
  flutter: ^3.41.2

dependencies:
  api_client:
    path: ../../shared/api_client
  bloc: ^9.0.0
  connection_repository:
    path: ../../shared/connection_repository
  dart_mappable: ^4.6.1
  flutter:
    sdk: flutter
  flutter_bloc: ^9.1.1
  flutter_localizations:
    sdk: flutter
  go_router: ^14.6.2
  intl: ^0.20.2
  order_repository:
    path: ../../shared/order_repository
  very_yummy_coffee_ui:
    path: ../../shared/very_yummy_coffee_ui

dev_dependencies:
  bloc_lint: ^0.3.6
  bloc_test: ^10.0.0
  build_runner: ^2.11.1
  dart_mappable_builder: ^4.6.4
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  nested: ^1.0.0
  very_good_analysis: ^10.0.0

flutter:
  generate: true
  uses-material-design: true
```

**`analysis_options.yaml`:** (same as mobile_app — `very_good_analysis` + `bloc_lint`)

**After creating `pubspec.yaml`, run:**
```sh
.github/update_github_actions.sh
```

#### 2.2 Localization

**`lib/l10n/arb/app_en.arb`:** KDS-specific strings

```json
{
  "@@locale": "en",
  "appTitle": "Very Yummy Coffee — Kitchen Display",
  "connecting": "Connecting to kitchen…",
  "columnNew": "NEW",
  "columnInProgress": "IN PROGRESS",
  "columnReady": "READY",
  "actionStart": "Start →",
  "actionMarkReady": "Mark Ready →",
  "actionComplete": "Complete ✓",
  "actionCancel": "Cancel",
  "ageJustNow": "just now",
  "ageMinutesAgo": "{minutes} min ago",
  "ageHoursMinutesAgo": "{hours}h {minutes}m ago",
  "orderQueue": "{count} in queue"
}
```

**`lib/l10n/l10n.dart`:** re-export `AppLocalizations` (same pattern as mobile_app).

#### 2.3 App layer

**`lib/app/bloc/app_event.dart`, `app_state.dart`, `app_bloc.dart`:**

Copy the AppBloc pattern from `mobile_app` exactly. Same events (`AppStarted`), same state (`AppStatus.connected / disconnected`), same connection repository subscription.

**`lib/app/app_router/go_router_refresh_stream.dart`:** Copy from `mobile_app` (utility class, no changes needed). Note: this creates two identical copies in the monorepo. Extracting to a shared package is deferred — if you fix a bug here, apply it to both copies.

**`lib/app/app_router/app_router.dart`:**

```dart
class AppRouter {
  AppRouter({...}) {
    _goRouter = GoRouter(
      initialLocation: ConnectingPage.routeName,
      refreshListenable: GoRouterRefreshStream(appBloc.stream),
      redirect: (context, state) {
        final status = context.read<AppBloc>().state.status;
        final onConnecting = state.uri.path == ConnectingPage.routeName;
        if (status != AppStatus.connected && !onConnecting) {
          return ConnectingPage.routeName;
        }
        if (status == AppStatus.connected && onConnecting) {
          return KdsPage.routeName;  // '/kds'
        }
        return null;
      },
      routes: [
        GoRoute(path: ConnectingPage.routeName, ...),
        GoRoute(path: KdsPage.routeName, ...),
      ],
    );
  }
}
```

**`lib/app/view/connecting_page.dart`:**

Matches `mobile_app`'s `ConnectingPage`. The KDS top bar shows a disconnected indicator once the KDS screen is mounted, but a full-screen spinner is appropriate for the initial connection.

**`lib/app/view/app.dart`:** Copy `App` + `_AppView` pattern from `mobile_app`. MaterialApp.router with `CoffeeTheme.light`, localization delegates, no `MenuRepository` in the `MultiRepositoryProvider`.

**`lib/main.dart`:**
```dart
void main() {
  final apiClient = ApiClient(host: 'localhost', port: 8080, secure: false, apiKey: '');
  final wsRpcClient = WsRpcClient.fromApiClient(apiClient);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => ConnectionRepository(wsRpcClient: wsRpcClient)),
        RepositoryProvider(create: (_) => OrderRepository(wsRpcClient: wsRpcClient)),
      ],
      child: const App(),
    ),
  );
}
```

#### 2.4 KDS Feature — Bloc

**`lib/kds/bloc/kds_event.dart`:**

> Follow the existing codebase pattern: every concrete event subclass must include its generated `with XxxMappable` mixin. Without this, `dart_mappable` code generation produces incomplete/broken mapper code.

```dart
part of 'kds_bloc.dart';

@MappableClass()
sealed class KdsEvent with KdsEventMappable {
  const KdsEvent();
}

@MappableClass()
class KdsSubscriptionRequested extends KdsEvent
    with KdsSubscriptionRequestedMappable {
  const KdsSubscriptionRequested();
}

@MappableClass()
class KdsOrderStarted extends KdsEvent with KdsOrderStartedMappable {
  const KdsOrderStarted(this.orderId);
  final String orderId;
}

@MappableClass()
class KdsOrderMarkedReady extends KdsEvent with KdsOrderMarkedReadyMappable {
  const KdsOrderMarkedReady(this.orderId);
  final String orderId;
}

@MappableClass()
class KdsOrderCompleted extends KdsEvent with KdsOrderCompletedMappable {
  const KdsOrderCompleted(this.orderId);
  final String orderId;
}

@MappableClass()
class KdsOrderCancelled extends KdsEvent with KdsOrderCancelledMappable {
  const KdsOrderCancelled(this.orderId);
  final String orderId;
}
```

**`lib/kds/bloc/kds_state.dart`:**

```dart
@MappableEnum()
enum KdsStatus { initial, loading, success, failure }

@MappableClass()
class KdsState with KdsStateMappable {
  const KdsState({
    this.status = KdsStatus.initial,
    this.newOrders = const [],
    this.inProgressOrders = const [],
    this.readyOrders = const [],
  });

  final KdsStatus status;
  final List<Order> newOrders;       // status == submitted
  final List<Order> inProgressOrders; // status == inProgress
  final List<Order> readyOrders;     // status == ready
}
```

**`lib/kds/bloc/kds_bloc.dart`:**

```dart
class KdsBloc extends Bloc<KdsEvent, KdsState> {
  KdsBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(const KdsState()) {
    on<KdsSubscriptionRequested>(_onSubscriptionRequested);
    on<KdsOrderStarted>(_onOrderStarted);
    on<KdsOrderMarkedReady>(_onOrderMarkedReady);
    on<KdsOrderCompleted>(_onOrderCompleted);
    on<KdsOrderCancelled>(_onOrderCancelled);
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    KdsSubscriptionRequested event,
    Emitter<KdsState> emit,
  ) async {
    emit(state.copyWith(status: KdsStatus.loading));
    await emit.forEach(
      _orderRepository.ordersStream,
      onData: (orders) {
        // Sort each group oldest-first by submittedAt
        final sorted = List<Order>.from(orders.orders)
          ..sort((a, b) {
            final aTime = a.submittedAt;
            final bTime = b.submittedAt;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return aTime.compareTo(bTime);
          });

        return state.copyWith(
          status: KdsStatus.success,
          newOrders: sorted.where((o) => o.status == OrderStatus.submitted).toList(),
          inProgressOrders: sorted.where((o) => o.status == OrderStatus.inProgress).toList(),
          readyOrders: sorted.where((o) => o.status == OrderStatus.ready).toList(),
        );
      },
      onError: (_, _) => state.copyWith(status: KdsStatus.failure),
    );
  }

  // Fire-and-forget handlers — send the WS action and let the server
  // broadcast the state change back through ordersStream. Use block bodies
  // (consistent with all other Bloc handlers in this codebase).
  void _onOrderStarted(KdsOrderStarted event, Emitter<KdsState> emit) {
    _orderRepository.startOrder(event.orderId);
  }

  void _onOrderMarkedReady(KdsOrderMarkedReady event, Emitter<KdsState> emit) {
    _orderRepository.markOrderReady(event.orderId);
  }

  void _onOrderCompleted(KdsOrderCompleted event, Emitter<KdsState> emit) {
    _orderRepository.markOrderCompleted(event.orderId);
  }

  void _onOrderCancelled(KdsOrderCancelled event, Emitter<KdsState> emit) {
    _orderRepository.cancelOrder(event.orderId);
  }
}
```

Run `dart run build_runner build --delete-conflicting-outputs` after creating bloc files.

#### 2.5 KDS Feature — View

**`lib/kds/view/kds_page.dart`:**

```dart
class KdsPage extends StatelessWidget {
  const KdsPage({super.key});
  static const routeName = '/kds';

  factory KdsPage.pageBuilder(BuildContext _, GoRouterState _) =>
      const KdsPage(key: Key('kds_page'));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KdsBloc(
        orderRepository: context.read<OrderRepository>(),
      )..add(const KdsSubscriptionRequested()),
      child: const KdsView(),
    );
  }
}
```

**`lib/kds/view/kds_view.dart`:**

Define the READY column color as a file-level constant in `kds_view.dart`:
```dart
// Distinct from context.colors.success (0xFF5A9E6F) — matches the design spec exactly.
const _kdsReadyGreen = Color(0xFF22C55E);
```

Full-screen landscape scaffold:
```
Scaffold
  └── Column
        ├── _KdsTopBar                          // dark bg, connection dot, title, queue pill, clock
        └── Expanded
              └── Row
                    ├── _KdsColumn(             // NEW — gold accent
                    │     orders: newOrders,
                    │     columnColor: context.colors.accentGold,
                    │     label: l10n.columnNew,
                    │     actionLabel: l10n.actionStart,
                    │     onAction: (id) => bloc.add(KdsOrderStarted(id)),
                    │     onCancel: (id) => bloc.add(KdsOrderCancelled(id)),
                    │   )
                    ├── _KdsColumn(             // IN PROGRESS — primary orange
                    │     orders: inProgressOrders,
                    │     columnColor: context.colors.primary,
                    │     label: l10n.columnInProgress,
                    │     actionLabel: l10n.actionMarkReady,
                    │     onAction: (id) => bloc.add(KdsOrderMarkedReady(id)),
                    │     onCancel: (id) => bloc.add(KdsOrderCancelled(id)),
                    │   )
                    └── _KdsColumn(             // READY — design green (file-level const _kdsReadyGreen)
                          orders: readyOrders,
                          columnColor: _kdsReadyGreen,
                          label: l10n.columnReady,
                          actionLabel: l10n.actionComplete,
                          onAction: (id) => bloc.add(KdsOrderCompleted(id)),
                          onCancel: (id) => bloc.add(KdsOrderCancelled(id)),
                        )
```

**`lib/kds/view/widgets/kds_top_bar.dart`** (private to KDS feature, not a shared UI widget):

`_KdsTopBar` must be a `StatefulWidget`. The `Stream.periodic` clock must be created **once** in `initState` (not in `build()` — creating it in `build()` would spawn a new timer on every parent rebuild and leak subscriptions):

```dart
class _KdsTopBar extends StatefulWidget { ... }

class _KdsTopBarState extends State<_KdsTopBar> {
  late final Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();
    _clockStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    ).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    // ...
    // Clock: StreamBuilder<DateTime>(stream: _clockStream, ...)
    // Queue pill: BlocBuilder<KdsBloc, KdsState>(...)
    // Connection dot: BlocBuilder<AppBloc, AppState>(...)
  }
}
```

**`lib/kds/view/widgets/kds_column.dart`** (private to KDS feature):
- Column header with accent color
- `ListView` (vertically scrollable)
- Each item: `_KdsOrderCard`

**`lib/kds/view/widgets/kds_order_card.dart`** (private to KDS feature):
- Card header: `order.orderNumber` + elapsed/age widget (see order number helper below)
- Items list: `qty× ItemName` (one row per LineItem; `options` field deferred)
- Footer: Cancel button (muted, left) + primary action button (right, color matches column accent)
- Primary action button: for v1, `KdsOrderCard` is a `StatelessWidget` — trust the server round-trip. Buttons are **not** disabled between tap and server response.
- **Elapsed/age widget**: see `kds_elapsed_widget.dart` below

**`lib/kds/view/widgets/kds_elapsed_widget.dart`** — **must be a `StatefulWidget`** with explicit `Timer` lifecycle:

```dart
class KdsElapsedWidget extends StatefulWidget {
  const KdsElapsedWidget({
    required this.submittedAt,
    required this.isLiveTimer,  // true = IN PROGRESS MM:SS, false = age display
    super.key,
  });

  final DateTime? submittedAt;
  final bool isLiveTimer;

  @override
  State<KdsElapsedWidget> createState() => _KdsElapsedWidgetState();
}

class _KdsElapsedWidgetState extends State<KdsElapsedWidget> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateElapsed());
  }

  void _updateElapsed() {
    final submitted = widget.submittedAt;
    if (submitted == null) return;
    setState(() => _elapsed = DateTime.now().difference(submitted));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If isLiveTimer: format as MM:SS
    // Else: format as age ("just now", "X min ago", "Xh Xm ago")
    // If submittedAt == null: show '—'
  }
}
```

**Order number helper** — add as an extension on `Order` in `shared/order_repository/lib/src/models/order.dart` (avoids duplication with `mobile_app/lib/home/view/home_view.dart` which already computes this inline):

```dart
extension OrderDisplayHelpers on Order {
  /// Returns the order number for display: last 4 UUID hex chars, e.g. '#A7F2'.
  String get orderNumber => '#${id.substring(id.length - 4).toUpperCase()}';
}
```

Update `mobile_app/lib/home/view/home_view.dart` to use `order.orderNumber` instead of the inline substring expression.

#### 2.6 Tests

**`test/helpers/pump_app.dart`:**

```dart
// Provides theme, localization, routing, AppBloc, and OrderRepository for widget tests.
// Same pattern as mobile_app, but without MenuRepository.
extension AppTester on WidgetTester {
  Future<void> pumpApp(
    Widget widgetUnderTest, {
    AppBloc? appBloc,
    GoRouter? goRouter,
    OrderRepository? orderRepository,
  }) async { ... }
}
```

**Bloc tests:**
- `test/kds/bloc/kds_bloc_test.dart` — use `blocTest`, mock `OrderRepository`
  - `KdsSubscriptionRequested` → emits `loading` then `success` with filtered state
  - `KdsSubscriptionRequested` → **sort order** — provide orders out of chronological order in the stream; assert `newOrders[0].submittedAt` is earlier than `newOrders[1].submittedAt`
  - `KdsSubscriptionRequested` — `inProgress` orders appear in `inProgressOrders`, not `newOrders`
  - `KdsOrderStarted` → calls `orderRepository.startOrder` with correct `orderId`
  - `KdsOrderMarkedReady` → calls `orderRepository.markOrderReady` with correct `orderId`
  - `KdsOrderCompleted` → calls `orderRepository.markOrderCompleted` with correct `orderId`
  - `KdsOrderCancelled` → calls `orderRepository.cancelOrder` with correct `orderId`
  - `onError` from stream → emits `KdsStatus.failure`
- `test/app/bloc/app_bloc_test.dart` — copy from `mobile_app`

**Also add to `mobile_app` tests:**
- `test/home/bloc/home_bloc_test.dart` — add a test asserting that an `inProgress` order is included in the emitted `orders` list (verifies the enum extension doesn't break the filter)

**Widget tests:**
- `test/kds/view/kds_page_test.dart` — verifies `BlocProvider` is wired, `KdsSubscriptionRequested` dispatched
- `test/kds/view/kds_view_test.dart` — verifies three columns render with correct labels; verifies tap on action button dispatches correct event

---

### Phase 3: GitHub Actions

After creating `applications/kds_app/pubspec.yaml` and any shared package dependency changes:

```sh
.github/update_github_actions.sh
```

Commit the resulting changes alongside the pubspec changes. Failing to do so will cause the `Verify Github Actions` CI check to fail.

---

## Files Changed

### Modified Files

| File | Change |
|---|---|
| `shared/order_repository/lib/src/models/order.dart` | Add `inProgress` to `OrderStatus`; add `submittedAt: DateTime?` to `Order`; add `orderNumber` extension |
| `shared/order_repository/lib/src/models/order.mapper.dart` | Regenerated by build_runner |
| `shared/order_repository/lib/src/order_repository.dart` | Add `startOrder`, `markOrderReady`, `markOrderCompleted(orderId)`, `cancelOrder(orderId)` |
| `shared/order_repository/test/src/order_repository_test.dart` | Tests for 4 new methods |
| `shared/api_client/lib/src/ws_rpc_client.dart` | Re-subscribe on reconnect |
| `shared/api_client/test/src/ws_rpc_client_test.dart` | New — tests for subscribe, reconnect re-subscribe, sendAction, close |
| `api/lib/src/server_state.dart` | Add `startOrder` handler; stamp `submittedAt` in `submitOrder`; retrofit status guards to all handlers |
| `applications/mobile_app/lib/home/bloc/home_state.dart` | Update docstring only |
| `applications/mobile_app/lib/home/view/home_view.dart` | Add `inProgress` to both exhaustive switches; use `order.orderNumber` extension |
| `applications/mobile_app/test/home/bloc/home_bloc_test.dart` | Add test for `inProgress` orders appearing in active list |
| `.github/workflows/*.yml` | Regenerated by update script |

### New Files (all under `applications/kds_app/`)

```
applications/kds_app/
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart                          (barrel)
│   │   ├── bloc/
│   │   │   ├── app_bloc.dart
│   │   │   ├── app_bloc.mapper.dart           (generated)
│   │   │   ├── app_event.dart
│   │   │   └── app_state.dart
│   │   ├── app_router/
│   │   │   ├── app_router.dart
│   │   │   └── go_router_refresh_stream.dart
│   │   └── view/
│   │       ├── app.dart
│   │       ├── connecting_page.dart
│   │       └── view.dart                     (barrel)
│   ├── l10n/
│   │   ├── l10n.dart
│   │   └── arb/
│   │       ├── app_en.arb
│   │       ├── app_localizations.dart         (generated)
│   │       └── app_localizations_en.dart      (generated)
│   └── kds/
│       ├── kds.dart                           (barrel)
│       ├── bloc/
│       │   ├── kds_bloc.dart
│       │   ├── kds_bloc.mapper.dart           (generated)
│       │   ├── kds_event.dart
│       │   └── kds_state.dart
│       └── view/
│           ├── kds_page.dart
│           ├── kds_view.dart
│           ├── view.dart                      (barrel)
│           └── widgets/
│               ├── kds_top_bar.dart
│               ├── kds_column.dart
│               ├── kds_order_card.dart
│               └── kds_elapsed_widget.dart
└── test/
    ├── helpers/
    │   ├── go_router.dart
    │   ├── helpers.dart                       (barrel)
    │   ├── l10n.dart
    │   └── pump_app.dart
    ├── app/
    │   └── bloc/
    │       └── app_bloc_test.dart
    └── kds/
        ├── bloc/
        │   └── kds_bloc_test.dart
        └── view/
            ├── kds_page_test.dart
            └── kds_view_test.dart
```

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| `dart_mappable` build_runner fails after enum/model change | Medium | Run `--delete-conflicting-outputs`; check for analyzer errors before proceeding |
| WS re-subscribe fix breaks existing mobile_app behavior | Medium | Write tests for `WsRpcClient` re-subscription; verify mobile_app integration |
| Two KDS clients race on same order | Low | Server status guards prevent backward transitions |
| `submittedAt` null for orders existing before deploy | Certain (server restart) | Null-safe display: show "—" or skip elapsed time when `submittedAt == null` |
| `HomeBloc` mobile_app shows `inProgress` differently | Low | Filter already correct by exclusion; only docstring update needed |
| Timer widget leak if card is disposed while timer running | Medium | Use `StatefulWidget.dispose()` to cancel `Timer.periodic` |

---

## Dependencies & Sequencing

```
Phase 1.1 (enum)
  → Phase 1.2 (model)
    → Phase 1.3 (repo methods)    ← can run parallel with 1.4, 1.5
    → Phase 1.4 (WS reconnect)
    → Phase 1.5 (server)
      → Phase 2 (kds_app)         ← depends on all Phase 1 complete
        → Phase 3 (CI workflows)  ← must run after pubspec.yaml created
```

---

## Future Considerations

- **`readyAt` timestamp**: Add when READY column needs to sort by time-became-ready rather than submission time
- **Audio alerts**: Play a sound when a new order arrives in the NEW column
- **Cancel confirmation**: Two-tap pattern (especially important for touch screens with gloves)
- **Order notes (`LineItem.options`)**: Display modifier text beneath each line item
- **Order number collision resolution**: Switch to sequential numeric IDs if UUID last-4 collisions become a real problem
- **KDS authentication**: API key or session token to distinguish KDS clients from customer clients on the server
- **Landscape lock**: Use `SystemChrome.setPreferredOrientations` to lock the KDS to landscape mode

---

## AI Notes

**User-flow analysis** identified: `startOrder` missing from server, no status guards on any handler, WS reconnect subscription bug, and `submittedAt` entirely absent from the model.

**Technical review** identified: `home_view.dart` exhaustive switches are a compile-blocker (not mentioned in brainstorm), `completeOrder` naming collision fixed to `markOrderCompleted`, `WsRpcClient` reconnect fix needs its own test file, server guard retrofitting applies to all existing handlers, `_KdsTopBar` clock must be `StatefulWidget.initState`-initialized, `_ElapsedWidget` timer disposal must be explicit, and `orderNumber` display logic should live on `Order` (not duplicated across both apps).

**Technical debt to track:**
- `GoRouterRefreshStream` exists in both apps — extract to shared package in a follow-up
- `@MappableClass` on Bloc events generates unused mapper code across the entire project — remove in a follow-up refactor
