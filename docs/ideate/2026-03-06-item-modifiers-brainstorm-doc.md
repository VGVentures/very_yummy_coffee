---
date: 2026-03-06
topic: item-modifiers
issue: https://github.com/VGVentures/very-yummy-coffee/issues/30
---

# Dynamic Item Modifiers with Pricing

## What We're Building

Menu items will support server-driven modifier groups (size, milk, syrup, temperature, etc.) that can add to the base price. Modifier groups are category-scoped — each group declares which `MenuGroup` IDs it applies to, so only relevant options appear per item. All ordering surfaces (mobile, kiosk, POS) show modifier selection UI; KDS shows selected modifiers per line item for barista context; the menu board is unchanged.

This replaces the current hardcoded client-side enums (`DrinkSize`, `MilkOption`, `DrinkExtra`) and the flat `options` string on `LineItem` with structured, server-driven modifier data that carries pricing information end-to-end.

## Why This Approach

### Approaches considered

**A. Category-level scoping only (chosen)** — `ModifierGroup.appliesToGroupIds` declares which menu categories a modifier group applies to. `MenuItem` needs no new field. The UI resolves applicable modifiers by matching `item.groupId` against each group's `appliesToGroupIds`. Simpler model, less fixture duplication, and sufficient for a coffee menu where modifiers naturally align with drink/food categories.

**B. Dual scoping (issue's original proposal)** — Both `ModifierGroup.appliesToGroupIds` AND `MenuItem.modifierGroupIds`. More flexible per-item control, but adds a field to every menu item in the fixture and creates two sources of truth. Rejected as YAGNI — no current menu item needs modifiers that differ from its category siblings.

**C. Item-level only** — Each `MenuItem` lists its own `modifierGroupIds`. No category scoping. Maximum flexibility but maximum fixture verbosity — every item must explicitly list its modifier groups. Rejected.

### Price storage approach

**Chosen: base price + compute at read time.** `LineItem.price` stays as the base menu item price. `Order.total` iterates each line item's modifiers to compute the real total. This is more transparent (you can always see the base vs. modifier breakdown) and resilient if modifier pricing is ever adjusted.

**Rejected: pre-computed unit price.** Storing `price = base + modifiers` on LineItem is simpler for totals but loses the breakdown and makes it harder to display "Base: $4.50 + Oat Milk: +$0.75" in cart views.

### Denormalization

**Chosen: fully denormalized SelectedModifier.** Each modifier group selection on a line item carries the group name and a nested list of selected options with their names and price deltas. Line items are self-contained — cart, KDS, and order history never need to look up modifier definitions from the menu.

### SelectedModifier structure

**Chosen: one SelectedModifier per group with nested option details.** Each `SelectedModifier` represents one modifier group and contains a `List<SelectedOption>` for the selected options within that group. For single-select groups (e.g. Size), the list has one entry. For multi-select groups (e.g. Syrups), the list has multiple entries. Each `SelectedOption` carries its own `priceDeltaCents` for transparent pricing.

**Rejected: one SelectedModifier per selected option.** Simpler for price computation but loses the group-level structure, making it harder to validate single-select constraints and display grouped modifier summaries.

### Server validation

**Chosen: client-side validation only.** The server trusts modifier data from the client. Client-side blocs validate required groups before sending `addItemToOrder`. No `itemId` is added to the payload. This keeps the server simple and avoids adding a WS error message type.

### Cart item editing

**Scoped out.** Users must delete a line item and re-add it with different modifiers. Cart editing of modifiers is a follow-up feature.

## Key Decisions

- **Scoping**: Category-level only via `ModifierGroup.appliesToGroupIds`. No `modifierGroupIds` field on `MenuItem`.
- **Price model**: `LineItem.price` = base price. Total computed at read time as `sum((price + modifierDeltas) * quantity)`.
- **SelectedModifier structure**: One per group, with nested `List<SelectedOption>` carrying per-option names and price deltas.
- **Denormalization**: Fully denormalized — line items are self-contained with all modifier display data.
- **Remove `options` string**: The current `LineItem.options` (plain String) is deleted entirely. Display strings are derived from the structured `modifiers` list.
- **Validation**: Client-side only. Server stores what the client sends. No `itemId` in payload.
- **Cart editing**: Out of scope — delete and re-add.
- **Default selections**: Required groups with a `defaultOptionId` are pre-selected on page load, making the item immediately addable. Required groups without defaults start empty (add button disabled).
- **Items with no modifiers**: POS quick-adds immediately (current behavior). Mobile/kiosk show item detail without modifier sections, add button immediately enabled.
- **Menu board unchanged**: No modifier display on the menu board app.

## Data Model Summary

### New models in `very_yummy_coffee_models`

```dart
@MappableClass()
class ModifierOption with ModifierOptionMappable {
  final String id;
  final String name;
  final int priceDeltaCents; // 0 = no change, positive = surcharge
}

@MappableClass()
class ModifierGroup with ModifierGroupMappable {
  final String id;
  final String name;
  final ModifierGroupType type;
  final List<String> appliesToGroupIds; // MenuGroup IDs; empty = all
  final SelectionMode selectionMode;    // single | multi
  final bool required;
  final String? defaultOptionId;
  final List<ModifierOption> options;
}

@MappableEnum()
enum ModifierGroupType { size, milk, syrup, temperature, other }

@MappableEnum()
enum SelectionMode { single, multi }
```

### New models for order line items

```dart
@MappableClass()
class SelectedOption with SelectedOptionMappable {
  final String id;
  final String name;
  final int priceDeltaCents;
}

@MappableClass()
class SelectedModifier with SelectedModifierMappable {
  final String modifierGroupId;
  final String modifierGroupName;
  final List<SelectedOption> options; // 1 entry for single-select, N for multi-select
}
```

### LineItem changes

```dart
@MappableClass()
class LineItem with LineItemMappable {
  final String id;
  final String name;
  final int price;                        // base price (unchanged semantics)
  final int quantity;
  final List<SelectedModifier> modifiers; // NEW — replaces `options` string
}
```

### Convenience getters on LineItem

```dart
/// Total price delta from all modifiers across all groups.
int get modifierPriceDelta => modifiers.fold(0, (sum, mod) =>
  sum + mod.options.fold(0, (s, opt) => s + opt.priceDeltaCents));

/// Unit price including modifiers (base + all deltas).
int get unitPriceWithModifiers => price + modifierPriceDelta;
```

### Order.total update

```dart
int get total => items.fold(0, (sum, item) =>
  sum + item.unitPriceWithModifiers * item.quantity);
```

## WS Protocol Changes

### Menu payload gains `modifierGroups`

```json
{
  "type": "update",
  "topic": "menu",
  "payload": {
    "groups": [...],
    "items": [...],
    "modifierGroups": [
      {
        "id": "size",
        "name": "Size",
        "type": "size",
        "appliesToGroupIds": ["espresso-drinks", "milk-based", "cold-drinks", "tea"],
        "selectionMode": "single",
        "required": true,
        "defaultOptionId": "tall",
        "options": [
          {"id": "short", "name": "Short", "priceDeltaCents": 0},
          {"id": "tall", "name": "Tall", "priceDeltaCents": 0},
          {"id": "grande", "name": "Grande", "priceDeltaCents": 50},
          {"id": "venti", "name": "Venti", "priceDeltaCents": 100}
        ]
      }
    ]
  }
}
```

### `addItemToOrder` payload gains `modifiers`

```json
{
  "type": "action",
  "action": "addItemToOrder",
  "payload": {
    "orderId": "<uuid>",
    "lineItemId": "<uuid>",
    "itemName": "Latte",
    "itemPrice": 450,
    "quantity": 1,
    "modifiers": [
      {
        "modifierGroupId": "size",
        "modifierGroupName": "Size",
        "options": [
          {"id": "grande", "name": "Grande", "priceDeltaCents": 50}
        ]
      },
      {
        "modifierGroupId": "milk",
        "modifierGroupName": "Milk",
        "options": [
          {"id": "oat", "name": "Oat", "priceDeltaCents": 75}
        ]
      },
      {
        "modifierGroupId": "syrup",
        "modifierGroupName": "Syrup",
        "options": [
          {"id": "vanilla", "name": "Vanilla", "priceDeltaCents": 50},
          {"id": "hazelnut", "name": "Hazelnut", "priceDeltaCents": 50}
        ]
      }
    ]
  }
}
```

## Server Changes

### `ServerState` updates

- `loadMenu()` parses the `modifierGroups` key from `fixtures/menu.json` into `List<Map<String, dynamic>> _modifierGroups`.
- `snapshotForTopic('menu')` returns `{'groups': _menuGroups, 'items': _menuItems, 'modifierGroups': _modifierGroups}`.
- `handleAction('addItemToOrder')` reads `payload['modifiers']` (a `List<Map>`) and stores it on the line item map. No server-side validation of modifier requirements — client is trusted.

### `MenuRepository` updates

- `_MenuCache` gains a `List<ModifierGroup> modifierGroups` field.
- The existing menu stream (from `getMenuGroupsAndItems()`) is extended to include modifier groups. Return type becomes a record with three fields: `({List<MenuGroup> groups, List<MenuItem> items, List<ModifierGroup> modifierGroups})`.
- Alternatively, add a dedicated `getModifierGroups()` stream that shares the same underlying WS subscription via ref-counting.

### Modifier group filtering (shared utility)

A utility function resolves which modifier groups apply to a given menu item:

```dart
List<ModifierGroup> applicableModifierGroups(
  String itemGroupId,
  List<ModifierGroup> allGroups,
) => allGroups.where((g) =>
  g.appliesToGroupIds.isEmpty || g.appliesToGroupIds.contains(itemGroupId)
).toList();
```

This lives in `very_yummy_coffee_models` (pure function, no dependencies) so all apps can use it.

## Per-App Impact

| App | Changes |
|-----|---------|
| **mobile_app** | Replace hardcoded `DrinkSize`/`MilkOption`/`DrinkExtra` enums with server-driven modifier UI on ItemDetailPage. `ItemDetailBloc` tracks `Map<String, List<String>> selectedModifiers` initialized from defaults. Cart shows modifier summary + `unitPriceWithModifiers` per line. `ItemDetailState.totalPrice` becomes `(basePrice + modifierDeltas) * quantity`. |
| **kiosk_app** | Same as mobile — replace hardcoded enums. Full-screen modifier layout. |
| **pos_app** | Items with applicable modifier groups show a bottom sheet for selection before adding. Items with no modifiers quick-add as today. Order summary shows modifier summary per line item with adjusted price. |
| **kds_app** | Show selected modifier names under each line item (e.g. "Oat . Grande . Vanilla"). No price display. Derive display string from `modifiers.expand((m) => m.options).map((o) => o.name).join(' . ')`. |
| **menu_board_app** | No changes. |

## Shared UI (`very_yummy_coffee_ui`)

Both widgets accept primitive parameters only (no domain types like `SelectionMode` — use `bool isMultiSelect` instead).

- **`ModifierGroupSelector`** — renders a labeled group of chips/buttons; supports single/multi selection via `bool isMultiSelect`; shows `+$X.XX` on options with price deltas; highlights selected options; fires `onSelectionChanged` callback with selected option indices.
- **`ModifierSummaryChips`** — compact read-only row of selected modifier names for cart/order/KDS views. Accepts `List<String> labels`.

## Breaking Change Impact

Removing `LineItem.options` (String) and replacing with `List<SelectedModifier> modifiers` is a wide-reaching change affecting ~23 files:

- `LineItem` model + generated mapper (`order_repository`)
- `OrderRepository.addItemToCurrentOrder()` signature (currently takes `String options`)
- `ServerState.handleAction('addItemToOrder')` reads `payload['options']`
- Mobile + Kiosk `ItemDetailBloc._onAddToCartRequested` (builds options string)
- POS `MenuBloc._onItemAdded` (sends `options: ''`)
- Both cart views (mobile + kiosk) display `item.options`
- 15+ test files constructing `LineItem(options: ...)`

Since this is a monorepo with an in-memory server, this is done as a single atomic change. No migration needed — server restart clears all state.

## Open Questions

- Exact modifier groups and options for the expanded menu (depends on #29 landing first or concurrently).
- Should modifier groups be ordered/sorted in UI? (Default: follow fixture array order.)
- Should `ModifierGroupType` affect UI rendering, or is `selectionMode` the only behavioral differentiator? (Default: type is semantic/KDS only; selectionMode drives behavior.)
- Should `ModifierGroup` have `int? maxSelections` for multi-select groups? (Default: no max for now — follow-up if needed.)

## Deviations from Issue #30

The following decisions differ from the original issue specification:

1. **No `MenuItem.modifierGroupIds`** — category-level scoping only via `ModifierGroup.appliesToGroupIds`.
2. **SelectedModifier is one-per-group** with nested `List<SelectedOption>`, not the issue's `List<String> optionIds`. Each option carries its own name and priceDelta for full denormalization.
3. **No server-side modifier validation** — client-side only. No `itemId` in payload.
4. **Cart item editing scoped out** — delete and re-add for now.
