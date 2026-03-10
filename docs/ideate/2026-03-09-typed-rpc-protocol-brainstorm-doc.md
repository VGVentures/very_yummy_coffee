---
date: 2026-03-09
topic: typed-rpc-protocol
---

# Formalize WebSocket RPC Message Types

## What We're Building

Replace all raw `Map<String, dynamic>` and string literals in the WebSocket RPC layer with typed sealed classes, an action enum, typed payload classes, and topic constants. This gives us compile-time safety for the entire client-server protocol, IDE autocomplete, and meaningful error responses for malformed messages.

The typed classes will live in the existing `very_yummy_coffee_models` package and use `dart_mappable` for serialization, consistent with all other models in the project.

## Why This Approach

### Approaches Considered

1. **New `shared/rpc_protocol/` package** -- Clean separation of protocol from domain models. Adds a package to manage and a new dependency edge for both `api_client` and `api/`.

2. **Add to `api_client`** -- Keeps protocol near the transport layer, but the server (`api/`) would need to depend on `api_client`, creating an awkward circular-ish relationship (server depends on client package).

3. **Add to `very_yummy_coffee_models`** (chosen) -- All shared types in one place. Both client and server already depend on this package. Protocol payloads reference domain models directly -- co-location avoids cross-package imports.

### Why `very_yummy_coffee_models`

- `dart_mappable` is already a dependency
- Protocol payloads reference domain models directly -- co-location avoids cross-package imports
- The package is already the shared contract between client and server
- One new dependency edge: `api_client` gains a dep on `very_yummy_coffee_models` (acceptable trade-off for full type safety at the transport layer)

## Prerequisites

### Move order models into `very_yummy_coffee_models`

Order domain models (`Order`, `LineItem`, `OrderStatus`, `SelectedModifier`, `SelectedOption`) currently live in `order_repository`. Typed RPC payload classes need to reference these models, so they must move to `very_yummy_coffee_models` first.

- Move model files from `order_repository/lib/src/models/` to `very_yummy_coffee_models/lib/src/`
- `order_repository` re-exports them from `very_yummy_coffee_models`
- Update all imports across the monorepo
- This is a mechanical refactor with no behavioral change

### Add `api_client` dependency on `very_yummy_coffee_models`

`WsRpcClient` will deserialize incoming messages into typed `RpcServerMessage` objects and serialize outgoing `RpcClientMessage` objects. This requires `api_client` to know about the message types.

- `LiveConnection` generic type changes from `Map<String, dynamic>` to `RpcServerMessage`
- `WsRpcClient` pattern-matches on `RpcServerMessage` subtypes instead of checking `message['type'] == 'update'`

## Key Decisions

- **Package location**: `very_yummy_coffee_models` -- extend existing shared models package
- **Serialization**: `dart_mappable` with sealed class discriminator on `type` field
- **Server validation**: Add typed error responses for malformed messages (structural errors only, not business-rule violations like invalid state transitions)
- **Migration strategy**: Big bang -- convert client, server, and repositories in one coordinated pass (codebase is small enough; ~5 files + tests)
- **Server internals scope**: Protocol boundary only -- server still stores state as raw maps, but deserializes incoming messages and serializes outgoing messages through typed classes
- **Message hierarchy**: `RpcClientMessage` (sealed) for client-to-server, `RpcServerMessage` (sealed) for server-to-client
- **Action enum**: `RpcAction` enum with `dart_mappable` for string serialization, each action gets a typed payload class
- **Topic constants**: `RpcTopics` abstract class with static constants and `order(id)` factory
- **`WsRpcClient` API**: Repositories construct typed `ActionMessage` instances; `WsRpcClient` accepts and serializes them. Avoids repositories knowing about message envelope structure while keeping types end-to-end.
- **`removeItemFromOrder`**: Omit from the enum -- the codebase uses `updateItemQuantity(quantity: 0)` instead. Clean up CLAUDE.md docs to match.

## Open Questions

- Should the error response include a correlation ID so the client can match errors to sent messages? (Leaning no -- current protocol is fire-and-forget, no client code awaits responses to actions. YAGNI.)
- Do we need protocol versioning now, or is that YAGNI for a single-deployment coffee app? (Leaning no -- all apps deploy from one monorepo.)
