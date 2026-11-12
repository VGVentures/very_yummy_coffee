import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:very_yummy_coffee_voice_order_app/decisions/decision_client.dart';
import 'package:very_yummy_coffee_voice_order_app/decisions/order_questions.dart';
import 'package:very_yummy_coffee_voice_order_app/menu/menu.dart';

/// Reads the order out of a transcript with OpenAI's Decisions API
/// (`POST /v1/decisions`).
class OpenAiDecisionClient implements DecisionClient {
  OpenAiDecisionClient({
    required String apiKey,
    http.Client? httpClient,
    this.model = defaultModel,
    Uri? endpoint,
  }) : _apiKey = apiKey,
       _httpClient = httpClient ?? http.Client(),
       _endpoint = endpoint ?? Uri.parse('https://api.openai.com/v1/decisions');

  /// The only model the Decisions API supports today.
  static const String defaultModel = 'gpt-6-luna';

  final String model;
  final String _apiKey;
  final http.Client _httpClient;
  final Uri _endpoint;

  /// Built once: the questions never change, so the instructions and
  /// questions stay a stable prefix for OpenAI's prompt cache.
  static final List<Map<String, Object?>> _questions = OrderQuestions.build();

  @override
  Future<List<DrinkOrder>> decideOrder(String transcript) async {
    final http.Response response;
    try {
      response = await _httpClient.post(
        _endpoint,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'prompt_cache_key': 'very-yummy-coffee-voice-order',
          'input': [
            {'role': 'developer', 'content': OrderQuestions.instructions},
            {'role': 'user', 'content': transcript},
          ],
          'questions': _questions,
        }),
      );
    } on http.ClientException catch (error) {
      throw DecisionException('Could not reach OpenAI: ${error.message}');
    }

    final Object? body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw DecisionException(
        'OpenAI replied with status ${response.statusCode} and no JSON.',
      );
    }

    if (response.statusCode != 200) {
      throw DecisionException(_errorMessage(body, response.statusCode));
    }
    if (body is! Map || body['answers'] is! List) {
      throw const DecisionException('OpenAI replied without any answers.');
    }
    return OrderQuestions.parse(body['answers'] as List<Object?>);
  }

  String _errorMessage(Object? body, int statusCode) {
    if (body case {'error': {'message': final String message}}) {
      return 'OpenAI ($statusCode): $message';
    }
    return 'OpenAI replied with status $statusCode.';
  }
}
