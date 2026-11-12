import 'dart:typed_data';

import 'package:record/record.dart';
import 'package:very_yummy_coffee_voice_order_app/speech/speech_transcriber.dart';

/// A source of raw mono 16-bit little-endian PCM audio.
abstract interface class AudioSource {
  /// Samples per second of the audio returned by [start].
  int get sampleRate;

  Future<Stream<Uint8List>> start();

  Future<void> stop();
}

/// Captures the device microphone.
class MicrophoneAudioSource implements AudioSource {
  MicrophoneAudioSource({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  /// The rate OpenAI's Realtime API expects for `audio/pcm`.
  @override
  int get sampleRate => 24000;

  @override
  Future<Stream<Uint8List>> start() async {
    if (!await _recorder.hasPermission()) {
      throw const TranscriptionException(
        'Microphone access was denied. Allow it in the browser and try again.',
      );
    }
    return _recorder.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
        echoCancel: true,
        noiseSuppress: true,
      ),
    );
  }

  @override
  Future<void> stop() async {
    await _recorder.stop();
  }
}
