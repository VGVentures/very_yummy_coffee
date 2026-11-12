import 'package:flutter/material.dart';
import 'package:very_yummy_coffee_ui/very_yummy_coffee_ui.dart';
import 'package:very_yummy_coffee_voice_order_app/setup/setup.dart';
import 'package:very_yummy_coffee_voice_order_app/voice_order/voice_order.dart';

class App extends StatefulWidget {
  const App({this.apiKey = '', super.key});

  /// An OpenAI API key supplied at build time. Empty shows the setup screen.
  final String apiKey;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// How the order screen is powered, or null while on the setup screen.
  VoiceOrderSource? _source;

  @override
  void initState() {
    super.initState();
    if (widget.apiKey.isNotEmpty) {
      _source = VoiceOrderSource.openAi(widget.apiKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final source = _source;
    return MaterialApp(
      title: 'Very Yummy Coffee',
      debugShowCheckedModeBanner: false,
      theme: CoffeeTheme.light,
      home: source == null
          ? SetupView(
              onApiKeySubmitted: (apiKey) => setState(
                () => _source = VoiceOrderSource.openAi(apiKey),
              ),
              onSampleSelected: () => setState(
                () => _source = const VoiceOrderSource.sample(),
              ),
            )
          : VoiceOrderPage(
              // A new source gets a new bloc.
              key: ValueKey(source),
              source: source,
              onExit: widget.apiKey.isEmpty
                  ? () => setState(() => _source = null)
                  : null,
            ),
    );
  }
}
