# Connection Repository

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A repository managing the WebSocket connection state for Very Yummy Coffee.

## Overview

Wraps the `ApiClient` connection lifecycle and exposes a stream of connection status. Used by `AppBloc` in each application to determine whether the app is connected to the backend, enabling UI states like connecting screens and automatic reconnection handling.

## Testing

```sh
dart test
```
