import 'dart:async';
import 'dart:convert';

import 'package:very_yummy_coffee_voice_order_app/speech/audio_source.dart';
import 'package:very_yummy_coffee_voice_order_app/speech/speech_transcriber.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Opens a WebSocket to [uri], offering [protocols] as subprotocols.
typedef WebSocketConnector =
    WebSocketChannel Function(Uri uri, {Iterable<String>? protocols});

/// Live speech-to-text over an OpenAI Realtime transcription session.
///
/// Microphone audio is streamed up a WebSocket and transcript deltas stream
/// back while the customer is still talking.
class OpenAiRealtimeTranscriber implements SpeechTranscriber {
  OpenAiRealtimeTranscriber({
    required String apiKey,
    AudioSource? audioSource,
    WebSocketConnector? connect,
    this.model = defaultModel,
    this.language = 'en',
    this.delay = 'minimal',
  }) : _apiKey = apiKey,
       _audioSource = audioSource ?? MicrophoneAudioSource(),
       _connect = connect ?? WebSocketChannel.connect;

  /// OpenAI's streaming transcription model. It emits text continuously and
  /// does not wait for the speaker to pause.
  static const String defaultModel = 'gpt-realtime-whisper';

  static final Uri _uri = Uri.parse(
    'wss://api.openai.com/v1/realtime?intent=transcription',
  );

  final String model;
  final String language;

  /// How long the model waits before emitting text: `minimal`, `low`,
  /// `medium`, `high` or `xhigh`. Lower is faster and less accurate.
  final String delay;

  final String _apiKey;
  final AudioSource _audioSource;
  final WebSocketConnector _connect;

  @override
  Stream<String> listen() {
    late final StreamController<String> controller;
    WebSocketChannel? channel;
    StreamSubscription<Object?>? socketSubscription;
    StreamSubscription<Object?>? audioSubscription;
    var audioStarted = false;
    final transcript = _Transcript();

    Future<void> stop() async {
      await audioSubscription?.cancel();
      if (audioStarted) await _audioSource.stop();
      await socketSubscription?.cancel();
      // Not awaited: closing a socket that never opened may never finish.
      unawaited(channel?.sink.close().catchError((Object _) {}));
    }

    void fail(Object error) {
      if (controller.isClosed) return;
      controller.addError(
        error is TranscriptionException
            ? error
            : TranscriptionException('Live transcription failed: $error'),
      );
    }

    Future<void> start() async {
      try {
        // Browsers cannot set an Authorization header on a WebSocket, so
        // the key travels as a subprotocol, as in OpenAI's own SDK.
        final socket = channel = _connect(
          _uri,
          protocols: ['realtime', 'openai-insecure-api-key.$_apiKey'],
        );
        await socket.ready;
        socket.sink.add(jsonEncode(_sessionUpdate()));

        socketSubscription = socket.stream.listen(
          (message) {
            if (controller.isClosed) return;
            final event = _decode(message);
            if (event == null) return;
            if (event['type'] == 'error') {
              fail(TranscriptionException(_errorMessage(event)));
            } else if (transcript.apply(event)) {
              controller.add(transcript.text);
            }
          },
          onError: fail,
          onDone: () {
            fail(
              TranscriptionException(
                'OpenAI closed the transcription connection'
                '${socket.closeReason == null ? '' : ': '
                          '${socket.closeReason}'}.',
              ),
            );
          },
        );

        final audio = await _audioSource.start();
        audioStarted = true;
        audioSubscription = audio.listen((bytes) {
          socket.sink.add(
            jsonEncode({
              'type': 'input_audio_buffer.append',
              'audio': base64Encode(bytes),
            }),
          );
        }, onError: fail);

        if (!controller.isClosed) controller.add('');
      } on WebSocketChannelException {
        fail(
          const TranscriptionException(
            'Could not connect to OpenAI for live transcription. Check the '
            'API key and your network.',
          ),
        );
      } on Object catch (error) {
        fail(error);
      }
    }

    controller = StreamController<String>(onListen: start, onCancel: stop);
    return controller.stream;
  }

  Map<String, Object?> _sessionUpdate() {
    return {
      'type': 'session.update',
      'session': {
        'type': 'transcription',
        'audio': {
          'input': {
            'format': {'type': 'audio/pcm', 'rate': _audioSource.sampleRate},
            'transcription': {
              'model': model,
              'language': language,
              'delay': delay,
            },
            // The streaming model transcribes continuously; it has no
            // turn detection.
            'turn_detection': null,
          },
        },
      },
    };
  }

  Map<String, Object?>? _decode(Object? message) {
    if (message is! String) return null;
    try {
      final decoded = jsonDecode(message);
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  String _errorMessage(Map<String, Object?> event) {
    if (event case {'error': {'message': final String message}}) {
      return 'OpenAI transcription error: $message';
    }
    return 'OpenAI reported a transcription error.';
  }
}

/// Assembles the session transcript from Realtime transcription events.
class _Transcript {
  /// Text per conversation item, in the order the items first appeared.
  final _items = <String, String>{};

  String get text {
    return _items.values
        .map((text) => text.trim())
        .where((text) => text.isNotEmpty)
        .join(' ');
  }

  /// Returns whether [event] changed the transcript.
  bool apply(Map<String, Object?> event) {
    final itemId = event['item_id'];
    if (itemId is! String) return false;

    switch (event['type']) {
      case 'conversation.item.input_audio_transcription.delta':
        final delta = event['delta'];
        if (delta is! String || delta.isEmpty) return false;
        _items[itemId] = (_items[itemId] ?? '') + delta;
        return true;
      case 'conversation.item.input_audio_transcription.completed':
        final completed = event['transcript'];
        if (completed is! String || completed == _items[itemId]) return false;
        _items[itemId] = completed;
        return true;
      default:
        return false;
    }
  }
}
