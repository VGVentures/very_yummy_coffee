import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

Response onRequest(RequestContext context, String id) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final fixture = jsonDecode(
    File('fixtures/menu.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  final items = (fixture['items'] as List<dynamic>)
      .where((e) => (e as Map<String, dynamic>)['groupId'] == id)
      .map((e) {
    final map = Map<String, dynamic>.from(e as Map<String, dynamic>)
      ..remove('groupId');
    return MenuItemMapper.fromMap(map);
  }).toList();

  return Response(
    body: jsonEncode(items.map((i) => i.toMap()).toList()),
    headers: {'content-type': 'application/json'},
  );
}
