part of 'voice_order_bloc.dart';

sealed class VoiceOrderEvent extends Equatable {
  const VoiceOrderEvent();

  @override
  List<Object?> get props => [];
}

/// The customer tapped the microphone to start or stop listening.
final class VoiceOrderMicToggled extends VoiceOrderEvent {
  const VoiceOrderMicToggled();
}

/// The customer asked to clear the order and start again.
final class VoiceOrderReset extends VoiceOrderEvent {
  const VoiceOrderReset();
}

/// The transcript of the whole order so far changed.
final class VoiceOrderTranscriptUpdated extends VoiceOrderEvent {
  const VoiceOrderTranscriptUpdated(this.transcript);

  final String transcript;

  @override
  List<Object?> get props => [transcript];
}

/// The transcription session ended by itself.
final class VoiceOrderTranscriptionEnded extends VoiceOrderEvent {
  const VoiceOrderTranscriptionEnded();
}

/// Live transcription failed or stopped unexpectedly.
final class VoiceOrderTranscriptionFailed extends VoiceOrderEvent {
  const VoiceOrderTranscriptionFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
