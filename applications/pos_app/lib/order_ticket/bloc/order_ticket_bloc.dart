import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';
import 'package:order_repository/order_repository.dart';

part 'order_ticket_bloc.mapper.dart';
part 'order_ticket_event.dart';
part 'order_ticket_state.dart';

class OrderTicketBloc extends Bloc<OrderTicketEvent, OrderTicketState> {
  OrderTicketBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const OrderTicketState()) {
    on<OrderTicketSubscriptionRequested>(_onSubscriptionRequested);
    on<OrderTicketCreateOrderRequested>(_onCreateOrderRequested);
    on<OrderTicketChargeRequested>(_onChargeRequested);
    on<OrderTicketClearRequested>(_onClearRequested);
    on<OrderTicketCustomerNameChanged>(_onCustomerNameChanged);
    on<OrderTicketItemRemoved>(_onItemRemoved);
  }

  final OrderRepository _orderRepository;

  Timer? _debounceTimer;
  String _pendingName = '';

  Future<void> _onSubscriptionRequested(
    OrderTicketSubscriptionRequested event,
    Emitter<OrderTicketState> emit,
  ) async {
    await emit.forEach(
      _orderRepository.currentOrderStream,
      onData: (order) =>
          state.copyWith(status: OrderTicketStatus.idle, order: order),
      onError: (_, _) => state.copyWith(status: OrderTicketStatus.failure),
    );
  }

  Future<void> _onCreateOrderRequested(
    OrderTicketCreateOrderRequested event,
    Emitter<OrderTicketState> emit,
  ) async {
    if (_orderRepository.currentOrderId != null) return;
    emit(state.copyWith(status: OrderTicketStatus.loading, order: null));
    await _orderRepository.createOrder();
  }

  Future<void> _onChargeRequested(
    OrderTicketChargeRequested event,
    Emitter<OrderTicketState> emit,
  ) async {
    if (state.status == OrderTicketStatus.charging) return;
    final orderId = _orderRepository.currentOrderId;
    final order = state.order;
    if (orderId == null || order == null || order.items.isEmpty) return;
    emit(state.copyWith(status: OrderTicketStatus.charging));

    // Flush any pending debounced name update before submitting.
    _debounceTimer?.cancel();
    _debounceTimer = null;
    if (_pendingName.trim().isNotEmpty) {
      await _orderRepository.updateNameOnCurrentOrder(_pendingName);
    }

    _orderRepository.submitCurrentOrder();
    emit(
      state.copyWith(
        status: OrderTicketStatus.submitted,
        submittedOrderId: orderId,
      ),
    );
  }

  void _onClearRequested(
    OrderTicketClearRequested event,
    Emitter<OrderTicketState> emit,
  ) {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _pendingName = '';
    _orderRepository.clearCurrentOrder();
    emit(state.copyWith(status: OrderTicketStatus.idle, order: null));
  }

  void _onCustomerNameChanged(
    OrderTicketCustomerNameChanged event,
    Emitter<OrderTicketState> emit,
  ) {
    if (_orderRepository.currentOrderId == null) return;
    _pendingName = event.name;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      unawaited(_orderRepository.updateNameOnCurrentOrder(event.name));
    });
  }

  void _onItemRemoved(
    OrderTicketItemRemoved event,
    Emitter<OrderTicketState> emit,
  ) {
    _orderRepository.updateItemQuantity(event.lineItemId, 0);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
