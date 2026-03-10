# Very Yummy Coffee — Mobile App

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

The customer-facing mobile ordering app for Very Yummy Coffee. Built with Flutter for iOS and Android.

## Overview

The mobile app lets customers browse the menu, build an order, and submit it for preparation. It connects to the backend via WebSocket for real-time order status updates.

Key features:

- Browse menu groups and items
- Add items to a cart and adjust quantities
- Submit orders with a customer name
- Track order status in real time
- Automatic reconnection on connection loss

## Running

```sh
flutter run
```

The backend (`api/`) must be running locally on port 8080.

## Testing

```sh
flutter test
```
