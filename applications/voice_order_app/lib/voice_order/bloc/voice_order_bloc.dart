import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:very_yummy_coffee_voice_order_app/decisions/decisions.dart';
import 'package:very_yummy_coffee_voice_order_app/menu/menu.dart';
import 'package:very_yummy_coffee_voice_order_app/speech/speech.dart';

part 'voice_order_event.dart';
part 'voice_order_state.dart';

/// Keeps the on-screen order in step with what the customer is saying.
///
/// Every transcript change asks the [DecisionClient] for the whole order
/// again. At most [maxConcurrentDecisions] requests run at once; while they
/// are busy only the newest transcript is kept, so the screen never falls
/// behind by more than one request.
class VoiceOrderBloc extends Bloc<VoiceOrderEvent, VoiceOrderState> {
  VoiceOrderBloc({
    required SpeechTranscriber transcriber,
    required DecisionClient decisionClient,
    this.maxConcurrentDecisions = 2,
  }) : _transcriber = transcriber,
       _decisionClient = decisionClient,
       super(const VoiceOrderState()) {
    on<VoiceOrderMicToggled>(_onMicToggled, transformer: sequential());
    on<VoiceOrderReset>(_onReset, transformer: sequential());
    on<VoiceOrderTranscriptionEnded>(_onTranscriptionEnded);
    on<VoiceOrderTranscriptionFailed>(_onTranscriptionFailed);
    on<VoiceOrderTranscriptUpdated>(
      _onTranscriptUpdated,
      transformer: concurrent(),
    );
  }

  final int maxConcurrentDecisions;
  final SpeechTranscriber _transcriber;
  final DecisionClient _decisionClient;

  // Cancelled in _stopListening, which close() calls.
  // ignore: cancel_subscriptions
  StreamSubscription<String>? _transcriptSubscription;

  /// The newest transcript that no decision request has picked up yet.
  String? _pendingTranscript;
  var _decisionsInFlight = 0;

  /// Request numbers, so a slow reply can never overwrite a newer one.
  var _lastRequested = 0;
  var _lastApplied = 0;

  Future<void> _onMicToggled(
    VoiceOrderMicToggled event,
    Emitter<VoiceOrderState> emit,
  ) async {
    if (state.status != VoiceOrderStatus.idle) {
      await _stopListening();
      emit(state.copyWith(status: VoiceOrderStatus.idle));
      return;
    }

    emit(
      state.copyWith(
        status: VoiceOrderStatus.connecting,
        errorMessage: () => null,
      ),
    );
    // A new session carries on from what was already said.
    final spokenBefore = state.transcript;
    _transcriptSubscription = _transcriber.listen().listen(
      (sessionTranscript) => add(
        VoiceOrderTranscriptUpdated(
          [
            spokenBefore,
            sessionTranscript,
          ].where((part) => part.isNotEmpty).join(' '),
        ),
      ),
      onError: (Object error) => add(
        VoiceOrderTranscriptionFailed(
          error is TranscriptionException ? error.message : '$error',
        ),
      ),
      onDone: () => add(const VoiceOrderTranscriptionEnded()),
    );
  }

  Future<void> _onReset(
    VoiceOrderReset event,
    Emitter<VoiceOrderState> emit,
  ) async {
    await _stopListening();
    // Discard replies to requests made before the reset.
    _pendingTranscript = null;
    _lastApplied = ++_lastRequested;
    emit(const VoiceOrderState());
  }

  Future<void> _onTranscriptionEnded(
    VoiceOrderTranscriptionEnded event,
    Emitter<VoiceOrderState> emit,
  ) async {
    await _stopListening();
    emit(state.copyWith(status: VoiceOrderStatus.idle));
  }

  Future<void> _onTranscriptionFailed(
    VoiceOrderTranscriptionFailed event,
    Emitter<VoiceOrderState> emit,
  ) async {
    await _stopListening();
    emit(
      state.copyWith(
        status: VoiceOrderStatus.idle,
        errorMessage: () => event.message,
      ),
    );
  }

  Future<void> _onTranscriptUpdated(
    VoiceOrderTranscriptUpdated event,
    Emitter<VoiceOrderState> emit,
  ) async {
    if (_transcriptSubscription == null) return;

    emit(
      state.copyWith(
        // The first update of a session means the microphone is live.
        status: VoiceOrderStatus.listening,
        transcript: event.transcript,
      ),
    );
    if (event.transcript.trim().isEmpty) return;

    _pendingTranscript = event.transcript;
    if (_decisionsInFlight >= maxConcurrentDecisions) return;

    while (_pendingTranscript != null) {
      final transcript = _pendingTranscript!;
      _pendingTranscript = null;
      final request = ++_lastRequested;
      final stopwatch = Stopwatch()..start();
      _decisionsInFlight++;
      try {
        final drinks = await _decisionClient.decideOrder(transcript);
        if (request > _lastApplied) {
          _lastApplied = request;
          emit(
            state.copyWith(
              drinks: drinks,
              decidedTranscript: transcript,
              latency: stopwatch.elapsed,
              errorMessage: () => null,
            ),
          );
        }
      } on DecisionException catch (error) {
        if (request > _lastApplied) {
          emit(state.copyWith(errorMessage: () => error.message));
        }
      } finally {
        _decisionsInFlight--;
      }
    }
  }

  Future<void> _stopListening() async {
    final subscription = _transcriptSubscription;
    _transcriptSubscription = null;
    await subscription?.cancel();
  }

  @override
  Future<void> close() async {
    await _stopListening();
    return super.close();
  }
}
