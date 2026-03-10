# Menu Repository

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A repository managing the menu domain for Very Yummy Coffee.

## Overview

Provides reactive streams of menu data with automatic WebSocket subscription management:

- **`getMenuGroups()`** — stream of all menu groups
- **`getMenuItems(groupId)`** — stream of items filtered by group
- **`getMenuGroupsAndItems()`** — single ref-counted stream of groups and items together

Uses a lazy subscription pattern: the first subscriber triggers an HTTP fetch for initial state plus a WebSocket subscription for live updates. The last subscriber automatically unsubscribes from the WebSocket topic. Built with `rxdart` (`BehaviorSubject` for replay, `doOnCancel` for ref-counting).

## Testing

```sh
flutter test
```
