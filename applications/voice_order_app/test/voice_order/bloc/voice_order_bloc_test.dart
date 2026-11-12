import 'package:flutter_test/flutter_test.dart';
import 'package:very_yummy_coffee_voice_order_app/decisions/decisions.dart';
import 'package:very_yummy_coffee_voice_order_app/menu/menu.dart';
import 'package:very_yummy_coffee_voice_order_app/speech/speech.dart';
import 'package:very_yummy_coffee_voice_order_app/voice_order/bloc/voice_order_bloc.dart';

import '../../helpers/fakes.dart';

void main() {
  group('VoiceOrderBloc', () {
    final latte = DrinkOrder.withDefaults(VoiceMenu.byId('latte')!);
    final mocha = DrinkOrder.withDefaults(VoiceMenu.byId('mocha')!);

    late FakeTranscriber transcriber;
    late FakeDecisionClient decisionClient;

    VoiceOrderBloc buildBloc({int maxConcurrentDecisions = 2}) {
      final bloc = VoiceOrderBloc(
        transcriber: transcriber,
        decisionClient: decisionClient,
        maxConcurrentDecisions: maxConcurrentDecisions,
      );
      addTearDown(bloc.close);
      return bloc;
    }

    /// A bloc that is already listening.
    Future<VoiceOrderBloc> buildListeningBloc({
      int maxConcurrentDecisions = 2,
    }) async {
      final bloc = buildBloc(maxConcurrentDecisions: maxConcurrentDecisions)
        ..add(const VoiceOrderMicToggled());
      await pumpEventQueue();
      transcriber.session.add('');
      await pumpEventQueue();
      return bloc;
    }

    Future<void> say(String transcript) async {
      transcriber.session.add(transcript);
      await pumpEventQueue();
    }

    setUp(() {
      transcriber = FakeTranscriber();
      decisionClient = FakeDecisionClient();
    });

    test('starts idle with an empty order', () {
      expect(buildBloc().state, const VoiceOrderState());
    });

    test('connects, then listens once the session is live', () async {
      final bloc = buildBloc()..add(const VoiceOrderMicToggled());
      await pumpEventQueue();
      expect(bloc.state.status, VoiceOrderStatus.connecting);

      transcriber.session.add('');
      await pumpEventQueue();
      expect(bloc.state.status, VoiceOrderStatus.listening);
      expect(decisionClient.transcripts, isEmpty);
    });

    test('shows the transcript at once and the order when it is '
        'decided', () async {
      final bloc = await buildListeningBloc();

      await say('a latte');
      expect(bloc.state.transcript, 'a latte');
      expect(bloc.state.decidedTranscript, isEmpty);
      expect(bloc.state.drinks, isEmpty);
      expect(decisionClient.transcripts, ['a latte']);

      decisionClient.replies.single.complete([latte]);
      await pumpEventQueue();
      expect(bloc.state.drinks, [latte]);
      expect(bloc.state.decidedTranscript, 'a latte');
      expect(bloc.state.latency, isNotNull);
    });

    test('never lets a slow reply overwrite a newer one', () async {
      final bloc = await buildListeningBloc();

      await say('a mocha');
      await say('a mocha no a latte');
      expect(decisionClient.transcripts, hasLength(2));

      decisionClient.replies[1].complete([latte]);
      await pumpEventQueue();
      decisionClient.replies[0].complete([mocha]);
      await pumpEventQueue();

      expect(bloc.state.drinks, [latte]);
      expect(bloc.state.decidedTranscript, 'a mocha no a latte');
    });

    test('while busy, keeps only the newest transcript for the next '
        'request', () async {
      final bloc = await buildListeningBloc(maxConcurrentDecisions: 1);

      await say('a');
      await say('a latte');
      await say('a latte and a mocha');
      expect(decisionClient.transcripts, ['a']);

      decisionClient.replies[0].complete([]);
      await pumpEventQueue();
      expect(decisionClient.transcripts, ['a', 'a latte and a mocha']);

      decisionClient.replies[1].complete([latte, mocha]);
      await pumpEventQueue();
      expect(bloc.state.drinks, [latte, mocha]);
    });

    test('runs no more requests at once than allowed', () async {
      await buildListeningBloc();

      await say('one');
      await say('one two');
      await say('one two three');

      expect(decisionClient.transcripts, ['one', 'one two']);
    });

    test('reports a failed decision and recovers on the next one', () async {
      final bloc = await buildListeningBloc();

      await say('a latte');
      decisionClient.replies[0].completeError(
        const DecisionException('OpenAI (429): Slow down.'),
      );
      await pumpEventQueue();
      expect(bloc.state.errorMessage, 'OpenAI (429): Slow down.');
      expect(bloc.state.status, VoiceOrderStatus.listening);

      await say('a latte please');
      decisionClient.replies[1].complete([latte]);
      await pumpEventQueue();
      expect(bloc.state.errorMessage, isNull);
      expect(bloc.state.drinks, [latte]);
    });

    test('stops listening and keeps the order when the mic is toggled '
        'off', () async {
      final bloc = await buildListeningBloc();
      await say('a latte');
      decisionClient.replies.single.complete([latte]);
      await pumpEventQueue();

      bloc.add(const VoiceOrderMicToggled());
      await pumpEventQueue();

      expect(transcriber.cancelled, 1);
      expect(bloc.state.status, VoiceOrderStatus.idle);
      expect(bloc.state.drinks, [latte]);
    });

    test('a second session carries on from what was already said', () async {
      final bloc = await buildListeningBloc();
      await say('a latte');
      bloc.add(const VoiceOrderMicToggled());
      await pumpEventQueue();

      bloc.add(const VoiceOrderMicToggled());
      await pumpEventQueue();
      await say('and a mocha');

      expect(bloc.state.transcript, 'a latte and a mocha');
      expect(decisionClient.transcripts.last, 'a latte and a mocha');
    });

    test('reset clears the order and ignores replies still on their '
        'way', () async {
      final bloc = await buildListeningBloc();
      await say('a latte');

      bloc.add(const VoiceOrderReset());
      await pumpEventQueue();
      decisionClient.replies.single.complete([latte]);
      await pumpEventQueue();

      expect(transcriber.cancelled, 1);
      expect(bloc.state, const VoiceOrderState());
    });

    test('goes idle with a message when transcription fails', () async {
      final bloc = await buildListeningBloc();

      transcriber.session.addError(
        const TranscriptionException('Microphone access was denied.'),
      );
      await pumpEventQueue();

      expect(bloc.state.status, VoiceOrderStatus.idle);
      expect(bloc.state.errorMessage, 'Microphone access was denied.');
      expect(transcriber.cancelled, 1);
    });

    test('goes idle when the session ends by itself', () async {
      final bloc = await buildListeningBloc();
      await say('a latte');

      await transcriber.session.close();
      await pumpEventQueue();

      expect(bloc.state.status, VoiceOrderStatus.idle);
      expect(bloc.state.transcript, 'a latte');
    });

    test('totals the price of the drinks', () async {
      final bloc = await buildListeningBloc();
      await say('a latte and a mocha');
      decisionClient.replies.single.complete([latte, mocha]);
      await pumpEventQueue();

      expect(bloc.state.totalCents, latte.priceCents + mocha.priceCents);
    });
  });
}
