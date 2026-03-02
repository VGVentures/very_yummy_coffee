// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order_complete_bloc.dart';

class OrderCompleteStatusMapper extends EnumMapper<OrderCompleteStatus> {
  OrderCompleteStatusMapper._();

  static OrderCompleteStatusMapper? _instance;
  static OrderCompleteStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderCompleteStatusMapper._());
    }
    return _instance!;
  }

  static OrderCompleteStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  OrderCompleteStatus decode(dynamic value) {
    switch (value) {
      case r'loading':
        return OrderCompleteStatus.loading;
      case r'success':
        return OrderCompleteStatus.success;
      case r'failure':
        return OrderCompleteStatus.failure;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(OrderCompleteStatus self) {
    switch (self) {
      case OrderCompleteStatus.loading:
        return r'loading';
      case OrderCompleteStatus.success:
        return r'success';
      case OrderCompleteStatus.failure:
        return r'failure';
    }
  }
}

extension OrderCompleteStatusMapperExtension on OrderCompleteStatus {
  String toValue() {
    OrderCompleteStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<OrderCompleteStatus>(this) as String;
  }
}

class OrderCompleteEventMapper extends ClassMapperBase<OrderCompleteEvent> {
  OrderCompleteEventMapper._();

  static OrderCompleteEventMapper? _instance;
  static OrderCompleteEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderCompleteEventMapper._());
      OrderCompleteSubscriptionRequestedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrderCompleteEvent';

  @override
  final MappableFields<OrderCompleteEvent> fields = const {};

  static OrderCompleteEvent _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('OrderCompleteEvent');
  }

  @override
  final Function instantiate = _instantiate;

  static OrderCompleteEvent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrderCompleteEvent>(map);
  }

  static OrderCompleteEvent fromJson(String json) {
    return ensureInitialized().decodeJson<OrderCompleteEvent>(json);
  }
}

mixin OrderCompleteEventMappable {
  String toJson();
  Map<String, dynamic> toMap();
  OrderCompleteEventCopyWith<
    OrderCompleteEvent,
    OrderCompleteEvent,
    OrderCompleteEvent
  >
  get copyWith;
}

abstract class OrderCompleteEventCopyWith<
  $R,
  $In extends OrderCompleteEvent,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  OrderCompleteEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class OrderCompleteSubscriptionRequestedMapper
    extends ClassMapperBase<OrderCompleteSubscriptionRequested> {
  OrderCompleteSubscriptionRequestedMapper._();

  static OrderCompleteSubscriptionRequestedMapper? _instance;
  static OrderCompleteSubscriptionRequestedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = OrderCompleteSubscriptionRequestedMapper._(),
      );
      OrderCompleteEventMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrderCompleteSubscriptionRequested';

  static String _$orderId(OrderCompleteSubscriptionRequested v) => v.orderId;
  static const Field<OrderCompleteSubscriptionRequested, String> _f$orderId =
      Field('orderId', _$orderId);

  @override
  final MappableFields<OrderCompleteSubscriptionRequested> fields = const {
    #orderId: _f$orderId,
  };

  static OrderCompleteSubscriptionRequested _instantiate(DecodingData data) {
    return OrderCompleteSubscriptionRequested(orderId: data.dec(_f$orderId));
  }

  @override
  final Function instantiate = _instantiate;

  static OrderCompleteSubscriptionRequested fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrderCompleteSubscriptionRequested>(
      map,
    );
  }

  static OrderCompleteSubscriptionRequested fromJson(String json) {
    return ensureInitialized().decodeJson<OrderCompleteSubscriptionRequested>(
      json,
    );
  }
}

mixin OrderCompleteSubscriptionRequestedMappable {
  String toJson() {
    return OrderCompleteSubscriptionRequestedMapper.ensureInitialized()
        .encodeJson<OrderCompleteSubscriptionRequested>(
          this as OrderCompleteSubscriptionRequested,
        );
  }

  Map<String, dynamic> toMap() {
    return OrderCompleteSubscriptionRequestedMapper.ensureInitialized()
        .encodeMap<OrderCompleteSubscriptionRequested>(
          this as OrderCompleteSubscriptionRequested,
        );
  }

  OrderCompleteSubscriptionRequestedCopyWith<
    OrderCompleteSubscriptionRequested,
    OrderCompleteSubscriptionRequested,
    OrderCompleteSubscriptionRequested
  >
  get copyWith =>
      _OrderCompleteSubscriptionRequestedCopyWithImpl<
        OrderCompleteSubscriptionRequested,
        OrderCompleteSubscriptionRequested
      >(this as OrderCompleteSubscriptionRequested, $identity, $identity);
  @override
  String toString() {
    return OrderCompleteSubscriptionRequestedMapper.ensureInitialized()
        .stringifyValue(this as OrderCompleteSubscriptionRequested);
  }

  @override
  bool operator ==(Object other) {
    return OrderCompleteSubscriptionRequestedMapper.ensureInitialized()
        .equalsValue(this as OrderCompleteSubscriptionRequested, other);
  }

  @override
  int get hashCode {
    return OrderCompleteSubscriptionRequestedMapper.ensureInitialized()
        .hashValue(this as OrderCompleteSubscriptionRequested);
  }
}

extension OrderCompleteSubscriptionRequestedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrderCompleteSubscriptionRequested, $Out> {
  OrderCompleteSubscriptionRequestedCopyWith<
    $R,
    OrderCompleteSubscriptionRequested,
    $Out
  >
  get $asOrderCompleteSubscriptionRequested => $base.as(
    (v, t, t2) =>
        _OrderCompleteSubscriptionRequestedCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrderCompleteSubscriptionRequestedCopyWith<
  $R,
  $In extends OrderCompleteSubscriptionRequested,
  $Out
>
    implements OrderCompleteEventCopyWith<$R, $In, $Out> {
  @override
  $R call({String? orderId});
  OrderCompleteSubscriptionRequestedCopyWith<$R2, $In, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OrderCompleteSubscriptionRequestedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrderCompleteSubscriptionRequested, $Out>
    implements
        OrderCompleteSubscriptionRequestedCopyWith<
          $R,
          OrderCompleteSubscriptionRequested,
          $Out
        > {
  _OrderCompleteSubscriptionRequestedCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<OrderCompleteSubscriptionRequested> $mapper =
      OrderCompleteSubscriptionRequestedMapper.ensureInitialized();
  @override
  $R call({String? orderId}) =>
      $apply(FieldCopyWithData({if (orderId != null) #orderId: orderId}));
  @override
  OrderCompleteSubscriptionRequested $make(CopyWithData data) =>
      OrderCompleteSubscriptionRequested(
        orderId: data.get(#orderId, or: $value.orderId),
      );

  @override
  OrderCompleteSubscriptionRequestedCopyWith<
    $R2,
    OrderCompleteSubscriptionRequested,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrderCompleteSubscriptionRequestedCopyWithImpl<$R2, $Out2>(
        $value,
        $cast,
        t,
      );
}

class OrderCompleteStateMapper extends ClassMapperBase<OrderCompleteState> {
  OrderCompleteStateMapper._();

  static OrderCompleteStateMapper? _instance;
  static OrderCompleteStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderCompleteStateMapper._());
      OrderCompleteStatusMapper.ensureInitialized();
      OrderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrderCompleteState';

  static OrderCompleteStatus _$status(OrderCompleteState v) => v.status;
  static const Field<OrderCompleteState, OrderCompleteStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: OrderCompleteStatus.loading,
  );
  static Order? _$order(OrderCompleteState v) => v.order;
  static const Field<OrderCompleteState, Order> _f$order = Field(
    'order',
    _$order,
    opt: true,
  );

  @override
  final MappableFields<OrderCompleteState> fields = const {
    #status: _f$status,
    #order: _f$order,
  };

  static OrderCompleteState _instantiate(DecodingData data) {
    return OrderCompleteState(
      status: data.dec(_f$status),
      order: data.dec(_f$order),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrderCompleteState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrderCompleteState>(map);
  }

  static OrderCompleteState fromJson(String json) {
    return ensureInitialized().decodeJson<OrderCompleteState>(json);
  }
}

mixin OrderCompleteStateMappable {
  String toJson() {
    return OrderCompleteStateMapper.ensureInitialized()
        .encodeJson<OrderCompleteState>(this as OrderCompleteState);
  }

  Map<String, dynamic> toMap() {
    return OrderCompleteStateMapper.ensureInitialized()
        .encodeMap<OrderCompleteState>(this as OrderCompleteState);
  }

  OrderCompleteStateCopyWith<
    OrderCompleteState,
    OrderCompleteState,
    OrderCompleteState
  >
  get copyWith =>
      _OrderCompleteStateCopyWithImpl<OrderCompleteState, OrderCompleteState>(
        this as OrderCompleteState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OrderCompleteStateMapper.ensureInitialized().stringifyValue(
      this as OrderCompleteState,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrderCompleteStateMapper.ensureInitialized().equalsValue(
      this as OrderCompleteState,
      other,
    );
  }

  @override
  int get hashCode {
    return OrderCompleteStateMapper.ensureInitialized().hashValue(
      this as OrderCompleteState,
    );
  }
}

extension OrderCompleteStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrderCompleteState, $Out> {
  OrderCompleteStateCopyWith<$R, OrderCompleteState, $Out>
  get $asOrderCompleteState => $base.as(
    (v, t, t2) => _OrderCompleteStateCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class OrderCompleteStateCopyWith<
  $R,
  $In extends OrderCompleteState,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  OrderCopyWith<$R, Order, Order>? get order;
  $R call({OrderCompleteStatus? status, Order? order});
  OrderCompleteStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrderCompleteStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrderCompleteState, $Out>
    implements OrderCompleteStateCopyWith<$R, OrderCompleteState, $Out> {
  _OrderCompleteStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrderCompleteState> $mapper =
      OrderCompleteStateMapper.ensureInitialized();
  @override
  OrderCopyWith<$R, Order, Order>? get order =>
      $value.order?.copyWith.$chain((v) => call(order: v));
  @override
  $R call({OrderCompleteStatus? status, Object? order = $none}) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (order != $none) #order: order,
    }),
  );
  @override
  OrderCompleteState $make(CopyWithData data) => OrderCompleteState(
    status: data.get(#status, or: $value.status),
    order: data.get(#order, or: $value.order),
  );

  @override
  OrderCompleteStateCopyWith<$R2, OrderCompleteState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrderCompleteStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

