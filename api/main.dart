import 'dart:developer';
import 'dart:io';

import 'package:api/src/server_state.dart';
import 'package:dart_frog/dart_frog.dart';

Future<void> init(InternetAddress ip, int port) async {
  serverState.loadMenu();
  log('[server] initialized, menu loaded');
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serve(handler, ip, port);
}
