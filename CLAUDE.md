# Project Context

<!-- ============================================================
     CUSTOMIZATION SECTION - Edit freely, preserved during updates
     ============================================================ -->

## About This Project

Very Yummy Coffee is a Flutter/Dart monorepo for a coffee ordering app. It targets mobile (iOS/Android) via `applications/mobile_app`. A Dart Frog backend serves menu and order data with real-time sync via WebSocket RPC.

## Key Dependencies

| Package | Purpose |
|---|---|
| `dart_frog` | Backend API framework |
| `dart_frog_web_socket` | WebSocket support for the RPC endpoint |
| `api_client` (shared) | HTTP + WebSocket client; exports `ApiClient`, `LiveConnection`, `WsRpcClient` |
| `menu_repository` (shared) | Menu domain; lazy WS subscription with ref-counting |
| `order_repository` (shared) | Order domain; WS-synced mutations |
| `very_yummy_coffee_models` (shared) | Shared models: `MenuGroup`, `MenuItem` (with `groupId` + `available`) |
| `rxdart` | `BehaviorSubject` for replay streams, `doOnCancel` for ref-counting |
| `dart_mappable` | JSON serialization for all models |

## Architecture Notes

### WebSocket RPC Layer

Real-time sync uses a single WebSocket endpoint at `GET /api/rpc` (`routes/api/rpc.dart`). Clients connect once per app via `WsRpcClient` (`shared/api_client/lib/src/ws_rpc_client.dart`), which multiplexes multiple topic subscriptions over one connection.

**Client → server messages:**
```json
{"type": "subscribe",   "topic": "menu"}
{"type": "subscribe",   "topic": "orders"}
{"type": "subscribe",   "topic": "order:<id>"}
{"type": "unsubscribe", "topic": "menu"}
{"type": "action", "action": "updateMenuItemAvailability", "payload": {"itemId": "101", "available": false}}
{"type": "action", "action": "createOrder",         "payload": {"id": "<uuid>"}}
{"type": "action", "action": "addItemToOrder",      "payload": {"orderId": "<uuid>", "lineItemId": "<uuid>", "itemName": "...", "itemPrice": 550}}
{"type": "action", "action": "removeItemFromOrder", "payload": {"orderId": "<uuid>", "lineItemId": "<uuid>"}}
{"type": "action", "action": "completeOrder",       "payload": {"orderId": "<uuid>"}}
{"type": "action", "action": "updateNameOnOrder",  "payload": {"orderId": "<uuid>", "customerName": "Marcus"}}
{"type": "action", "action": "cancelOrder",         "payload": {"orderId": "<uuid>"}}
```

**Server → client messages:**
```json
{"type": "update", "topic": "menu",        "payload": {"groups": [...], "items": [...]}}
{"type": "update", "topic": "orders",      "payload": {"orders": [...]}}
{"type": "update", "topic": "order:<id>",  "payload": {...order...}}
```

On `subscribe`, the server immediately sends the current snapshot, then sends updates whenever state changes due to any client's action.

### Server State

`api/lib/src/server_state.dart` — in-memory singleton (`serverState`) holding the current menu (loaded from `fixtures/menu.json`) and all orders. Manages topic subscriptions as `Map<String, Set<StreamSink>>` and broadcasts to relevant subscribers after each action.

### WsRpcClient

`shared/api_client/lib/src/ws_rpc_client.dart` — calling `subscribe(topic)` twice returns the same broadcast stream (no duplicate WS messages). Created via `WsRpcClient.fromApiClient(apiClient)`.

### Repository Subscription Pattern

**MenuRepository** (`shared/menu_repository/lib/src/menu_repository.dart`): `Rx.defer` + `BehaviorSubject` + `doOnCancel` for ref-counted lazy subscriptions. First subscriber triggers HTTP fetch (initial state) + WS subscribe. Last subscriber cancels the WS subscription. `getMenuGroups()` and `getMenuItems(groupId)` share one WS subscription and one HTTP initial fetch.

**OrderRepository** (`shared/order_repository/lib/src/order_repository.dart`): Subscribes to `orders` WS topic on first `ordersStream` access and stays open. All mutations send WS actions — no local state mutation. Call `dispose()` when done.

### State Management

Prefer `Bloc` over `Cubit`. Always use `Bloc` with explicit event classes.

### Navigation

Always use `context.go('/path')` with hardcoded path strings. Never use `context.pushNamed`, `context.goNamed`, `context.push`, or `extra`.

### Shared UI Package (`very_yummy_coffee_ui`)

Before building any custom widget, check `shared/very_yummy_coffee_ui/lib/src/widgets/` for an existing shared component. Current shared widgets include:

- **`AppTopBar`** — shared dark top bar with connection dot, title, live clock, and optional `middleWidgets`/`actionWidgets` slots. Used by both KDS and POS apps.
- **`BaseButton`** — primary/secondary/cancel variants, supports `isLoading`. Use for all full-width and inline action buttons.
- **`CustomBackButton`** — standard back arrow for colored headers. Use instead of raw `GestureDetector + Icon(arrow_back)`.

When implementing a new widget that is used in more than one screen, or that is a general-purpose UI primitive (buttons, cards, inputs, chips, etc.), place it in `shared/very_yummy_coffee_ui/lib/src/widgets/` and export it from the package. Do not duplicate UI patterns across feature views.

### UI Coding Standards

**Colors — always use design tokens:**
- Never use `Color(0xFFxxxxxx)` raw hex literals in view code.
- Never use `Colors.green`, `Colors.white`, `Colors.black`, etc. from Material.
- Always use `context.colors.xxx` from `AppColors`. Add new named tokens to `AppColors` + `CoffeeTheme` if a color is needed that doesn't exist yet.

**EdgeInsets — never use `EdgeInsets.fromLTRB`:**
- Use `EdgeInsets.symmetric` when horizontal and vertical values match.
- Use `EdgeInsets.only` when values differ on individual sides.
- `EdgeInsets.fromLTRB` is never acceptable.

**Spacing and radius — use design tokens:**
- Use `context.spacing.xxx` (xxs=2, xs=4, sm=8, md=12, lg=16, xl=20, xxl=24, huge=32) for padding, gaps, and margins.
- Use `context.radius.xxx` (small=12, medium=14, large=18, card=20, pill=9999) for `BorderRadius`.
- Avoid raw numeric literals for layout values when a spacing/radius token matches.

**Typography — use design tokens:**
- Never construct `TextStyle(fontFamily: 'IBM Plex Sans', fontSize: ...)` directly in view code.
- Always use `context.typography.xxx.copyWith(...)` (pageTitle, subtitle, label, body, muted, caption, etc.).
- Add new named styles to `AppTypography` + `CoffeeTheme` if the scale is missing a needed size.

**Bloc scoping:**
- Provide each Bloc at its feature level, not at a parent page that merely hosts multiple features.
- E.g., `MenuBloc` is provided by `MenuView`, not by the parent `PosOrderPage`.

### Widget Tests

Use the `pumpApp` helper from `test/helpers/pump_app.dart` in all widget tests. It provides theme, localization, routing, and bloc scaffolding.

```dart
await tester.pumpApp(
  MyWidget(),
  menuRepository: menuRepository,
);
```

### GitHub Actions Workflows

Workflow files under `.github/workflows/` are auto-generated by mason. After any change to package dependencies (adding/removing entries in any `pubspec.yaml`), regenerate them by running:

```sh
.github/update_github_actions.sh
```

Commit the resulting file changes alongside the pubspec change. Failing to do so will cause the `Verify Github Actions` CI check to fail.

### Shared UI Package Dependency Constraint

`shared/very_yummy_coffee_ui` must **not** depend on any repository packages (`menu_repository`, `order_repository`, etc.) or `api_client`. It is a pure UI/theme package. Widgets that need domain types should accept primitive parameters (e.g. `int activeStep` instead of `OrderStatus`), and call sites in the app layer perform the mapping.

<!-- ============================================================
     VGV STANDARDS - Do not edit below this line
     Run init-project.sh to update VGV standards
     ============================================================ -->

# VGV Standards

**IMPORTANT:** Before beginning any Flutter/Dart development work, read and apply the VGV coding standards in `ai-coding/vgv-context.md`.

In addition, use the context7 mcp to look up Very Good Engineering best practices and bloc best practices when writing code.