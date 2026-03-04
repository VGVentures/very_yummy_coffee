# Very Yummy Coffee — POS App

A Flutter application for the point-of-sale (POS) terminal at Very Yummy Coffee.
Designed for iPad landscape orientation operated by baristas at the counter.

## Overview

The POS app connects to the Very Yummy Coffee backend via WebSocket and provides
a split-pane ordering interface:

| LEFT PANEL | RIGHT PANEL |
|------------|-------------|
| Menu browser with category tabs and item grid | Live order ticket with line items and totals |

Baristas can take orders and process payments:

- **Add items** — tap menu items to add to the current order (unavailable items are blocked)
- **Remove items** — swipe or tap remove on order ticket line items
- **Charge** — submit the order and navigate to the receipt screen
- **New Order** — clear the receipt and start fresh
- **View Orders** — navigate to the orders dashboard (active + history)

The app preserves the receipt screen if the WebSocket connection drops mid-transaction,
and redirects to a connecting screen for all other views.

## Running the App

```sh
flutter run -d <ipad-device-id>
```

The app targets iPad landscape orientation. The backend (`api/`) must be running
locally on port 8080.

## Architecture

- **AppBloc** — manages WebSocket connection state (`connecting` → `connected`)
- **MenuBloc** — subscribes to menu groups and items via a single ref-counted WebSocket
  subscription; filters items by selected category
- **OrderTicketBloc** — manages the live order ticket; creates orders on demand,
  guards against duplicate charge taps, and triggers receipt navigation
- **PosOrderCompleteBloc** — subscribes to a completed order by ID to display the receipt
- **PosOrdersBloc** — subscribes to all orders and filters into active/history lists

## Testing

```sh
flutter test
```

All business logic (blocs) has unit tests under `test/`. 30 tests, all passing.
