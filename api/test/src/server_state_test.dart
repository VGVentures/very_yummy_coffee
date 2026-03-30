import 'dart:async';

import 'package:api/src/server_state.dart';
import 'package:test/test.dart';

void main() {
  group('ServerState', () {
    late ServerState state;

    setUp(() {
      state = ServerState();
    });

    group('handleAction updateNameOnOrder', () {
      setUp(() {
        state.handleAction('createOrder', {'id': 'order-1'});
      });

      test('sets customerName on a pending order', () {
        state.handleAction('updateNameOnOrder', {
          'orderId': 'order-1',
          'customerName': 'Marcus',
        });

        final snapshot = state.snapshotForTopic('order:order-1');
        expect(snapshot['customerName'], 'Marcus');
      });

      test('clears customerName when null is sent', () {
        state
          ..handleAction('updateNameOnOrder', {
            'orderId': 'order-1',
            'customerName': 'Marcus',
          })
          ..handleAction('updateNameOnOrder', {
            'orderId': 'order-1',
            'customerName': null,
          });

        final snapshot = state.snapshotForTopic('order:order-1');
        expect(snapshot['customerName'], isNull);
      });

      test('clears customerName when empty string is sent', () {
        state
          ..handleAction('updateNameOnOrder', {
            'orderId': 'order-1',
            'customerName': 'Marcus',
          })
          ..handleAction('updateNameOnOrder', {
            'orderId': 'order-1',
            'customerName': '',
          });

        final snapshot = state.snapshotForTopic('order:order-1');
        expect(snapshot['customerName'], isNull);
      });

      test('rejects name update on submitted order', () {
        state
          ..handleAction('submitOrder', {'orderId': 'order-1'})
          ..handleAction('updateNameOnOrder', {
            'orderId': 'order-1',
            'customerName': 'Marcus',
          });

        final snapshot = state.snapshotForTopic('order:order-1');
        expect(snapshot['customerName'], isNull);
      });

      test('rejects name update on completed order', () {
        state
          ..handleAction('submitOrder', {'orderId': 'order-1'})
          ..handleAction('startOrder', {'orderId': 'order-1'})
          ..handleAction('markOrderReady', {'orderId': 'order-1'})
          ..handleAction('completeOrder', {'orderId': 'order-1'})
          ..handleAction('updateNameOnOrder', {
            'orderId': 'order-1',
            'customerName': 'Marcus',
          });

        final snapshot = state.snapshotForTopic('order:order-1');
        expect(snapshot['customerName'], isNull);
      });

      test('rejects name update on cancelled order', () {
        state
          ..handleAction('cancelOrder', {'orderId': 'order-1'})
          ..handleAction('updateNameOnOrder', {
            'orderId': 'order-1',
            'customerName': 'Marcus',
          });

        final snapshot = state.snapshotForTopic('order:order-1');
        expect(snapshot['customerName'], isNull);
      });

      test('broadcasts to orders and order:<id> subscribers', () {
        final ordersSink = _TestSink();
        final orderIdSink = _TestSink();

        state
          ..subscribe('orders', ordersSink)
          ..subscribe('order:order-1', orderIdSink)
          ..handleAction('updateNameOnOrder', {
            'orderId': 'order-1',
            'customerName': 'Marcus',
          });

        expect(ordersSink.messages, hasLength(1));
        expect(orderIdSink.messages, hasLength(1));
      });

      test('createOrder initializes customerName as null', () {
        final snapshot = state.snapshotForTopic('order:order-1');
        expect(snapshot['customerName'], isNull);
      });
    });

    group('handleAction updateMenuItemAvailability', () {
      test('preserves imageUrl when toggling availability', () {
        state.loadMenu();
        const itemId = '101';
        final before = state.snapshotForTopic('menu');
        final itemsBefore = before['items']! as List<dynamic>;
        final mapBefore = itemsBefore.cast<Map<String, dynamic>>().firstWhere(
          (e) => e['id'] == itemId,
        );
        final imageUrl = mapBefore['imageUrl'] as String?;
        expect(imageUrl, isNotNull);

        state.handleAction('updateMenuItemAvailability', {
          'itemId': itemId,
          'available': false,
        });

        final after = state.snapshotForTopic('menu');
        final itemsAfter = after['items']! as List<dynamic>;
        final mapAfter = itemsAfter.cast<Map<String, dynamic>>().firstWhere(
          (e) => e['id'] == itemId,
        );
        expect(mapAfter['available'], isFalse);
        expect(mapAfter['imageUrl'], imageUrl);
      });
    });
  });
}

class _TestSink implements StreamSink<dynamic> {
  final List<dynamic> messages = [];

  @override
  void add(dynamic event) => messages.add(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<dynamic> addStream(Stream<dynamic> stream) => Future.value();

  @override
  Future<dynamic> close() => Future.value();

  @override
  Future<dynamic> get done => Future.value();
}
