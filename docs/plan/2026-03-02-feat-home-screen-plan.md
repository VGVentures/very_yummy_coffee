# feat: implement home screen with active order tracking

## Background & Motivation

The mobile app currently lands users on the Menu Groups screen after connecting. There is no way to see in-progress orders after leaving the checkout confirmation page. This feature introduces a `/home` route as the post-connection landing page, showing real-time active order cards with a step-progress tracker and a "Start New Order" CTA. It also formalises the `ready` order status on both the backend and client, and extracts the `OrderStepTracker` widget into the shared UI package so it can be reused between Home and OrderComplete screens.

## Acceptance Criteria

- [ ] After WebSocket connection is established, the app navigates to `/home` instead of `/menu`
- [ ] Home screen shows a time-based greeting ("Good morning/afternoon/evening") in the header
- [ ] Active orders (status: `pending`, `submitted`, `ready`) are displayed as cards with order number (`#XXXX`), item count + total, status pill, and 4-step progress tracker
- [ ] Completed and cancelled orders are filtered out by `HomeBloc`; they never appear on the screen
- [ ] An empty state is shown when there are no active orders
- [ ] "Start New Order" CTA is always visible at the bottom and navigates to `context.go('/menu')`
- [ ] The order list updates in real-time as the server broadcasts order status changes
- [ ] `OrderStatus.ready` is added to the enum and `markOrderReady` WS action is handled in `server_state.dart`
- [ ] `OrderStepTracker` is extracted to `shared/very_yummy_coffee_ui` and used by both Home and `OrderCompleteView`
- [ ] Widget tests exist for `HomeView` using the `pumpApp` helper
- [ ] All existing `OrderCompleteView` tests continue to pass

## Technical Approach

### Codebase has strong patterns — no external research needed

All required patterns exist in the codebase:
- **Bloc pattern**: `OrderCompleteBloc` ([order_complete_bloc.dart](applications/mobile_app/lib/order_complete/bloc/order_complete_bloc.dart)) — `emit.forEach` over a repository stream
- **Filtering in onData**: [cart_bloc.dart](applications/mobile_app/lib/cart/bloc/cart_bloc.dart) — maps a stream with a filter inline
- **Router redirect**: [app_router.dart](applications/mobile_app/lib/app/app_router/app_router.dart:28-30) — `status == AppStatus.connected && onConnecting` check
- **Shared widget export**: [widgets.dart](shared/very_yummy_coffee_ui/lib/src/widgets/widgets.dart)
- **Server action pattern**: [server_state.dart](api/lib/src/server_state.dart:147-154) — `case 'submitOrder':` block

### Key Resolved Decisions (from brainstorm)

| Decision | Resolution |
|---|---|
| Order ID format | `order.id.substring(order.id.length - 4).toUpperCase()` → `#XXXX` |
| Tap behavior on order cards | No tap navigation — inert cards (no GestureDetector) |
| Greeting computation | In the view, `DateTime.now().hour` |
| Greeting boundaries | `hour < 12` → morning, `12 ≤ hour < 18` → afternoon, `≥ 18` → evening |
| Active statuses | `pending`, `submitted`, `ready` |
| `HomeStatus` values | `loading`, `success`, `failure` (no separate `initial`) |
| Back to Menu button (OrderComplete) | Keep as `context.go('/menu')` for this ticket — update in future |

### Step index mapping for `OrderStepTracker`

The existing `_StatusTracker` in `OrderCompleteView` maps `completed` to index 2 (only 3 states existed). After adding `ready`, the mapping becomes:

| Status | Step index | Label |
|---|---|---|
| `pending` | 0 | Placed |
| `submitted` | 1 | Brewing |
| `ready` | 2 | Ready |
| `completed` | 3 | Picked Up |
| `cancelled` | -1 | (no step) |

> ⚠️ This changes `completed`'s visual from step 2 → step 3 on the existing `OrderCompleteView`. Regression tests must be added.

## Implementation Plan

### Phase 1 — Backend + Models

**1.1 Add `ready` to `OrderStatus` in `very_yummy_coffee_models`**

File: [shared/order_repository/lib/src/models/order.dart](shared/order_repository/lib/src/models/order.dart)

```dart
@MappableEnum()
enum OrderStatus {
  pending,
  submitted,
  ready,       // ← new
  completed,
  cancelled,
}
```

Then regenerate mappers:

```bash
dart run build_runner build --delete-conflicting-outputs
```

in `shared/order_repository`.

**1.2 Add `markOrderReady` action in `server_state.dart`**

File: [api/lib/src/server_state.dart](api/lib/src/server_state.dart)

Add a new case inside `handleAction`:

```dart
case 'markOrderReady':
  final orderId = payload['orderId'] as String;
  final order = _orders[orderId];
  if (order != null) {
    _orders[orderId] = <String, dynamic>{...order, 'status': 'ready'};
    broadcast('orders', snapshotForTopic('orders'));
    broadcast('order:$orderId', _orders[orderId]!);
  }
```

> Note: No mobile UI trigger for this ticket — barista screen is future work. The action is added so the enum is stable.

---

### Phase 2 — Shared UI: Extract `OrderStepTracker`

**2.1 Create `OrderStepTracker` in `very_yummy_coffee_ui`**

New file: `shared/very_yummy_coffee_ui/lib/src/widgets/order_step_tracker.dart`

Extract `_StatusTracker`, `_StepNode` from `order_complete_view.dart` into a public `OrderStepTracker` widget. The widget takes `OrderStatus status` and `List<String> labels` (or hard-codes 4 labels with l10n injection from the caller). The `_activeStepIndex` switch must be updated with the new 5-value mapping.

```dart
class OrderStepTracker extends StatelessWidget {
  const OrderStepTracker({
    required this.status,
    required this.labels,
    super.key,
  });

  final OrderStatus status;
  final List<String> labels; // always length 4

  int get _activeStepIndex {
    switch (status) {
      case OrderStatus.pending:    return 0;
      case OrderStatus.submitted:  return 1;
      case OrderStatus.ready:      return 2;
      case OrderStatus.completed:  return 3;
      case OrderStatus.cancelled:  return -1;
    }
  }
  // ... render logic (extracted from _StatusTracker)
}
```

**2.2 Export from `widgets.dart`**

File: [shared/very_yummy_coffee_ui/lib/src/widgets/widgets.dart](shared/very_yummy_coffee_ui/lib/src/widgets/widgets.dart)

```dart
export 'order_step_tracker.dart';
```

**2.3 Update `OrderCompleteView` to use `OrderStepTracker`**

File: [applications/mobile_app/lib/order_complete/view/order_complete_view.dart](applications/mobile_app/lib/order_complete/view/order_complete_view.dart)

Replace the `_StatusTracker(status: order.status)` call with:

```dart
OrderStepTracker(
  status: order.status,
  labels: [
    context.l10n.orderCompleteStep1,
    context.l10n.orderCompleteStep2,
    context.l10n.orderCompleteStep3,
    context.l10n.orderCompleteStep4,
  ],
)
```

Delete the private `_StatusTracker` and `_StepNode` classes from `order_complete_view.dart`.

---

### Phase 3 — Mobile App: `HomeBloc`

**3.1 Create `lib/home/` feature directory**

```
lib/home/
  bloc/
    home_bloc.dart
    home_event.dart
    home_state.dart
    home_bloc.mapper.dart   ← generated
  view/
    home_page.dart
    home_view.dart
    view.dart
  home.dart
```

**3.2 `home_event.dart`**

```dart
part of 'home_bloc.dart';

@MappableClass()
sealed class HomeEvent with HomeEventMappable {
  const HomeEvent();
}

@MappableClass()
class HomeSubscriptionRequested extends HomeEvent
    with HomeSubscriptionRequestedMappable {
  const HomeSubscriptionRequested();
}
```

**3.3 `home_state.dart`**

```dart
part of 'home_bloc.dart';

@MappableEnum()
enum HomeStatus { loading, success, failure }

@MappableClass()
class HomeState with HomeStateMappable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.orders = const [],
  });

  final HomeStatus status;
  final List<Order> orders; // filtered: active orders only
}
```

**3.4 `home_bloc.dart`**

```dart
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const HomeState()) {
    on<HomeSubscriptionRequested>(_onSubscriptionRequested);
  }

  final OrderRepository _orderRepository;

  Future<void> _onSubscriptionRequested(
    HomeSubscriptionRequested event,
    Emitter<HomeState> emit,
  ) async {
    await emit.forEach(
      _orderRepository.ordersStream,
      onData: (orders) {
        final active = orders.orders
            .where((o) =>
                o.status != OrderStatus.completed &&
                o.status != OrderStatus.cancelled)
            .toList();
        return state.copyWith(orders: active, status: HomeStatus.success);
      },
      onError: (_, _) => state.copyWith(status: HomeStatus.failure),
    );
  }
}
```

> Regenerate mappers: `dart run build_runner build --delete-conflicting-outputs` in `applications/mobile_app`.

---

### Phase 4 — Mobile App: `HomePage` and `HomeView`

**4.1 `home_page.dart`**

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  factory HomePage.pageBuilder(BuildContext _, GoRouterState state) {
    return const HomePage(key: Key('home_page'));
  }

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(
        orderRepository: context.read<OrderRepository>(),
      )..add(const HomeSubscriptionRequested()),
      child: const HomeView(),
    );
  }
}
```

**4.2 `home_view.dart` — structure**

```dart
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _HomeHeader(greeting: _greeting()),
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state.status == HomeStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == HomeStatus.failure) {
                  return _ErrorState();
                }
                if (state.orders.isEmpty) {
                  return _EmptyState();
                }
                return _OrderList(orders: state.orders);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _StartNewOrderBar(),
    );
  }
}
```

Key sub-widgets:
- `_HomeHeader` — colored bar, coffee icon, greeting text
- `_OrderCard` — shows order `#XXXX`, item count + total, status pill, `OrderStepTracker`
- `_EmptyState` — icon + copy + optional secondary CTA
- `_ErrorState` — error message (matching `context.l10n.errorSomethingWentWrong`)
- `_StartNewOrderBar` — `BaseButton` calling `context.go('/menu')`

---

### Phase 5 — Router Update

**5.1 Add `/home` route and update redirect**

File: [applications/mobile_app/lib/app/app_router/app_router.dart](applications/mobile_app/lib/app/app_router/app_router.dart)

Change the connected redirect:

```dart
// Before:
if (status == AppStatus.connected && onConnecting) {
  return MenuGroupsPage.routeName;
}

// After:
if (status == AppStatus.connected && onConnecting) {
  return HomePage.routeName;
}
```

Add the `/home` GoRoute as a **top-level sibling** of `/menu` (not nested):

```dart
GoRoute(
  name: HomePage.routeName,
  path: HomePage.routeName,
  pageBuilder: (BuildContext context, GoRouterState state) =>
      NoTransitionPage(
        name: HomePage.routeName,
        child: HomePage.pageBuilder(context, state),
      ),
),
```

---

### Phase 6 — l10n Strings

File: `applications/mobile_app/lib/l10n/arb/app_en.arb`

Add keys:
```arb
"homeGreetingMorning": "Good morning",
"homeGreetingAfternoon": "Good afternoon",
"homeGreetingEvening": "Good evening",
"homeYourOrdersLabel": "Your Orders",
"homeActiveOrdersCount": "{count} active",
"homeStartNewOrderButton": "Start New Order",
"homeEmptyStateTitle": "No active orders",
"homeEmptyStateBody": "Tap below to start your first order",
"homeOrderNumber": "#{orderNumber}",
"homeOrderItemCount": "{count} {count, plural, =1{item} other{items}}",
```

---

### Phase 7 — Widget Tests

**7.1 `home_bloc_test.dart`**

File: `applications/mobile_app/test/home/bloc/home_bloc_test.dart`

- `HomeSubscriptionRequested` emits `success` with filtered active orders
- `HomeSubscriptionRequested` filters out `completed` and `cancelled` orders
- Stream error emits `failure` state

**7.2 `home_view_test.dart`**

File: `applications/mobile_app/test/home/view/home_view_test.dart`

- Renders `CircularProgressIndicator` in `loading` state
- Renders empty state when `orders` is empty
- Renders order cards when `orders` is non-empty
- "Start New Order" button calls `context.go('/menu')`

Use `pumpApp` from [test/helpers/pump_app.dart](applications/mobile_app/test/helpers/pump_app.dart).

**7.3 `order_complete_view_test.dart` regression**

Ensure `OrderCompleteView` renders correctly for `OrderStatus.completed` (step 3 now, was step 2). Add a regression test if one does not exist.

---

## Dependencies and Risks

| Risk | Mitigation |
|---|---|
| `dart_mappable` mapper regeneration must run in both `order_repository` and `mobile_app` | Run `build_runner` in each package separately after adding `ready` |
| `completed` step index changes from 2 → 3, affecting OrderComplete visual | Add regression widget test for `OrderCompleteView` with `completed` status before extracting |
| `BehaviorSubject.seeded(Orders(orders: []))` causes a flicker to empty state before WS snapshot | `HomeStatus.loading` is the initial state; only transition to `success` after first `onData` — the seeded empty value will trigger `success` with `orders: []` which renders empty state briefly; acceptable since it resolves on next WS push within ~100ms |
| `OrderRepository.currentOrderId` overwritten if user starts a new order while another pending order exists | Accepted as known gap for this ticket — document in code comment |
| `markOrderReady` action is untested from mobile side until barista screen | Backend action is added now so model is stable; can be integration-tested later |

## Files To Create

```
applications/mobile_app/lib/home/bloc/home_bloc.dart
applications/mobile_app/lib/home/bloc/home_event.dart
applications/mobile_app/lib/home/bloc/home_state.dart
applications/mobile_app/lib/home/view/home_page.dart
applications/mobile_app/lib/home/view/home_view.dart
applications/mobile_app/lib/home/view/view.dart
applications/mobile_app/lib/home/home.dart
applications/mobile_app/test/home/bloc/home_bloc_test.dart
applications/mobile_app/test/home/view/home_view_test.dart
shared/very_yummy_coffee_ui/lib/src/widgets/order_step_tracker.dart
```

## Files To Modify

```
shared/order_repository/lib/src/models/order.dart           ← add ready to OrderStatus
shared/order_repository/lib/src/models/order.mapper.dart    ← regenerated
api/lib/src/server_state.dart                               ← add markOrderReady action
shared/very_yummy_coffee_ui/lib/src/widgets/widgets.dart    ← export OrderStepTracker
applications/mobile_app/lib/order_complete/view/order_complete_view.dart  ← use OrderStepTracker
applications/mobile_app/lib/app/app_router/app_router.dart  ← add /home route + update redirect
applications/mobile_app/lib/l10n/arb/app_en.arb             ← add home screen strings
```
