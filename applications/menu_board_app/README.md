# Very Yummy Coffee — Menu Board App

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A digital menu board display for Very Yummy Coffee. Designed for large screens or TVs mounted in-store.

## Overview

The menu board app displays the full menu with real-time updates:

- Shows all menu groups and items with prices
- Reflects stock availability changes in real time (items marked out-of-stock are visually indicated)
- Includes an order status panel showing active order progress
- Connects via WebSocket for live updates without manual refresh

## Running

```sh
flutter run
```

The backend (`api/`) must be running locally on port 8080.

## Testing

```sh
flutter test
```
