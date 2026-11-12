import 'dart:async';

import 'package:very_yummy_coffee_voice_order_app/decisions/decisions.dart';
import 'package:very_yummy_coffee_voice_order_app/menu/menu.dart';
import 'package:very_yummy_coffee_voice_order_app/speech/speech.dart';

/// A transcriber whose transcript is driven by the test.
class FakeTranscriber implements SpeechTranscriber {
  final sessions = <StreamController<String>>[];
  int cancelled = 0;

  /// The session opened by the most recent [listen].
  StreamController<String> get session => sessions.last;

  @override
  Stream<String> listen() {
    final controller = StreamController<String>(onCancel: () => cancelled++);
    sessions.add(controller);
    return controller.stream;
  }
}

/// A decision client whose replies are completed by the test.
class FakeDecisionClient implements DecisionClient {
  final transcripts = <String>[];
  final replies = <Completer<List<DrinkOrder>>>[];

  @override
  Future<List<DrinkOrder>> decideOrder(String transcript) {
    transcripts.add(transcript);
    final reply = Completer<List<DrinkOrder>>();
    replies.add(reply);
    return reply.future;
  }
}
