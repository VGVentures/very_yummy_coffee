---
date: 2026-03-05
topic: kiosk-app
---

# Kiosk App

## What We're Building

A landscape tablet kiosk app (`applications/kiosk_app`) for in-store self-service ordering. The app mirrors the mobile_app's ordering flow — Home → Menu Groups → Menu Items → Item Detail → Cart → Checkout → Order Complete — but with kiosk-optimized layouts designed for a 1366×1024 landscape display with larger touch targets and split-pane screens.

The app targets iPad/tablet and reuses the same backend (Dart Frog server), repositories (`menu_repository`, `order_repository`, `connection_repository`), and shared UI package (`very_yummy_coffee_ui`) as the mobile app.

## Why This Approach

**Copy & Adapt from mobile_app** was chosen over extracting shared blocs into a separate package. Reasons:

- Blocs are thin (20–40 lines each, mostly `emit.forEach` on repository streams) — duplication cost is minimal.
- The kiosk Home screen is fundamentally different (full-screen splash with "Start Order" vs mobile's active-order tracker).
- Several kiosk screens use split-pane layouts that don't exist in mobile — views diverge significantly.
- Keeps both apps fully independent so they can evolve without coordination overhead.
- No risk of accidentally breaking the mobile app.

## Key Decisions

- **Platform**: iPad/tablet (native iOS/Android Flutter app).
- **Architecture**: Mirror mobile_app's feature-per-folder structure with Bloc + GoRouter + l10n + very_good_analysis + bloc_lint.
- **No idle timeout**: Skip auto-reset for now; can be added later.
- **Copy & adapt**: Duplicate mobile_app blocs and adapt views for kiosk layouts rather than extracting shared bloc packages.
- **Shared UI**: Reuse `very_yummy_coffee_ui` design tokens (colors, spacing, radius, typography) and shared widgets (e.g., `BaseButton`, `CustomBackButton`). Add new kiosk-specific widgets to the kiosk app, not the shared package, unless they're truly reusable.
- **Navigation**: Hardcoded `context.go('/path')` strings per CLAUDE.md convention.
- **Connection gating**: `AppBloc` + `/connecting` page, identical to mobile_app. App starts at `/connecting` and redirects to `/home` once WebSocket connects. If connection drops, redirects back to `/connecting`.
- **Orientation**: Lock to landscape in `main.dart` via `SystemChrome.setPreferredOrientations`.
- **Kiosk header**: A kiosk-internal `KioskHeader` widget (inside the kiosk_app, not in `very_yummy_coffee_ui`) shared across Menu Groups, Menu Items, Item Detail, Cart, and Checkout screens. Accepts back button, title, and cart badge slots.

## Screens (from design.pen)

| # | Screen | Route | Layout |
|---|--------|-------|--------|
| 0 | Connecting | `/connecting` | Centered loading indicator (initial route, shown until WS connects) |
| 1 | Home | `/home` | Full-screen BG image, brand name, tagline, "Start Order" pill button |
| 2 | Menu Groups | `/home/menu` | KioskHeader (brand + cart badge), 3 equal category cards in horizontal row |
| 3 | Menu Items | `/home/menu/:groupId` | KioskHeader (back + group title + cart), 2-column grid of item cards |
| 4 | Item Detail | `/home/menu/:groupId/:itemId` | KioskHeader (back + title + cart), split: left (item hero on primary bg), right (size/milk pickers, qty stepper, "Add to Cart") |
| 5 | Cart | `/home/menu/cart` | KioskHeader (back + "My Cart"), split: left (item list with qty steppers + delete), right (order summary panel + checkout button) |
| 6 | Checkout | `/home/menu/cart/checkout` | KioskHeader (back + item count + total), payment section, order summary, "Place Order" bottom bar |
| 7 | Order Complete | `/home/menu/cart/checkout/:orderId` | Split: left (success hero on primary bg + "Back to Menu"), right (status tracker + order details) |

## Feature Structure (per feature)

```
lib/<feature>/
  <feature>.dart          # barrel export
  bloc/
    <feature>_bloc.dart
    <feature>_event.dart
    <feature>_state.dart
  view/
    view.dart             # barrel export
    <feature>_page.dart   # provides bloc, defines routeName + pageBuilder
    <feature>_view.dart   # UI with BlocBuilder
```

## Dependencies (matching mobile_app)

```yaml
dependencies:
  api_client: (local)
  bloc: ^9.0.0
  connection_repository: (local)
  dart_mappable: ^4.6.1
  flutter_bloc: ^9.1.1
  go_router: ^14.6.2
  intl: ^0.20.2
  menu_repository: (local)
  order_repository: (local)
  rxdart: ^0.28.0
  very_yummy_coffee_ui: (local)

dev_dependencies:
  bloc_lint: ^0.3.6
  bloc_test: ^10.0.0
  build_runner: ^2.11.1
  dart_mappable_builder: ^4.6.4
  mocktail: ^1.0.4
  nested: ^1.0.0
  very_good_analysis: ^10.0.0
```

## Open Questions

- Does the kiosk need different menu data (e.g., kiosk-only items) or the same menu as mobile?
- Should "Fake Payment" be the only payment option, or is this a placeholder for real payment integration later?
