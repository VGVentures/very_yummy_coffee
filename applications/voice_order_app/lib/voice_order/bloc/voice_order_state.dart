part of 'voice_order_bloc.dart';

enum VoiceOrderStatus { idle, connecting, listening }

final class VoiceOrderState extends Equatable {
  const VoiceOrderState({
    this.status = VoiceOrderStatus.idle,
    this.transcript = '',
    this.decidedTranscript = '',
    this.drinks = const [],
    this.latency,
    this.errorMessage,
  });

  final VoiceOrderStatus status;

  /// Everything the customer has said for this order.
  final String transcript;

  /// The transcript [drinks] was worked out from. Anything in [transcript]
  /// beyond it has been heard but is not on screen yet.
  final String decidedTranscript;

  final List<DrinkOrder> drinks;

  /// How long the decision behind [drinks] took.
  final Duration? latency;

  final String? errorMessage;

  int get totalCents {
    return drinks.fold(0, (total, drink) => total + drink.priceCents);
  }

  VoiceOrderState copyWith({
    VoiceOrderStatus? status,
    String? transcript,
    String? decidedTranscript,
    List<DrinkOrder>? drinks,
    Duration? latency,
    String? Function()? errorMessage,
  }) {
    return VoiceOrderState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      decidedTranscript: decidedTranscript ?? this.decidedTranscript,
      drinks: drinks ?? this.drinks,
      latency: latency ?? this.latency,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transcript,
    decidedTranscript,
    drinks,
    latency,
    errorMessage,
  ];
}
