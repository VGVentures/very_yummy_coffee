import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_yummy_coffee_voice_order_app/decisions/decisions.dart';
import 'package:very_yummy_coffee_voice_order_app/sample/sample_order.dart';
import 'package:very_yummy_coffee_voice_order_app/speech/speech.dart';
import 'package:very_yummy_coffee_voice_order_app/voice_order/bloc/voice_order_bloc.dart';
import 'package:very_yummy_coffee_voice_order_app/voice_order/view/voice_order_view.dart';

/// What powers the order screen.
class VoiceOrderSource extends Equatable {
  /// Live microphone, transcribed and understood by OpenAI.
  const VoiceOrderSource.openAi(String this.apiKey);

  /// The recorded sample order. No microphone, key or network.
  const VoiceOrderSource.sample() : apiKey = null;

  final String? apiKey;

  bool get isSample => apiKey == null;

  @override
  List<Object?> get props => [apiKey];
}

class VoiceOrderPage extends StatelessWidget {
  const VoiceOrderPage({required this.source, this.onExit, super.key});

  final VoiceOrderSource source;

  /// Returns to the setup screen. Null hides the control.
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    final apiKey = source.apiKey;
    return BlocProvider(
      create: (_) => apiKey == null
          ? VoiceOrderBloc(
              transcriber: const SampleTranscriber(),
              decisionClient: const SampleDecisionClient(),
            )
          : VoiceOrderBloc(
              transcriber: OpenAiRealtimeTranscriber(apiKey: apiKey),
              decisionClient: OpenAiDecisionClient(apiKey: apiKey),
            ),
      child: VoiceOrderView(isSample: source.isSample, onExit: onExit),
    );
  }
}
