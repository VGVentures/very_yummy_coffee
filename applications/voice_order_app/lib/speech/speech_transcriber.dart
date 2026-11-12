/// Live speech-to-text.
// A single-method interface keeps the bloc independent of OpenAI.
// ignore: one_member_abstracts
abstract interface class SpeechTranscriber {
  /// Starts listening when the returned stream is listened to and stops when
  /// the subscription is cancelled.
  ///
  /// The stream emits an empty string once the session is live, then the
  /// whole transcript of the session so far each time it changes.
  Stream<String> listen();
}

/// Thrown when live transcription cannot start or stops unexpectedly.
class TranscriptionException implements Exception {
  const TranscriptionException(this.message);

  final String message;

  @override
  String toString() => 'TranscriptionException: $message';
}
