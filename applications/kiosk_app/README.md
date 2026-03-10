# Very Yummy Coffee — Kiosk App

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

An in-store self-service kiosk for Very Yummy Coffee. Designed for landscape tablet displays (1366x1024) where customers can place orders independently.

## Overview

The kiosk app provides a touch-friendly ordering flow optimized for unattended use:

- Splash screen with a "Start Order" call to action
- Browse menu groups and items
- View item details and add to cart
- Review cart, adjust quantities, and proceed to checkout
- Order confirmation screen with auto-reset back to the splash

The app connects to the backend via WebSocket for real-time menu availability and order submission. It automatically redirects to a connecting screen if the connection drops (except on the order complete screen).

## Running

```sh
flutter run
```

The app targets landscape orientation. Run on a tablet simulator or physical device for the best experience. The backend (`api/`) must be running locally on port 8080.

## Testing

```sh
flutter test
```
