# Very Yummy Coffee Models

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

Shared domain models and typed RPC protocol classes for the Very Yummy Coffee system.

## Overview

This package defines all data types shared between the backend and front-end applications, serialized with `dart_mappable`:

- **Domain models** — `MenuGroup`, `MenuItem` (with `groupId` and `available` fields), `Order`, `LineItem`, `OrderStatus`
- **RPC protocol types:**
  - `RpcAction` — sealed class hierarchy with typed subtypes for each mutation (e.g., `CreateOrderAction`, `AddItemToOrderAction`, `SubmitOrderAction`)
  - `RpcClientMessage` — sealed class for client-to-server wire messages (`RpcSubscribeMessage`, `RpcUnsubscribeMessage`, `RpcActionClientMessage`)
  - `RpcTopics` — constants for topic names (`menu`, `orders`, `order(id)`)

## Code Generation

After modifying model classes, run the build runner:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Testing

```sh
dart test
```
