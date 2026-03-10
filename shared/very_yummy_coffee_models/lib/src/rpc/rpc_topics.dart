/// Constants for WebSocket RPC topic names.
///
/// Use these instead of raw string literals to get compile-time safety
/// for topic names across client and server code.
abstract final class RpcTopics {
  /// The menu topic — subscribes to menu group and item updates.
  static const menu = 'menu';

  /// The orders topic — subscribes to all order updates.
  static const orders = 'orders';

  /// Returns the topic for a specific order by [id].
  static String order(String id) => 'order:$id';
}
