---
date: 2026-03-08
topic: stock-management-oos-display
---

# In-Stock Management with Out-of-Stock Display

## What We're Building

A complete stock availability feature that lets POS baristas toggle menu items in/out of stock, with real-time out-of-stock treatment displayed across all customer-facing surfaces (mobile, kiosk, menu board). The infrastructure already exists: `MenuItem.available`, the `updateMenuItemAvailability` WS action, and live menu broadcasts. This feature wires the UI on top.

The scope covers: adding `menuItemId` to `LineItem` (prerequisite for cart-availability checking), a new `menu_repository.setItemAvailability()` method, a dedicated POS stock management screen, out-of-stock display on POS ordering/mobile/kiosk/menu board item cards, and cart-level warnings when items become unavailable mid-session.

## Why This Approach

### POS Stock Management: Dedicated Tab

Three options were considered:

1. **Dedicated tab** (chosen) — A new `/stock-management` route in the POS top bar alongside "Ordering" and "Order History". All items grouped by category with availability toggles.
2. **Bottom sheet from order screen** — Quick access but adds complexity to an already busy ordering UI.
3. **Inline toggles on menu grid** — Embeds stock management into the ordering flow, risking accidental toggles and cluttering the primary ordering UI.

The dedicated tab wins because toggling stock is an intentional management action, not part of order-taking. It keeps the ordering screen clean and provides a purpose-built view for scanning all items at once.

### Cart Unavailability: Block Checkout with Warning

Two options were considered:

1. **Block checkout with inline warning** (chosen) — Show a warning badge on affected cart line items and disable checkout until the unavailable item is removed.
2. **Auto-remove with snackbar** — Silently remove items and notify via snackbar. Less friction but surprising to customers.

Blocking checkout is more transparent. The customer sees exactly what happened and decides how to proceed (remove the item, wait, or browse alternatives). This prevents confusion and bad orders.

### Scope: All Surfaces in One Feature

Menu board changes are included despite being view-only. The dimmed-item + "Unavailable" label treatment is small, and shipping all surfaces together ensures consistency and a complete feature.

## Key Decisions

- **Add `menuItemId` to `LineItem`** (prerequisite): Currently `LineItem` only has `id` (lineItemId), `name`, `price`, `modifiers`, `quantity` — no way to cross-reference against `MenuItem.available`. Adding `menuItemId` requires a model change, server passthrough in `addItemToOrder`, and updated `addItemToCurrentOrder()` signature. This is foundational for cart-availability checking.
- **POS stock UI is a dedicated tab** (`/stock-management`): Clean separation from ordering, purpose-built for scanning and toggling all items by category
- **POS ordering grid also dims/disables out-of-stock items**: Consistent treatment — baristas see availability state on both the ordering and stock management screens
- **Cart unavailability blocks checkout**: Inline warning on affected line items, checkout button disabled until resolved
- **Kiosk `ItemDetailPage` shows overlay on mid-session unavailability**: Display out-of-stock overlay and disable "Add to Order" rather than navigating away — less jarring for the customer
- **Shared `OutOfStockBadge` and `UnavailableOverlay` widgets**: Placed in `very_yummy_coffee_ui` for reuse across mobile, kiosk, and menu board — accepts primitive params only (no domain types)
- **`menu_repository.setItemAvailability()`**: New method sends the existing `updateMenuItemAvailability` WS action — no server changes needed beyond the `menuItemId` passthrough
- **Menu board included**: Dimmed items + "Unavailable" label, view-only, no interaction
- **KDS unchanged**: Availability is a pre-order concern; KDS only sees placed orders
- **All UI uses design tokens**: `unavailableOverlay` color token already exists; `OutOfStockBadge` uses appropriate color/typography tokens

## Open Questions

- Should the POS stock management screen support search/filter for shops with large menus, or is grouped-by-category sufficient for the current menu size?
- Should there be any confirmation dialog when toggling an item out of stock (e.g., "This will affect X active orders"), or is instant toggle sufficient?
