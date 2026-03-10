# Very Yummy Coffee

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A full-stack coffee ordering system built with Flutter and Dart Frog. The monorepo contains multiple front-end applications, a real-time backend, and shared packages that keep domain logic, API communication, and UI consistent across all apps.

## Repository Structure

```
very-yummy-coffee/
├── api/                   # Dart Frog backend server
├── applications/
│   ├── mobile_app/        # Customer ordering app (iOS/Android)
│   ├── kds_app/           # Kitchen Display System (landscape tablet)
│   ├── pos_app/           # Point-of-Sale terminal (iPad)
│   ├── kiosk_app/         # In-store self-service kiosk (landscape tablet)
│   └── menu_board_app/    # Menu board display
├── shared/
│   ├── api_client/        # HTTP + WebSocket client
│   ├── very_yummy_coffee_models/  # Shared domain models & RPC types
│   ├── menu_repository/   # Menu domain repository
│   ├── order_repository/  # Order domain repository
│   ├── connection_repository/  # WebSocket connection state
│   └── very_yummy_coffee_ui/   # Shared theme, design tokens & widgets
└── docs/                  # Plans, specs, and brainstorm documents
```

## Applications

| App | Description | Target |
|-----|-------------|--------|
| **Mobile App** | Customer-facing ordering app | iOS / Android |
| **KDS App** | Kitchen display for order queue management | Landscape tablet |
| **POS App** | Barista point-of-sale with ordering and order history | iPad |
| **Kiosk App** | In-store self-service ordering kiosk | Landscape tablet (1366x1024) |
| **Menu Board App** | Real-time menu display with order status panel | Large display |

## Backend

The API server is built with [Dart Frog](https://dartfrog.vgv.dev) and exposes:

- **`GET /`** &mdash; Health check
- **`GET /api/rpc`** &mdash; WebSocket RPC endpoint for real-time sync

All state is held in-memory. The menu is loaded from `api/fixtures/menu.json` on startup. Clients connect via a single WebSocket and use a topic-based subscribe/unsubscribe model to receive live updates for menus, orders, and individual order tracking.

## Shared Packages

| Package | Purpose |
|---------|---------|
| `api_client` | HTTP and WebSocket client; exports `ApiClient`, `LiveConnection`, `WsRpcClient` |
| `very_yummy_coffee_models` | Domain models (`MenuGroup`, `MenuItem`, `Order`, etc.) and typed RPC protocol classes, serialized with `dart_mappable` |
| `menu_repository` | Menu domain with lazy, ref-counted WebSocket subscriptions via `rxdart` |
| `order_repository` | Order domain with WebSocket-synced mutations |
| `connection_repository` | WebSocket connection state management |
| `very_yummy_coffee_ui` | Design tokens (colors, spacing, radius, typography), theme, and shared widgets (`AppTopBar`, `BaseButton`, `CustomBackButton`) |

## Architecture

- **State management**: Bloc (with explicit event classes)
- **Navigation**: GoRouter with `context.go('/path')` and hardcoded path strings
- **Real-time sync**: Single WebSocket RPC connection per app, multiplexed via `WsRpcClient`
- **Serialization**: `dart_mappable` for all models
- **Linting**: `very_good_analysis` + `bloc_lint`

### WebSocket RPC Protocol

Clients communicate with the server over a single WebSocket at `/api/rpc`. The protocol supports three client message types:

- **`subscribe`** / **`unsubscribe`** &mdash; manage topic subscriptions (`menu`, `orders`, `order:<id>`)
- **`action`** &mdash; send mutations (e.g., `createOrder`, `addItemToOrder`, `submitOrder`, `startOrder`, `markOrderReady`, `completeOrder`, `cancelOrder`)

On subscribe, the server immediately sends the current state snapshot, then pushes updates whenever any client's action changes the relevant data.

## Getting Started

### Prerequisites

- Flutter SDK `>=3.41.2`
- Dart SDK `>=3.11.0`
- [Dart Frog CLI](https://dartfrog.vgv.dev) (`dart pub global activate dart_frog_cli`)

### Running the Backend

```sh
cd api
dart_frog dev
```

The server starts on `http://localhost:8080` by default.

### Running an Application

```sh
cd applications/mobile_app   # or kds_app, pos_app, kiosk_app, menu_board_app
flutter run
```

### Running Tests

Each package has its own test suite:

```sh
cd <package_directory>
flutter test          # for Flutter packages
dart test             # for pure Dart packages (api, api_client, models, etc.)
```

### Updating GitHub Actions

After changing any `pubspec.yaml` (adding/removing dependencies), regenerate CI workflows:

```sh
.github/update_github_actions.sh
```

Commit the resulting changes alongside the pubspec update.
