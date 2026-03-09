// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order_status_bloc.dart';

class OrderStatusStatusMapper extends EnumMapper<OrderStatusStatus> {
  OrderStatusStatusMapper._();

  static OrderStatusStatusMapper? _instance;
  static OrderStatusStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderStatusStatusMapper._());
    }
    return _instance!;
  }

  static OrderStatusStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  OrderStatusStatus decode(dynamic value) {
    switch (value) {
      case r'initial':
        return OrderStatusStatus.initial;
      case r'loading':
        return OrderStatusStatus.loading;
      case r'success':
        return OrderStatusStatus.success;
      case r'failure':
        return OrderStatusStatus.failure;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(OrderStatusStatus self) {
    switch (self) {
      case OrderStatusStatus.initial:
        return r'initial';
      case OrderStatusStatus.loading:
        return r'loading';
      case OrderStatusStatus.success:
        return r'success';
      case OrderStatusStatus.failure:
        return r'failure';
    }
  }
}

extension OrderStatusStatusMapperExtension on OrderStatusStatus {
  String toValue() {
    OrderStatusStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<OrderStatusStatus>(this) as String;
  }
}

class OrderStatusStateMapper extends ClassMapperBase<OrderStatusState> {
  OrderStatusStateMapper._();

  static OrderStatusStateMapper? _instance;
  static OrderStatusStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderStatusStateMapper._());
      OrderStatusStatusMapper.ensureInitialized();
      OrderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrderStatusState';

  static OrderStatusStatus _$status(OrderStatusState v) => v.status;
  static const Field<OrderStatusState, OrderStatusStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: OrderStatusStatus.initial,
  );
  static List<Order> _$inProgressOrders(OrderStatusState v) =>
      v.inProgressOrders;
  static const Field<OrderStatusState, List<Order>> _f$inProgressOrders = Field(
    'inProgressOrders',
    _$inProgressOrders,
    opt: true,
    def: const [],
  );
  static List<Order> _$readyOrders(OrderStatusState v) => v.readyOrders;
  static const Field<OrderStatusState, List<Order>> _f$readyOrders = Field(
    'readyOrders',
    _$readyOrders,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<OrderStatusState> fields = const {
    #status: _f$status,
    #inProgressOrders: _f$inProgressOrders,
    #readyOrders: _f$readyOrders,
  };

  static OrderStatusState _instantiate(DecodingData data) {
    return OrderStatusState(
      status: data.dec(_f$status),
      inProgressOrders: data.dec(_f$inProgressOrders),
      readyOrders: data.dec(_f$readyOrders),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrderStatusState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrderStatusState>(map);
  }

  static OrderStatusState fromJson(String json) {
    return ensureInitialized().decodeJson<OrderStatusState>(json);
  }
}

mixin OrderStatusStateMappable {
  String toJson() {
    return OrderStatusStateMapper.ensureInitialized()
        .encodeJson<OrderStatusState>(this as OrderStatusState);
  }

  Map<String, dynamic> toMap() {
    return OrderStatusStateMapper.ensureInitialized()
        .encodeMap<OrderStatusState>(this as OrderStatusState);
  }

  OrderStatusStateCopyWith<OrderStatusState, OrderStatusState, OrderStatusState>
  get copyWith =>
      _OrderStatusStateCopyWithImpl<OrderStatusState, OrderStatusState>(
        this as OrderStatusState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OrderStatusStateMapper.ensureInitialized().stringifyValue(
      this as OrderStatusState,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrderStatusStateMapper.ensureInitialized().equalsValue(
      this as OrderStatusState,
      other,
    );
  }

  @override
  int get hashCode {
    return OrderStatusStateMapper.ensureInitialized().hashValue(
      this as OrderStatusState,
    );
  }
}

extension OrderStatusStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrderStatusState, $Out> {
  OrderStatusStateCopyWith<$R, OrderStatusState, $Out>
  get $asOrderStatusState =>
      $base.as((v, t, t2) => _OrderStatusStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrderStatusStateCopyWith<$R, $In extends OrderStatusState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get inProgressOrders;
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get readyOrders;
  $R call({
    OrderStatusStatus? status,
    List<Order>? inProgressOrders,
    List<Order>? readyOrders,
  });
  OrderStatusStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrderStatusStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrderStatusState, $Out>
    implements OrderStatusStateCopyWith<$R, OrderStatusState, $Out> {
  _OrderStatusStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrderStatusState> $mapper =
      OrderStatusStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>>
  get inProgressOrders => ListCopyWith(
    $value.inProgressOrders,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(inProgressOrders: v),
  );
  @override
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get readyOrders =>
      ListCopyWith(
        $value.readyOrders,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(readyOrders: v),
      );
  @override
  $R call({
    OrderStatusStatus? status,
    List<Order>? inProgressOrders,
    List<Order>? readyOrders,
  }) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (inProgressOrders != null) #inProgressOrders: inProgressOrders,
      if (readyOrders != null) #readyOrders: readyOrders,
    }),
  );
  @override
  OrderStatusState $make(CopyWithData data) => OrderStatusState(
    status: data.get(#status, or: $value.status),
    inProgressOrders: data.get(#inProgressOrders, or: $value.inProgressOrders),
    readyOrders: data.get(#readyOrders, or: $value.readyOrders),
  );

  @override
  OrderStatusStateCopyWith<$R2, OrderStatusState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrderStatusStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

