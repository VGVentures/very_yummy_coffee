# Very Yummy Coffee — KDS App

A Flutter application for the kitchen display system (KDS) at Very Yummy Coffee.
Designed for landscape tablet displays mounted in the kitchen.

## Overview

The KDS app connects to the Very Yummy Coffee backend via WebSocket and presents
incoming orders in a three-column board:

| NEW | IN PROGRESS | READY |
|-----|-------------|-------|
| Orders submitted by customers | Orders being prepared | Orders ready for pickup |

Kitchen staff can move orders through the workflow:

- **Start** — moves an order from NEW → IN PROGRESS and starts a live elapsed timer
- **Mark Ready** — moves an order from IN PROGRESS → READY
- **Complete** — removes a READY order from the board
- **Cancel** — removes any order from the board

The app automatically reconnects if the WebSocket connection drops and navigates
back to a connecting screen until the server is reachable again.

## Running the App

```sh
flutter run -d <device-id>
```

The app targets landscape orientation. Run on a tablet simulator or physical tablet
for the best experience. The backend (`api/`) must be running locally on port 8080.

## Architecture

- **AppBloc** — manages WebSocket connection state (`connecting` → `connected`)
- **KdsBloc** — subscribes to the `orders` WebSocket topic, sorts and filters
  orders by status, and dispatches kitchen actions (start, ready, complete, cancel)
- **KdsView** — three-column layout using `KdsColumn` and `KdsOrderCard` widgets
- **KdsTopBar** — displays a live clock and WebSocket connection status

## Testing

```sh
flutter test
```

All business logic (blocs) and widgets have unit/widget tests under `test/`.
