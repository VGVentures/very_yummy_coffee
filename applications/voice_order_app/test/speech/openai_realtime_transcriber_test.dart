import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_yummy_coffee_voice_order_app/speech/speech.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _MockWebSocketChannel extends Mock implements WebSocketChannel {}

class _MockWebSocketSink extends Mock implements WebSocketSink {}

class _FakeAudioSource implements AudioSource {
  final controller = StreamController<Uint8List>();
  bool started = false;
  bool stopped = false;
  Exception? startError;

  @override
  int get sampleRate => 24000;

  @override
  Future<Stream<Uint8List>> start() async {
    if (startError case final error?) throw error;
    started = true;
    return controller.stream;
  }

  @override
  Future<void> stop() async => stopped = true;
}

void main() {
  group('OpenAiRealtimeTranscriber', () {
    late _MockWebSocketChannel channel;
    late _MockWebSocketSink sink;
    late StreamController<Object?> serverEvents;
    late _FakeAudioSource audioSource;
    late List<Map<String, Object?>> sent;
    late Uri connectedUri;
    late List<String> connectedProtocols;

    OpenAiRealtimeTranscriber buildTranscriber() {
      return OpenAiRealtimeTranscriber(
        apiKey: 'sk-test',
        audioSource: audioSource,
        connect: (uri, {protocols}) {
          connectedUri = uri;
          connectedProtocols = protocols!.toList();
          return channel;
        },
      );
    }

    void serverSends(Map<String, Object?> event) {
      serverEvents.add(jsonEncode(event));
    }

    setUp(() {
      channel = _MockWebSocketChannel();
      sink = _MockWebSocketSink();
      serverEvents = StreamController<Object?>();
      audioSource = _FakeAudioSource();
      sent = [];

      when(() => channel.ready).thenAnswer((_) async {});
      when(() => channel.sink).thenReturn(sink);
      when(() => channel.stream).thenAnswer((_) => serverEvents.stream);
      when(() => channel.closeReason).thenReturn(null);
      when(() => sink.add(any<dynamic>())).thenAnswer((invocation) {
        final message = invocation.positionalArguments.single as String;
        sent.add(jsonDecode(message) as Map<String, Object?>);
      });
      when(() => sink.close()).thenAnswer((_) async {});
    });

    test('connects with the key as a subprotocol and configures a '
        'transcription session', () async {
      final subscription = buildTranscriber().listen().listen((_) {});
      await pumpEventQueue();

      expect(
        connectedUri,
        Uri.parse('wss://api.openai.com/v1/realtime?intent=transcription'),
      );
      expect(connectedProtocols, [
        'realtime',
        'openai-insecure-api-key.sk-test',
      ]);
      expect(sent.first, {
        'type': 'session.update',
        'session': {
          'type': 'transcription',
          'audio': {
            'input': {
              'format': {'type': 'audio/pcm', 'rate': 24000},
              'transcription': {
                'model': 'gpt-realtime-whisper',
                'language': 'en',
                'delay': 'minimal',
              },
              'turn_detection': null,
            },
          },
        },
      });

      await subscription.cancel();
    });

    test('emits an empty transcript once the microphone is live', () async {
      final transcripts = <String>[];
      final subscription = buildTranscriber().listen().listen(transcripts.add);
      await pumpEventQueue();

      expect(audioSource.started, isTrue);
      expect(transcripts, ['']);

      await subscription.cancel();
    });

    test('sends microphone audio as base64 appends', () async {
      final subscription = buildTranscriber().listen().listen((_) {});
      await pumpEventQueue();

      audioSource.controller.add(Uint8List.fromList([1, 2, 3, 4]));
      await pumpEventQueue();

      expect(sent.last, {
        'type': 'input_audio_buffer.append',
        'audio': base64Encode([1, 2, 3, 4]),
      });

      await subscription.cancel();
    });

    test('builds the transcript from deltas as they arrive', () async {
      final transcripts = <String>[];
      final subscription = buildTranscriber().listen().listen(transcripts.add);
      await pumpEventQueue();

      for (final delta in ['can I', ' get a', ' latte']) {
        serverSends({
          'type': 'conversation.item.input_audio_transcription.delta',
          'item_id': 'item_1',
          'delta': delta,
        });
      }
      await pumpEventQueue();

      expect(transcripts, [
        '',
        'can I',
        'can I get a',
        'can I get a latte',
      ]);

      await subscription.cancel();
    });

    test('replaces an item with its completed transcript and keeps items '
        'in order', () async {
      final transcripts = <String>[];
      final subscription = buildTranscriber().listen().listen(transcripts.add);
      await pumpEventQueue();

      serverSends({
        'type': 'conversation.item.input_audio_transcription.delta',
        'item_id': 'item_1',
        'delta': 'can I get a lot a',
      });
      serverSends({
        'type': 'conversation.item.input_audio_transcription.delta',
        'item_id': 'item_2',
        'delta': 'make it iced',
      });
      serverSends({
        'type': 'conversation.item.input_audio_transcription.completed',
        'item_id': 'item_1',
        'transcript': 'Can I get a latte?',
      });
      await pumpEventQueue();

      expect(transcripts.last, 'Can I get a latte? make it iced');

      await subscription.cancel();
    });

    test('ignores events that do not change the transcript', () async {
      final transcripts = <String>[];
      final subscription = buildTranscriber().listen().listen(transcripts.add);
      await pumpEventQueue();

      serverSends({'type': 'session.updated'});
      serverSends({'type': 'input_audio_buffer.speech_started'});
      serverEvents.add('not json');
      await pumpEventQueue();

      expect(transcripts, ['']);

      await subscription.cancel();
    });

    test('reports an error event from OpenAI', () async {
      final errors = <Object>[];
      final subscription = buildTranscriber().listen().listen(
        (_) {},
        onError: errors.add,
      );
      await pumpEventQueue();

      serverSends({
        'type': 'error',
        'error': {'message': 'Invalid model.'},
      });
      await pumpEventQueue();

      expect(
        errors.single,
        isA<TranscriptionException>().having(
          (error) => error.message,
          'message',
          'OpenAI transcription error: Invalid model.',
        ),
      );

      await subscription.cancel();
    });

    test('reports the connection closing', () async {
      final errors = <Object>[];
      final subscription = buildTranscriber().listen().listen(
        (_) {},
        onError: errors.add,
      );
      await pumpEventQueue();

      await serverEvents.close();
      await pumpEventQueue();

      expect(errors.single, isA<TranscriptionException>());

      await subscription.cancel();
    });

    test('reports the microphone being refused', () async {
      audioSource.startError = const TranscriptionException('denied');
      final errors = <Object>[];
      final subscription = buildTranscriber().listen().listen(
        (_) {},
        onError: errors.add,
      );
      await pumpEventQueue();

      expect(
        errors.single,
        isA<TranscriptionException>().having(
          (error) => error.message,
          'message',
          'denied',
        ),
      );

      await subscription.cancel();
    });

    test('reports a connection that cannot be opened and still shuts '
        'down', () async {
      when(() => channel.ready).thenAnswer(
        (_) async => throw WebSocketChannelException('tunnel failed'),
      );
      // A socket that never opened may never finish closing.
      when(() => sink.close()).thenAnswer((_) => Completer<void>().future);
      final errors = <Object>[];
      final subscription = buildTranscriber().listen().listen(
        (_) {},
        onError: errors.add,
      );
      await pumpEventQueue();

      expect(
        errors.single,
        isA<TranscriptionException>().having(
          (error) => error.message,
          'message',
          startsWith('Could not connect to OpenAI'),
        ),
      );
      expect(audioSource.started, isFalse);
      await subscription.cancel().timeout(const Duration(seconds: 1));
    });

    test('stops the microphone and closes the socket when cancelled', () async {
      final subscription = buildTranscriber().listen().listen((_) {});
      await pumpEventQueue();

      await subscription.cancel();

      expect(audioSource.stopped, isTrue);
      verify(() => sink.close()).called(1);
    });
  });
}
