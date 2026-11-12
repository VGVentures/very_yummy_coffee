import 'package:flutter/widgets.dart';
import 'package:very_yummy_coffee_voice_order_app/app/app.dart';

void main() {
  // Optional: `--dart-define=OPENAI_API_KEY=sk-...` skips the key prompt.
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  // The value differs per build, so it is passed even when it is empty.
  // ignore: avoid_redundant_argument_values
  runApp(const App(apiKey: apiKey));
}
