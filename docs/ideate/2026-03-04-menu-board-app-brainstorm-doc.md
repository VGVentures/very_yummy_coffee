---
date: 2026-03-04
topic: menu-board-app
---

# Digital Menu Board App

## What We're Building

A new Flutter macOS/desktop application (`applications/menu_board_app`) that displays the coffee shop menu on a 1920×1080 landscape screen — the in-store digital menu board customers see when ordering. The board is read-only; it displays live menu data from the WebSocket backend and requires no user interaction.

The design (from `design.pen`, frame `eTi3R`) shows a three-panel layout:
- **Header bar**: "Very Yummy Coffee" branding + connection status dot
- **Left panel**: A featured item with circular hero image, name, description, and price
- **Center**: Two columns of menu categories and their items with prices
- **Right panel**: A second featured item in the same style

Data comes from `MenuRepository` over WebSocket — item availability and prices update in real-time whenever a barista changes them on the POS app.

## Why This Approach

Straightforward replication of the KDS/POS app pattern. No novel architecture is needed:
- Single screen app (no meaningful routing decisions beyond the connecting → display redirect)
- `MenuDisplayBloc` subscribes to `MenuRepository.getMenuGroupsAndItems()` for live data
- Featured items are static (first available item from two pre-selected categories)
- macOS desktop target matches the landscape display environment and is easiest to develop/test locally

## Key Decisions

- **Static featured items**: The two flanking featured-item panels always show the first available item from pre-designated categories (e.g. first "Drinks" item left, first "Food" item right). No timer/animation complexity. If an item becomes unavailable, it falls back to the next available item in that category.
- **macOS desktop platform**: App runs as a native Flutter macOS app, keeping it consistent with how the monorepo apps are structured. No web/TV-specific deployment complexity.
- **Single feature, single route**: One `menu_display` feature folder; the router redirects to `/menu-display` once connected and stays there. No other screens needed.
- **Shared `AppTopBar`**: Reuse the existing `AppTopBar` shared widget for the header (connection dot, title) to stay consistent with KDS/POS.
- **`MenuRepository` only**: No `OrderRepository` dependency — the board only needs menu data.
- **Unavailable items hidden**: Items marked as `available: false` are filtered out from the menu columns and featured panels (cleaner than showing them struck-through).

## App Structure

```
applications/menu_board_app/
├── lib/
│   ├── main.dart                        # Init ApiClient, WsRpcClient, repos; set initial window size
│   ├── app/
│   │   ├── app.dart
│   │   ├── bloc/                        # AppBloc (connection state)
│   │   ├── app_router/app_router.dart   # GoRouter: connecting → /menu-display
│   │   └── view/                        # App widget, ConnectingPage
│   └── menu_display/
│       ├── menu_display.dart
│       ├── bloc/                        # MenuDisplayBloc + events + state
│       └── view/
│           ├── menu_display_page.dart   # BlocProvider + MenuDisplayBloc
│           ├── menu_display_view.dart   # Three-panel layout
│           └── widgets/
│               ├── featured_item_panel.dart
│               └── menu_column.dart
├── pubspec.yaml
├── analysis_options.yaml
└── .gitignore
```

## Key Dependencies

```yaml
dependencies:
  api_client:               # WsRpcClient, ApiClient
  connection_repository:    # AppBloc connection state
  menu_repository:          # Live menu data
  very_yummy_coffee_ui:     # AppTopBar, design tokens, CoffeeTheme
  flutter_bloc: ^9.1.1
  go_router: ^14.6.2
  dart_mappable: ^4.6.1
```

## Data Flow

```
WsRpcClient ──► MenuRepository.getMenuGroupsAndItems()
                      │
                      ▼
              MenuDisplayBloc
              (emit.forEach stream)
                      │
                      ▼
           MenuDisplayView
           ├── AppTopBar (connection status)
           ├── FeaturedItemPanel (left: first item from category A)
           ├── MenuColumn × N (center: all groups + their available items)
           └── FeaturedItemPanel (right: first item from category B)
```

## Resolved Decisions

- **Featured item source**: Use first group (index 0) for the left panel and last group (index N-1) for the right panel, taking the first available item from each. No hardcoded category names — derived purely from API order.
- **Window management**: No additional dependency (e.g. `window_manager`). macOS window size is set via `macos/Runner/AppDelegate.swift` or initial window config in `main.dart`. The physical display's kiosk configuration handles fullscreen. YAGNI.
