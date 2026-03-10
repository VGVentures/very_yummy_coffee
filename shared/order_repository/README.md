# Order Repository

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A repository managing the ordering domain for Very Yummy Coffee.

## Overview

Provides reactive order streams and mutation methods, all synced via WebSocket:

- **`ordersStream`** — stream of all orders (subscribes to the `orders` WebSocket topic on first access)
- **`currentOrderStream`** — stream tracking the current in-progress order
- **Mutations** — `createOrder()`, `addItemToOrder()`, `updateItemQuantity()`, `removeItemFromOrder()`, `submitOrder()`, `startOrder()`, `markOrderReady()`, `completeOrder()`, `cancelOrder()`, `updateNameOnOrder()`, `clearCurrentOrder()`

All mutations send typed `RpcAction` messages over WebSocket. There is no local state mutation; the server is the source of truth and pushes updates back to all subscribers.

## Testing

```sh
dart test
```
