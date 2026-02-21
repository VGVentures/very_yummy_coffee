import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:very_yummy_coffee_models/very_yummy_coffee_models.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final fixture = jsonDecode(
    File('fixtures/menu.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  final items = (fixture['items'] as List<dynamic>)
      .map((e) => MenuItemMapper.fromMap(e as Map<String, dynamic>))
      .toList();

  return Response(
    body: jsonEncode(items.map((i) => i.toMap()).toList()),
    headers: {'content-type': 'application/json'},
  );
}
