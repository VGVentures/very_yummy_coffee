---
title: "refactor: formalize WebSocket RPC message types with typed classes"
type: refactor
date: 2026-03-09
---

## refactor: formalize WebSocket RPC message types with typed classes - Extensive

## Overview

Replace all raw `Map<String, dynamic>` and string literals in the WebSocket RPC layer with typed sealed classes for actions, topic constants, and typed client message classes. This gives compile-time safety for the entire client-server protocol and IDE autocomplete for action names, payload fields, and topic names.

## Problem Statement

The WebSocket RPC layer (`/api/rpc`) uses raw maps and string literals throughout. Action names like `'createOrder'` are duplicated across client and server with no single source of truth. Payload fields are extracted with unsafe `as` casts (`payload['itemId'] as String`). A typo in an action name or a missing payload field produces a silent runtime failure, not a compile-time error.

**Current pain points:**
- 10 action names duplicated as string literals in `server_state.dart`, `order_repository.dart`, and `menu_repository.dart`
- Zero IDE autocomplete for action names or payload fields
- Refactoring an action name requires grep-and-replace across client and server

## Proposed Solution

Add typed RPC protocol classes to `very_yummy_coffee_models` using `dart_mappable`. Use a sealed `RpcAction` class hierarchy where each action is its own subtype with typed fields (no separate enum + payload classes). Update `WsRpcClient`, the server, and both repositories to use typed messages. Server internals remain raw maps (protocol-boundary-only typing).

### Key Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Package location | `very_yummy_coffee_models` | Both client and server already depend on it; co-locates protocol types with domain models |
| Serialization | `dart_mappable` | Consistent with all existing models; supports sealed class discriminators |
| Action typing | Sealed `RpcAction` subtypes (not enum + payload) | One type per action instead of three (enum + payload class + generic message). `CreateOrderAction(id: id)` vs `RpcActionMessage(action: RpcAction.createOrder, payload: CreateOrderPayload(id: id).toMap())` |
| Server scope | Protocol boundary only | Server stores state as raw maps; typed parsing on input only |
| Error responses | Server logs malformed messages | No `RpcErrorMessage` or client error stream — structural parse errors in a monorepo are dev-time bugs caught by tests, not runtime concerns. Add error responses later if needed. |
| `LiveConnection` | Remains `Map<String, dynamic>` | `WsRpcClient` converts between typed messages and maps internally; `LiveConnection` stays generic |
| Model relocation | **Not in scope** | Order models stay in `order_repository`. Action payload fields use primitives (`String orderId`) not domain model types (`Order`). Model move is a separate concern if ever needed. |
| `removeItemFromOrder` | Omit | Codebase uses `updateItemQuantity(quantity: 0)` instead. Clean up CLAUDE.md to match. |

## Technical Approach

### Architecture

```
┌─────────────────────────────────────────────────────┐
│  very_yummy_coffee_models                           │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │ Domain Models │  │ RPC Types    │  │ RpcTopics │ │
│  │ Menu, Mods…   │  │ sealed       │  │ constants │ │
│  └──────────────┘  │ RpcAction    │  └───────────┘ │
│                    │ RpcClient    │                 │
│                    │ Message      │                 │
│                    └──────────────┘                 │
└──────────┬──────────────────┬──────────────────┬────┘
           │                  │                  │
     ┌─────▼─────┐    ┌──────▼──────┐    ┌──────▼──────┐
     │ api_client │    │ order_repo  │    │ api server  │
     │ WsRpcClient│    │ menu_repo   │    │ rpc.dart    │
     │ typed API  │    │ typed calls │    │ typed parse │
     └────────────┘    └─────────────┘    └─────────────┘
```

**Dependency changes:**
- `api_client` gains dependency on `very_yummy_coffee_models` (new)
- All other dependencies unchanged

**Note:** `api_client` becomes coffee-app-specific with this change. Acceptable for a monorepo, but worth documenting.

### WsRpcClient API Design

`LiveConnection` remains `LiveConnection<Map<String, dynamic>>` — `WsRpcClient` handles typed↔map conversion internally.

```dart
// ws_rpc_client.dart — new public API

class WsRpcClient {
  /// Subscribe to a topic. Returns raw payload maps (repositories parse these).
  Stream<Map<String, dynamic>> subscribe(String topic);  // UNCHANGED

  /// Unsubscribe from a topic.
  void unsubscribe(String topic);  // UNCHANGED

  /// Send a typed action to the server.
  void sendAction(RpcAction action);  // CHANGED: was (String, Map)

  /// Connection state stream.
  Stream<bool> get isConnected;  // UNCHANGED

  void close();  // UNCHANGED
}
```

**Why `sendAction(RpcAction action)` and not `sendAction(RpcClientMessage)`:** The previous plan accepted any `RpcClientMessage` (including subscribe/unsubscribe), which is semantically wrong for a method called `sendAction`. Subscribe/unsubscribe are handled internally by `subscribe()`/`unsubscribe()` — those methods construct `RpcSubscribeMessage`/`RpcUnsubscribeMessage` internally and serialize via `.toMap()`.

**Why `subscribe()` still returns `Stream<Map<String, dynamic>>`:** Repositories already parse these into typed domain models (`OrderMapper.fromMap`, `MenuGroupMapper.fromMap`). Adding a typed intermediate would just be destructured immediately for no gain.

### RPC Type Hierarchy

All types in `very_yummy_coffee_models/lib/src/rpc/`.

#### Client → Server Messages

```dart
// rpc_client_message.dart
@MappableClass(discriminatorKey: 'type')
sealed class RpcClientMessage with RpcClientMessageMappable {
  // dart_mappable generates toMap() via mixin
}

@MappableClass(discriminatorValue: 'subscribe')
class RpcSubscribeMessage extends RpcClientMessage with RpcSubscribeMessageMappable {
  const RpcSubscribeMessage({required this.topic});
  final String topic;
}

@MappableClass(discriminatorValue: 'unsubscribe')
class RpcUnsubscribeMessage extends RpcClientMessage with RpcUnsubscribeMessageMappable {
  const RpcUnsubscribeMessage({required this.topic});
  final String topic;
}

@MappableClass(discriminatorValue: 'action')
class RpcActionClientMessage extends RpcClientMessage with RpcActionClientMessageMappable {
  const RpcActionClientMessage({required this.action, required this.payload});
  final String action;  // RpcAction.actionName (serialized by the action itself)
  final Map<String, dynamic> payload;
}
```

**Note:** `RpcActionClientMessage` is the wire-level envelope. Repositories never construct it directly — they construct typed `RpcAction` subtypes. `WsRpcClient.sendAction` wraps the `RpcAction` into an `RpcActionClientMessage` internally.

#### Sealed Action Hierarchy

Each action is its own subtype with typed fields. No separate enum or payload classes needed.

```dart
// rpc_action.dart

/// Marker for the action name used in the wire format.
/// Each subclass serializes to {'action': '<actionName>', 'payload': {...}}.
sealed class RpcAction {
  /// The wire-format action name (e.g., 'createOrder').
  String get actionName;

  /// Serializes the action's payload fields to a map.
  Map<String, dynamic> toPayloadMap();
}

class CreateOrderAction extends RpcAction {
  const CreateOrderAction({required this.id});
  final String id;

  @override
  String get actionName => 'createOrder';

  @override
  Map<String, dynamic> toPayloadMap() => {'id': id};
}

class AddItemToOrderAction extends RpcAction {
  const AddItemToOrderAction({
    required this.orderId,
    required this.lineItemId,
    required this.itemName,
    required this.itemPrice,
    this.menuItemId,
    this.modifiers = const [],
    this.quantity = 1,
  });
  final String orderId;
  final String lineItemId;
  final String itemName;
  final int itemPrice;
  final String? menuItemId;
  final List<Map<String, dynamic>> modifiers;
  final int quantity;

  @override
  String get actionName => 'addItemToOrder';

  @override
  Map<String, dynamic> toPayloadMap() => {
    'orderId': orderId,
    'lineItemId': lineItemId,
    'itemName': itemName,
    'itemPrice': itemPrice,
    'menuItemId': menuItemId,
    'modifiers': modifiers,
    'quantity': quantity,
  };
}

class UpdateItemQuantityAction extends RpcAction {
  const UpdateItemQuantityAction({
    required this.orderId,
    required this.lineItemId,
    required this.quantity,
  });
  final String orderId;
  final String lineItemId;
  final int quantity;

  @override
  String get actionName => 'updateItemQuantity';

  @override
  Map<String, dynamic> toPayloadMap() => {
    'orderId': orderId,
    'lineItemId': lineItemId,
    'quantity': quantity,
  };
}

/// Shared base for actions that only need an orderId.
/// Used by: submitOrder, startOrder, markOrderReady, completeOrder, cancelOrder
class SubmitOrderAction extends RpcAction {
  const SubmitOrderAction({required this.orderId});
  final String orderId;
  @override String get actionName => 'submitOrder';
  @override Map<String, dynamic> toPayloadMap() => {'orderId': orderId};
}

class StartOrderAction extends RpcAction {
  const StartOrderAction({required this.orderId});
  final String orderId;
  @override String get actionName => 'startOrder';
  @override Map<String, dynamic> toPayloadMap() => {'orderId': orderId};
}

class MarkOrderReadyAction extends RpcAction {
  const MarkOrderReadyAction({required this.orderId});
  final String orderId;
  @override String get actionName => 'markOrderReady';
  @override Map<String, dynamic> toPayloadMap() => {'orderId': orderId};
}

class CompleteOrderAction extends RpcAction {
  const CompleteOrderAction({required this.orderId});
  final String orderId;
  @override String get actionName => 'completeOrder';
  @override Map<String, dynamic> toPayloadMap() => {'orderId': orderId};
}

class CancelOrderAction extends RpcAction {
  const CancelOrderAction({required this.orderId});
  final String orderId;
  @override String get actionName => 'cancelOrder';
  @override Map<String, dynamic> toPayloadMap() => {'orderId': orderId};
}

class UpdateNameOnOrderAction extends RpcAction {
  const UpdateNameOnOrderAction({
    required this.orderId,
    this.customerName,
  });
  final String orderId;
  final String? customerName;
  @override String get actionName => 'updateNameOnOrder';
  @override Map<String, dynamic> toPayloadMap() => {
    'orderId': orderId,
    'customerName': customerName,
  };
}

class UpdateMenuItemAvailabilityAction extends RpcAction {
  const UpdateMenuItemAvailabilityAction({
    required this.itemId,
    required this.available,
  });
  final String itemId;
  final bool available;
  @override String get actionName => 'updateMenuItemAvailability';
  @override Map<String, dynamic> toPayloadMap() => {
    'itemId': itemId,
    'available': available,
  };
}
```

**Why hand-written `toPayloadMap()` instead of `dart_mappable`:** These are write-only types — constructed by repositories, serialized once, never deserialized. Codegen adds `.mapper.dart` files (~100+ lines each) for no benefit. Simple `toPayloadMap()` is explicit and testable.

**Why `modifiers` is `List<Map<String, dynamic>>` not `List<SelectedModifier>`:** Avoids requiring order models to move to `very_yummy_coffee_models`. Repositories call `modifiers.map((m) => m.toMap()).toList()` before constructing the action, same as today.

#### Topic Constants

```dart
// rpc_topics.dart
abstract final class RpcTopics {
  static const menu = 'menu';
  static const orders = 'orders';
  static String order(String id) => 'order:$id';
}
```

### How `WsRpcClient` Uses the Types

```dart
// Inside WsRpcClient

void sendAction(RpcAction action) {
  _connection.send({
    'type': 'action',
    'action': action.actionName,
    'payload': action.toPayloadMap(),
  });
}

// subscribe() internally:
void _sendSubscribe(String topic) {
  _connection.send(
    const RpcSubscribeMessage(topic: topic).toMap(),
  );
}
```

`LiveConnection.send` still receives `Map<String, dynamic>` which `jsonEncode` handles fine. No changes to `LiveConnection`.

### How the Server Parses Messages

```dart
// In rpc.dart — parse incoming JSON into typed RpcClientMessage

final json = jsonDecode(message as String) as Map<String, dynamic>;
try {
  final msg = RpcClientMessageMapper.fromMap(json);
  switch (msg) {
    case RpcSubscribeMessage(:final topic):
      serverState.subscribe(topic, sink);
      // send snapshot...
    case RpcUnsubscribeMessage(:final topic):
      serverState.unsubscribe(topic, sink);
    case RpcActionClientMessage(:final action, :final payload):
      serverState.handleAction(action, payload);
  }
} on MapperException catch (e) {
  log('[rpc] malformed message: $e');
  // Optionally: sink.add(jsonEncode({'type': 'error', 'message': '$e'}));
}
```

**Note:** `ServerState.handleAction` signature stays as `(String action, Map<String, dynamic> payload)` — server internals unchanged. The typed parsing happens at the route boundary only.

### How Repositories Construct Actions

```dart
// Before (order_repository.dart):
_wsRpcClient.sendAction('createOrder', {'id': id});

// After:
_wsRpcClient.sendAction(CreateOrderAction(id: id));

// Before:
_wsRpcClient.sendAction('addItemToOrder', {
  'orderId': currentOrderId,
  'lineItemId': _uuid.v4(),
  'itemName': itemName,
  'itemPrice': itemPrice,
  'menuItemId': menuItemId,
  'modifiers': modifiers.map((m) => m.toMap()).toList(),
  'quantity': quantity,
});

// After:
_wsRpcClient.sendAction(AddItemToOrderAction(
  orderId: currentOrderId!,
  lineItemId: _uuid.v4(),
  itemName: itemName,
  itemPrice: itemPrice,
  menuItemId: menuItemId,
  modifiers: modifiers.map((m) => m.toMap()).toList(),
  quantity: quantity,
));

// Before (menu_repository.dart):
_wsRpcClient.sendAction('updateMenuItemAvailability', {
  'itemId': itemId,
  'available': available,
});

// After:
_wsRpcClient.sendAction(UpdateMenuItemAvailabilityAction(
  itemId: itemId,
  available: available,
));
```

### Implementation Phases

#### Phase 1: Define RPC Types in `very_yummy_coffee_models`

Add all protocol types. No consumers changed yet.

- [ ] Create `shared/very_yummy_coffee_models/lib/src/rpc/` directory
- [ ] Create `rpc_client_message.dart` — sealed `RpcClientMessage` with `RpcSubscribeMessage`, `RpcUnsubscribeMessage`, `RpcActionClientMessage` (dart_mappable with discriminator on `type`)
- [ ] Create `rpc_action.dart` — sealed `RpcAction` with 10 action subtypes, each with typed fields and hand-written `toPayloadMap()` + `actionName` getter
- [ ] Create `rpc_topics.dart` — `abstract final class RpcTopics` with `menu`, `orders`, `order(id)`
- [ ] Create `rpc.dart` barrel file exporting all RPC types
- [ ] Update `shared/very_yummy_coffee_models/lib/very_yummy_coffee_models.dart` barrel to export `src/rpc/rpc.dart`
- [ ] Run `build_runner` in `very_yummy_coffee_models` to generate mapper files for `RpcClientMessage` hierarchy
- [ ] Write tests in `shared/very_yummy_coffee_models/test/src/rpc/`:
  - [ ] `rpc_client_message_test.dart` — serialization roundtrip for `RpcSubscribeMessage`, `RpcUnsubscribeMessage`, `RpcActionClientMessage`; verify `fromMap` dispatches to correct subtype via discriminator
  - [ ] `rpc_action_test.dart` — verify `actionName` and `toPayloadMap()` for all 10 action subtypes; verify all required fields are present in output
  - [ ] `rpc_topics_test.dart` — verify constant values and `order(id)` format

**Success criteria:** All tests pass. `RpcSubscribeMessage(topic: 'menu').toMap()` produces `{'type': 'subscribe', 'topic': 'menu'}`. `CreateOrderAction(id: '123').actionName` returns `'createOrder'`. Wire format matches existing protocol exactly.

#### Phase 2: Update `WsRpcClient`, Server, and Repositories

Wire typed messages into all consumers in one pass.

**api_client changes:**
- [ ] Add `very_yummy_coffee_models` dependency to `shared/api_client/pubspec.yaml`
- [ ] Update `WsRpcClient.sendAction` signature: `void sendAction(RpcAction action)` — internally constructs `{'type': 'action', 'action': action.actionName, 'payload': action.toPayloadMap()}` and passes to `_connection.send`
- [ ] Update internal `subscribe`/`unsubscribe` to construct `RpcSubscribeMessage`/`RpcUnsubscribeMessage` and call `_connection.send(message.toMap())`
- [ ] Update reconnect logic in `_ensureListening` to use typed subscribe messages
- [ ] `WsRpcClient.fromConnection` test constructor unchanged (still accepts `LiveConnection<Map<String, dynamic>>`)
- [ ] Update all tests in `shared/api_client/test/src/ws_rpc_client_test.dart`:
  - [ ] `sendAction` tests verify typed `RpcAction` objects produce correct map on the wire
  - [ ] `subscribe`/`unsubscribe` tests verify typed messages
  - [ ] Reconnect tests verify typed re-subscribe messages

**Server changes:**
- [ ] Update `api/routes/api/rpc.dart`:
  - [ ] Parse incoming JSON into `RpcClientMessage` via `RpcClientMessageMapper.fromMap`
  - [ ] Wrap in try/catch — on `MapperException`, log the error (no error response needed for now)
  - [ ] Pattern-match on `RpcClientMessage` subtypes instead of switching on `json['type']` string
  - [ ] Extract `action` string and `payload` map from `RpcActionClientMessage` for `handleAction`
- [ ] `ServerState.handleAction` signature unchanged — still `(String, Map<String, dynamic>)`
- [ ] `ServerState.broadcast` unchanged — still constructs raw update maps (server internals not in scope)
- [ ] Update server tests to use typed messages in test inputs

**Repository changes:**
- [ ] Update `OrderRepository` — replace all `_wsRpcClient.sendAction('actionName', {...})` with typed `RpcAction` subtypes (see "How Repositories Construct Actions" above)
- [ ] Update `MenuRepository.setItemAvailability` — use `UpdateMenuItemAvailabilityAction`
- [ ] Replace `_wsRpcClient.subscribe('orders')` with `_wsRpcClient.subscribe(RpcTopics.orders)`
- [ ] Replace `_wsRpcClient.subscribe('menu')` with `_wsRpcClient.subscribe(RpcTopics.menu)`
- [ ] Replace `_wsRpcClient.unsubscribe('menu')` with `_wsRpcClient.unsubscribe(RpcTopics.menu)`
- [ ] Update all tests in `shared/order_repository/test/` — mock expectations use typed actions
- [ ] Update all tests in `shared/menu_repository/test/` — same

**Success criteria:** No string literals for action names or topic names in repository or `WsRpcClient` code. All tests pass.

#### Phase 3: Cleanup and CI

- [ ] Remove `removeItemFromOrder` from CLAUDE.md protocol documentation
- [ ] Update CLAUDE.md: document new `WsRpcClient.sendAction(RpcAction)` signature and the repository pattern for constructing typed actions
- [ ] Run `.github/update_github_actions.sh` (pubspec change in `api_client`)
- [ ] Run `dart fix --apply` across all changed packages
- [ ] Run `dart format` across all changed packages
- [ ] Add one integration-style test that exercises the full path: construct typed `RpcAction` → serialize via `WsRpcClient` → parse via `RpcClientMessage.fromMap` → extract action/payload — verifying wire compatibility end-to-end
- [ ] Verify all CI checks pass

**Success criteria:** Zero raw string action names or topic names in client/server code. All tests green. CI passes including "Verify Github Actions" check.

## Alternative Approaches Considered

1. **Enum + separate payload classes** — Previous version of this plan used an `RpcAction` enum plus 6 `@MappableClass` payload classes. This meant 3 types per action call (`RpcActionMessage(action: RpcAction.createOrder, payload: CreateOrderPayload(id: id).toMap())`). The sealed subtype approach achieves the same safety with 1 type per call and no codegen for payloads. Rejected: unnecessary indirection.

2. **`RpcServerMessage` sealed hierarchy + `RpcErrorMessage` + client error stream** — Previous version added typed server→client messages and an error propagation path. But with no consumer of errors, no UI displaying them, and structural errors being dev-time bugs in a monorepo, this was YAGNI. The server currently handles `type == 'update'` in 2 lines — a sealed class with one subtype adds complexity for no benefit. Rejected: add when needed.

3. **Move order models to `very_yummy_coffee_models` first** — Previous prerequisite phase. But action payloads only need primitives (`String orderId`, `int itemPrice`), not domain model types. The one exception (`modifiers`) already uses `List<Map<String, dynamic>>` on the wire. Rejected: separate concern, do independently if needed.

4. **New `shared/rpc_protocol/` package** — Clean separation but adds a package and dependency edges. Rejected: more complexity for no benefit.

5. **Add to `api_client`** — Server would need to depend on a client library. Rejected: wrong dependency direction.

6. **Hand-written `fromJson`/`toJson` for client messages** — Inconsistent with codebase conventions. Rejected for `RpcClientMessage` (server needs `fromMap`). Action subtypes use hand-written `toPayloadMap()` since they are write-only — this is the right trade-off.

## Acceptance Criteria

### Functional Requirements

- [ ] All 10 RPC actions have typed `RpcAction` subtypes with named fields
- [ ] Action `actionName` values match existing wire-format strings exactly (no format change)
- [ ] `RpcTopics` constants cover all 3 topic patterns (menu, orders, order:id)
- [ ] `WsRpcClient.sendAction` accepts typed `RpcAction` objects
- [ ] Server parses incoming messages via `RpcClientMessageMapper.fromMap` and pattern-matches on subtypes
- [ ] Server logs malformed messages instead of silently ignoring them
- [ ] All existing client-server communication works identically (no wire format change)

### Non-Functional Requirements

- [ ] Zero raw string action names in repository or client transport code
- [ ] Zero raw string topic names in repository code
- [ ] No inline `Map<String, dynamic>` payload construction in repository code

### Quality Gates

- [ ] Serialization roundtrip tests for every `RpcClientMessage` variant
- [ ] `toPayloadMap()` tests for every `RpcAction` subtype
- [ ] Integration test: typed action → serialize → parse → extract matches original
- [ ] Updated tests for `WsRpcClient`, `rpc.dart`, `OrderRepository`, `MenuRepository`
- [ ] All existing tests pass (regression)
- [ ] CI green including "Verify Github Actions" check

## Dependencies & Prerequisites

| Dependency | Status | Notes |
|---|---|---|
| `dart_mappable` sealed class support | Available (v4.6.x) | Already in use for domain models |
| `api_client` dep on `very_yummy_coffee_models` | Added in Phase 2 | New dependency edge |
| GitHub Actions regeneration | Must run after pubspec changes | `.github/update_github_actions.sh` |

## Risk Analysis & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `dart_mappable` sealed class discriminator doesn't match wire format | Low | High | Write roundtrip tests in Phase 1 before touching any consumers |
| `@MappableEnum` default casing doesn't match camelCase action names | Low | High | Not using `@MappableEnum` — hand-written `actionName` getters give explicit control |
| `jsonEncode` fails on typed objects passed to `LiveConnection.send` | N/A | N/A | Eliminated: `WsRpcClient` passes `Map<String, dynamic>` to `send`, not typed objects |
| In-flight feature branches conflict on `sendAction` signature | Medium | Low | Conflicts are mechanical — just update string args to typed constructors |

## Future Considerations

- **Error responses:** Server currently silently ignores business-rule violations and malformed messages. When UX needs error feedback (e.g., "order already started"), add `RpcServerMessage` sealed class with `UpdateMessage` and `ErrorMessage` subtypes, plus a client `errors` stream.
- **Move order models to `very_yummy_coffee_models`:** If future RPC types need domain model references, do the model relocation then.
- **Full server typed internals:** Server stores state as raw maps. A follow-up could convert to typed `Order`/`MenuItem` objects for additional safety.
- **Protocol versioning:** YAGNI for a single-monorepo deployment.

## Documentation Plan

- [ ] Update CLAUDE.md: remove `removeItemFromOrder` from the protocol table
- [ ] Update CLAUDE.md: document `WsRpcClient.sendAction(RpcAction)` signature
- [ ] Update CLAUDE.md: add note about typed RPC classes in `very_yummy_coffee_models/lib/src/rpc/`
- [ ] Update CLAUDE.md: document repository pattern for constructing typed actions

## References & Research

### Internal References

- Brainstorm: `docs/ideate/2026-03-09-typed-rpc-protocol-brainstorm-doc.md`
- Current RPC client: `shared/api_client/lib/src/ws_rpc_client.dart`
- Current server state: `api/lib/src/server_state.dart`
- Current server route: `api/routes/api/rpc.dart`
- Current order repository: `shared/order_repository/lib/src/order_repository.dart`
- Current menu repository: `shared/menu_repository/lib/src/menu_repository.dart`
- Target package: `shared/very_yummy_coffee_models/lib/src/rpc/`

### Related Work

- Related issue: #45
