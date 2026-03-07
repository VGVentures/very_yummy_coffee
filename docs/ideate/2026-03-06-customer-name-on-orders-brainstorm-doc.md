---
date: 2026-03-06
topic: customer-name-on-orders
issue: "#32"
---

# Customer Name on Orders

## What We're Building

Add an optional `customerName` field to orders so baristas can call out names when drinks are ready. Every ordering surface (mobile, kiosk, POS) collects the name differently based on its context — customer self-service vs. barista-entered. Display surfaces (KDS, POS order history) show the name prominently alongside the order number.

The feature spans the full stack: shared model, server state, WS actions, repository layer, and UI across four apps.

## Why This Approach

We considered three levels of complexity:

**Approach A: Name on `createOrder` only (immutable)** — simplest, but prevents baristas from correcting typos or adding a name after order creation.

**Approach B: `createOrder` + `updateNameOnOrder` (chosen)** — two WS actions. `createOrder` accepts an optional name at creation time (mobile, kiosk). `updateNameOnOrder` lets the POS barista set or correct the name at any point before submission. Minimal added complexity, covers all real-world scenarios.

**Approach C: Full name-editing from any app** — over-engineered for a coffee shop. Customers don't need to rename orders mid-flight.

Approach B was chosen: it covers the POS correction use case without over-engineering.

## Key Decisions

- **Model**: `String? customerName` on `Order` (nullable, optional). No separate `Customer` entity — YAGNI.
- **WS actions**: `createOrder` stays unchanged (no name param). New `updateNameOnOrder` action accepts `{orderId, customerName}`, handled in `ServerState.handleAction`. All apps use `updateNameOnOrder` as the single path to set the name.
- **Repository**: `createOrder()` unchanged. New `updateNameOnCurrentOrder(String customerName)` method on `OrderRepository` — auto-creates an order (like `addItemToCurrentOrder`) if `currentOrderId` is null, then sends the `updateNameOnOrder` WS action.
- **Why `updateNameOnOrder` everywhere**: the name is never reliably known at order-creation time. Kiosk collects the name at checkout, after items are already in the cart. POS creates the order before the barista types a name. A single `updateNameOnOrder` action keeps one consistent path across all apps. The repository method `updateNameOnCurrentOrder` auto-creates an order if needed (same pattern as `addItemToCurrentOrder`), so mobile can set the name eagerly on "Start New Order".
- **POS name sync**: the POS sends `updateNameOnOrder` debounced at 500ms while the barista types, so the KDS sees the name updating in near-real-time.
- **Name editing is POS-only**: only baristas on the POS can correct the name after it's set. Mobile/kiosk send the name once and don't offer editing.

### Per-App UX Decisions

**Mobile app:**
- Dedicated tappable name row below the `_HomeHeader`, showing "Your name: Marcus" or "Tap to add your name".
- Tapping opens inline editing (text field replaces the label).
- Name persisted to `SharedPreferences` and pre-filled on return.
- When tapping "Start New Order", the app calls `updateNameOnCurrentOrder(name)` which auto-creates the order and sets the name in one step. Optional — ordering works without a name.

**Kiosk app:**
- Name entry section added to the existing checkout screen (above the fake payment card).
- Single text field with placeholder hint (e.g., "Enter your name (optional)"). No separate skip button needed — leaving it blank is the skip.
- `CheckoutBloc` sends `updateNameOnOrder` before submitting the order if a name was entered.
- Order Complete screen personalises: "Thanks, Marcus!" when a name is present.

**POS app:**
- Always-editable text field at the top of the `OrderTicket` panel (320px right sidebar).
- Barista types the name while building the order — no dialog or extra tap.
- Field stays editable until order submission. Updates sent via debounced `updateNameOnOrder` WS action.
- Order history: `customerName` displayed in both `_ActiveOrderCard` and `_TableDataRow` (alongside order number).

**KDS app:**
- `KdsOrderCard` displays `customerName` prominently below/beside the order number.
- Falls back to showing only the order number if name is blank (existing behaviour preserved).
- Name should be large enough to read across the counter.

## Confirmed Non-Changes

- **Menu board app**: display-only, doesn't show orders — no changes needed.

## Open Questions

- **Name max length**: should we enforce a character limit (e.g., 30 chars) to prevent layout overflow on KDS cards and POS tickets? Leaning yes — cap at 30.
- **SharedPreferences key**: `customer_name` — simple string key. No migration needed since this is a new field.
