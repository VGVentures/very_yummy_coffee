import 'package:api_client/api_client.dart';
import 'package:connection_repository/connection_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_repository/menu_repository.dart';
import 'package:order_repository/order_repository.dart';
import 'package:very_yummy_coffee_kiosk_app/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final apiClient = ApiClient(
    host: 'localhost',
    port: 8080,
    secure: false,
    apiKey: '',
  );
  final wsRpcClient = WsRpcClient.fromApiClient(apiClient);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => ConnectionRepository(wsRpcClient: wsRpcClient),
        ),
        RepositoryProvider(
          create: (_) => MenuRepository(wsRpcClient: wsRpcClient),
        ),
        RepositoryProvider(
          create: (_) => OrderRepository(wsRpcClient: wsRpcClient),
        ),
      ],
      child: const App(),
    ),
  );
}
