import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:very_yummy_coffee_voice_order_app/decisions/decisions.dart';
import 'package:very_yummy_coffee_voice_order_app/menu/menu.dart';

void main() {
  group('OpenAiDecisionClient', () {
    const decision = {
      'model': 'gpt-6-luna',
      'answers': [
        {
          'type': 'choice',
          'name': 'drink_1',
          'choice': 'matcha_latte',
          'confidence': 0.98,
          'probabilities': <Object?>[],
        },
        {
          'type': 'choice',
          'name': 'temperature_1',
          'choice': 'iced',
          'confidence': 0.95,
          'probabilities': <Object?>[],
        },
      ],
      'usage': {'input_tokens': 900, 'output_tokens': 0, 'total_tokens': 900},
    };

    test('posts the transcript and questions to /v1/decisions', () async {
      late http.Request sent;
      final client = OpenAiDecisionClient(
        apiKey: 'sk-test',
        httpClient: MockClient((request) async {
          sent = request;
          return http.Response(jsonEncode(decision), 200);
        }),
      );

      await client.decideOrder('an iced matcha please');

      expect(sent.method, 'POST');
      expect(sent.url, Uri.parse('https://api.openai.com/v1/decisions'));
      expect(sent.headers['Authorization'], 'Bearer sk-test');
      expect(sent.headers['Content-Type'], contains('application/json'));

      final body = jsonDecode(sent.body) as Map<String, Object?>;
      expect(body['model'], 'gpt-6-luna');
      expect(body['input'], [
        {'role': 'developer', 'content': OrderQuestions.instructions},
        {'role': 'user', 'content': 'an iced matcha please'},
      ]);
      expect(body['questions'], jsonDecode(jsonEncode(OrderQuestions.build())));
    });

    test('returns the order described by the answers', () async {
      final client = OpenAiDecisionClient(
        apiKey: 'sk-test',
        httpClient: MockClient(
          (_) async => http.Response(jsonEncode(decision), 200),
        ),
      );

      expect(await client.decideOrder('an iced matcha please'), [
        DrinkOrder.withDefaults(
          VoiceMenu.byId('matcha_latte')!,
          temperature: Temperature.iced,
        ),
      ]);
    });

    test("throws OpenAI's own message when the request is rejected", () {
      final client = OpenAiDecisionClient(
        apiKey: 'sk-bad',
        httpClient: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'error': {'message': 'Incorrect API key provided.'},
            }),
            401,
          ),
        ),
      );

      expect(
        client.decideOrder('a latte'),
        throwsA(
          isA<DecisionException>().having(
            (error) => error.message,
            'message',
            'OpenAI (401): Incorrect API key provided.',
          ),
        ),
      );
    });

    test('throws when the reply is not JSON', () {
      final client = OpenAiDecisionClient(
        apiKey: 'sk-test',
        httpClient: MockClient((_) async => http.Response('<html>', 502)),
      );

      expect(client.decideOrder('a latte'), throwsA(isA<DecisionException>()));
    });

    test('throws when the reply has no answers', () {
      final client = OpenAiDecisionClient(
        apiKey: 'sk-test',
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );

      expect(client.decideOrder('a latte'), throwsA(isA<DecisionException>()));
    });

    test('throws when OpenAI cannot be reached', () {
      final client = OpenAiDecisionClient(
        apiKey: 'sk-test',
        httpClient: MockClient(
          (_) async => throw http.ClientException('offline'),
        ),
      );

      expect(client.decideOrder('a latte'), throwsA(isA<DecisionException>()));
    });
  });
}
