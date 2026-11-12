import 'package:very_yummy_coffee_voice_order_app/menu/menu.dart';

/// Turns everything the customer has said so far into the current order.
///
/// Implementations are stateless: each call gets the whole transcript, so
/// corrections ("actually, make that one iced") need no special handling.
// A single-method interface keeps the bloc independent of OpenAI.
// ignore: one_member_abstracts
abstract interface class DecisionClient {
  Future<List<DrinkOrder>> decideOrder(String transcript);
}

/// Thrown when the decision service rejects a request or replies with
/// something that is not a decision.
class DecisionException implements Exception {
  const DecisionException(this.message);

  final String message;

  @override
  String toString() => 'DecisionException: $message';
}
