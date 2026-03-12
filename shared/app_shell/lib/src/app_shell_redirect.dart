import 'package:app_shell/src/app_shell_routes.dart';
import 'package:app_shell/src/bloc/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Pure redirect logic for testing. [path] is the current route path.
String? redirectLogic(
  AppStatus status,
  String path, {
  required String connectedHomePath,
  List<String> allowedWhenDisconnected = const [],
}) {
  final isConnected = status == AppStatus.connected;
  final onConnecting = path == AppShellRoutes.connecting;
  final isAllowedWhenDisconnected = allowedWhenDisconnected.any(path.contains);

  if (!isConnected && !onConnecting && !isAllowedWhenDisconnected) {
    return AppShellRoutes.connecting;
  }
  if (isConnected && onConnecting) {
    return connectedHomePath;
  }
  return null;
}

/// Returns the redirect path for the app shell based on connection status
/// and current route.
///
/// [AppBloc] must be provided above the GoRouter in the widget tree so
/// [context.read<AppBloc>()] succeeds when the redirect runs.
///
/// Logic:
/// - If not connected (including [AppStatus.initial]) and current path is not
///   [AppShellRoutes.connecting] and path is not in [allowedWhenDisconnected]
///   (current path contains any of the substrings) → return connecting path.
/// - If connected and current path is connecting → return [connectedHomePath].
/// - Otherwise → return null.
String? redirect(
  BuildContext context,
  GoRouterState state, {
  required String connectedHomePath,
  List<String> allowedWhenDisconnected = const [],
}) {
  final status = context.read<AppBloc>().state.status;
  return redirectLogic(
    status,
    state.uri.path,
    connectedHomePath: connectedHomePath,
    allowedWhenDisconnected: allowedWhenDisconnected,
  );
}
