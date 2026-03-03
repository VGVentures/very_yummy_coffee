---
date: 2026-02-23
topic: cart-page
---

# Cart Page

## What We're Building

A cart screen that lets users review the items they've added, adjust quantities, remove items, and see a price breakdown. The design (from `design.pen` → "Cart" frame) shows a primary-colored header ("My Cart" + item count), a scrollable list of cart items with +/- quantity controls and a trash button each, an order summary card (subtotal, 8% tax, total), and a fixed bottom checkout bar.

The current `LineItem` model stores flat items (one UUID per add-to-cart) with no `options` or `quantity` field. Implementing the cart faithfully requires extending the model and backend before building the UI.

The checkout button is **out of scope** — it will not be implemented. The cart is complete when items can be viewed, quantities adjusted, and items removed.

## Why This Approach

Three approaches were considered:

**Option A — Full model extension (chosen):** Extend `LineItem` with `options` and `quantity` fields; add a new `updateItemQuantity` WS action; compute tax client-side at 8%.

**Option B — Client-side grouping, encode options in name:** No model changes; group by name in CartBloc for quantity; pack options string into the item name at add-time. Rejected: options packed into a name string cannot be recovered for display without fragile string parsing.

**Option C — Options as structured sub-object:** Model options as separate fields (size, milk, extras) on LineItem. Rejected: a formatted string is sufficient for the cart view and avoids unnecessary model complexity.

## Key Decisions

- **Item options**: Add `options: String` to `LineItem` (e.g. `"Medium · Oat Milk · Vanilla Syrup"`). Built from the user's selections in `ItemDetailBloc` and sent with `addItemToOrder`.
- **Quantity**: Add `quantity: int` to `LineItem`. `addItemToOrder` sends initial quantity 1. A new `updateItemQuantity` WS action handles changes from the cart; sending `quantity: 0` removes the item (trash and decrement-to-zero both use this).
- **Tax**: Computed in `CartBloc` as `(subtotal * 0.08).round()` (integer cents). Not stored in state or persisted to the server.
- **Navigation**: `/cart` is a top-level GoRoute sibling to `/menu-groups`. Navigated to with `context.go('/cart')`.
- **Empty cart**: Show an empty-state message with a prompt to browse the menu. No redirect.
- **Checkout button**: Not implemented in this scope.

## Scope of Changes

### 1. Shared models (`order_repository`)
- `LineItem`: add `options: String` (default `''`) and `quantity: int` (default `1`)
- `Order.total`: update to `items.fold(0, (sum, i) => sum + i.price * i.quantity)`
- `OrderRepository.addItemToCurrentOrder`: add `options` and `quantity` params; pass them in the WS payload. **Breaking change** — all existing callers (ItemDetailBloc) must be updated.
- `OrderRepository.updateItemQuantity(String lineItemId, int quantity)`: new method; sends `updateItemQuantity` WS action with `{orderId, lineItemId, quantity}`

### 2. Backend (`api/lib/src/server_state.dart`)
- Handle `updateItemQuantity` action: find line item by id; if `quantity == 0` remove it, otherwise update its quantity; broadcast updated order to subscribers.

### 3. ItemDetailBloc
- `ItemDetailAddToCartRequested`: build options string from `selectedSize`, `selectedMilk`, `selectedExtras`; pass to updated `addItemToCurrentOrder`.

### 4. Cart feature (`applications/mobile_app/lib/cart/`)
- `CartBloc` with events:
  - `CartSubscriptionRequested` — subscribes to `currentOrderStream`
  - `CartItemQuantityUpdated(lineItemId, quantity)` — calls `updateItemQuantity`; `quantity: 0` handles both trash and decrement-to-zero
- `CartState(order: Order?, status: CartStatus)` — tax computed inline in the view as `(order.total * 0.08).round()`
- `CartPage` / `CartView` following the existing page/view barrel pattern
- Empty state: shown when `order == null` or `order.items.isEmpty`

### 5. Router
- Add `GoRoute(path: '/cart')` as a top-level route in `AppRouter`
- Navigate from ItemDetail "added" state: `context.go('/cart')`
