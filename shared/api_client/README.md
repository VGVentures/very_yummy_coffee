# API Client

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

HTTP and WebSocket client for communicating with the Very Yummy Coffee backend.

## Overview

This package provides the networking layer used by all front-end applications:

- **`ApiClient`** — HTTP client for REST endpoints (initial menu fetch, etc.)
- **`LiveConnection`** — manages the raw WebSocket connection lifecycle
- **`WsRpcClient`** — multiplexes multiple topic subscriptions over a single WebSocket connection. Calling `subscribe(topic)` twice returns the same broadcast stream (no duplicate server messages). Accepts typed `RpcAction` subtypes for mutations.

Repositories (`menu_repository`, `order_repository`) depend on this package and use `WsRpcClient` for all real-time communication.

## API connection (`dart-define`)

Apps typically construct [`ApiClient.fromDartDefines`](lib/src/api_client.dart). Compile-time flags:

| Define | Meaning | Default |
|--------|---------|---------|
| `API_HOST` | Server hostname | `localhost` |
| `API_PORT` | Port; empty string omits explicit port (default for the scheme) | `8080` |
| `API_SECURE` | `true` → HTTPS + WSS; `false` → HTTP + WS | `false` |
| `API_KEY` | `X-API-KEY` header | empty |

Example:

```sh
flutter run --dart-define=API_HOST=api.example.com --dart-define=API_PORT=443 --dart-define=API_SECURE=true --dart-define=API_KEY=secret
```

## Testing

```sh
dart test
```
