// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order_complete_bloc.dart';

class OrderCompleteStateMapper extends ClassMapperBase<OrderCompleteState> {
  OrderCompleteStateMapper._();

  static OrderCompleteStateMapper? _instance;
  static OrderCompleteStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderCompleteStateMapper._());
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

