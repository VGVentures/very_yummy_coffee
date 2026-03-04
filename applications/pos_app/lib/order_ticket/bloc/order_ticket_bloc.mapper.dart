// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order_ticket_bloc.dart';

class OrderTicketStateMapper extends ClassMapperBase<OrderTicketState> {
  OrderTicketStateMapper._();

  static OrderTicketStateMapper? _instance;
  static OrderTicketStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderTicketStateMapper._());
      OrderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrderTicketState';

  static OrderTicketStatus _$status(OrderTicketState v) => v.status;
  static const Field<OrderTicketState, OrderTicketStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: OrderTicketStatus.loading,
  );
  static Order? _$order(OrderTicketState v) => v.order;
  static const Field<OrderTicketState, Order> _f$order = Field(
    'order',
    _$order,
    opt: true,
  );
  static String? _$submittedOrderId(OrderTicketState v) => v.submittedOrderId;
  static const Field<OrderTicketState, String> _f$submittedOrderId = Field(
    'submittedOrderId',
    _$submittedOrderId,
    opt: true,
  );

  @override
  final MappableFields<OrderTicketState> fields = const {
    #status: _f$status,
    #order: _f$order,
    #submittedOrderId: _f$submittedOrderId,
  };

  static OrderTicketState _instantiate(DecodingData data) {
    return OrderTicketState(
      status: data.dec(_f$status),
      order: data.dec(_f$order),
      submittedOrderId: data.dec(_f$submittedOrderId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrderTicketState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrderTicketState>(map);
  }

  static OrderTicketState fromJson(String json) {
    return ensureInitialized().decodeJson<OrderTicketState>(json);
  }
}

mixin OrderTicketStateMappable {
  String toJson() {
    return OrderTicketStateMapper.ensureInitialized()
        .encodeJson<OrderTicketState>(this as OrderTicketState);
  }

  Map<String, dynamic> toMap() {
    return OrderTicketStateMapper.ensureInitialized()
        .encodeMap<OrderTicketState>(this as OrderTicketState);
  }

  OrderTicketStateCopyWith<OrderTicketState, OrderTicketState, OrderTicketState>
  get copyWith =>
      _OrderTicketStateCopyWithImpl<OrderTicketState, OrderTicketState>(
        this as OrderTicketState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OrderTicketStateMapper.ensureInitialized().stringifyValue(
      this as OrderTicketState,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrderTicketStateMapper.ensureInitialized().equalsValue(
      this as OrderTicketState,
      other,
    );
  }

  @override
  int get hashCode {
    return OrderTicketStateMapper.ensureInitialized().hashValue(
      this as OrderTicketState,
    );
  }
}

extension OrderTicketStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrderTicketState, $Out> {
  OrderTicketStateCopyWith<$R, OrderTicketState, $Out>
  get $asOrderTicketState =>
      $base.as((v, t, t2) => _OrderTicketStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrderTicketStateCopyWith<$R, $In extends OrderTicketState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  OrderCopyWith<$R, Order, Order>? get order;
  $R call({OrderTicketStatus? status, Order? order, String? submittedOrderId});
  OrderTicketStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrderTicketStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrderTicketState, $Out>
    implements OrderTicketStateCopyWith<$R, OrderTicketState, $Out> {
  _OrderTicketStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrderTicketState> $mapper =
      OrderTicketStateMapper.ensureInitialized();
  @override
  OrderCopyWith<$R, Order, Order>? get order =>
      $value.order?.copyWith.$chain((v) => call(order: v));
  @override
  $R call({
    OrderTicketStatus? status,
    Object? order = $none,
    Object? submittedOrderId = $none,
  }) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (order != $none) #order: order,
      if (submittedOrderId != $none) #submittedOrderId: submittedOrderId,
    }),
  );
  @override
  OrderTicketState $make(CopyWithData data) => OrderTicketState(
    status: data.get(#status, or: $value.status),
    order: data.get(#order, or: $value.order),
    submittedOrderId: data.get(#submittedOrderId, or: $value.submittedOrderId),
  );

  @override
  OrderTicketStateCopyWith<$R2, OrderTicketState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrderTicketStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

