# Very Yummy Coffee API

[![style: dart frog lint][dart_frog_lint_badge]][dart_frog_lint_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dart-frog.dev)

The backend server for Very Yummy Coffee, built with [Dart Frog](https://dartfrog.vgv.dev).

## Overview

The API holds all menu and order state in memory. The menu is loaded from `fixtures/menu.json` on startup. Clients interact with the server over a single WebSocket RPC endpoint that supports topic-based subscriptions and action-based mutations.

### Endpoints

- **`GET /`** — Health check
- **`GET /api/rpc`** — WebSocket RPC endpoint

### WebSocket RPC Protocol

Clients send JSON messages to subscribe to topics, unsubscribe, or perform actions:

- **`subscribe`** / **`unsubscribe`** — manage topic subscriptions (`menu`, `orders`, `order:<id>`)
- **`action`** — send mutations (`createOrder`, `addItemToOrder`, `submitOrder`, `startOrder`, `markOrderReady`, `completeOrder`, `cancelOrder`, `updateMenuItemAvailability`, etc.)

On subscribe, the server immediately sends the current state snapshot, then pushes updates to all relevant subscribers whenever any client's action changes the data.

### Server State

`lib/src/server_state.dart` is an in-memory singleton that stores the menu and all orders. It manages topic subscriptions as `Map<String, Set<StreamSink>>` and broadcasts changes after each action.

## Running

```sh
dart_frog dev
```

Starts on `http://localhost:8080` by default.

## Testing

```sh
dart test
```

[dart_frog_lint_badge]: https://img.shields.io/badge/style-dart_frog_lint-1DF9D2.svg
[dart_frog_lint_link]: https://pub.dev/packages/dart_frog_lint
