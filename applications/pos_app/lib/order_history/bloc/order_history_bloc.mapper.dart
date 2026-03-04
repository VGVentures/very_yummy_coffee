// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order_history_bloc.dart';

class OrderHistoryStateMapper extends ClassMapperBase<OrderHistoryState> {
  OrderHistoryStateMapper._();

  static OrderHistoryStateMapper? _instance;
  static OrderHistoryStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderHistoryStateMapper._());
      OrderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'OrderHistoryState';

  static OrderHistoryStatus _$status(OrderHistoryState v) => v.status;
  static const Field<OrderHistoryState, OrderHistoryStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: OrderHistoryStatus.loading,
  );
  static List<Order> _$activeOrders(OrderHistoryState v) => v.activeOrders;
  static const Field<OrderHistoryState, List<Order>> _f$activeOrders = Field(
    'activeOrders',
    _$activeOrders,
    opt: true,
    def: const [],
  );
  static List<Order> _$historyOrders(OrderHistoryState v) => v.historyOrders;
  static const Field<OrderHistoryState, List<Order>> _f$historyOrders = Field(
    'historyOrders',
    _$historyOrders,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<OrderHistoryState> fields = const {
    #status: _f$status,
    #activeOrders: _f$activeOrders,
    #historyOrders: _f$historyOrders,
  };

  static OrderHistoryState _instantiate(DecodingData data) {
    return OrderHistoryState(
      status: data.dec(_f$status),
      activeOrders: data.dec(_f$activeOrders),
      historyOrders: data.dec(_f$historyOrders),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrderHistoryState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrderHistoryState>(map);
  }

  static OrderHistoryState fromJson(String json) {
    return ensureInitialized().decodeJson<OrderHistoryState>(json);
  }
}

mixin OrderHistoryStateMappable {
  String toJson() {
    return OrderHistoryStateMapper.ensureInitialized().encodeJson<OrderHistoryState>(
      this as OrderHistoryState,
    );
  }

  Map<String, dynamic> toMap() {
    return OrderHistoryStateMapper.ensureInitialized().encodeMap<OrderHistoryState>(
      this as OrderHistoryState,
    );
  }

  OrderHistoryStateCopyWith<OrderHistoryState, OrderHistoryState, OrderHistoryState>
  get copyWith => _OrderHistoryStateCopyWithImpl<OrderHistoryState, OrderHistoryState>(
    this as OrderHistoryState,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return OrderHistoryStateMapper.ensureInitialized().stringifyValue(
      this as OrderHistoryState,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrderHistoryStateMapper.ensureInitialized().equalsValue(
      this as OrderHistoryState,
      other,
    );
  }

  @override
  int get hashCode {
    return OrderHistoryStateMapper.ensureInitialized().hashValue(
      this as OrderHistoryState,
    );
  }
}

extension OrderHistoryStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrderHistoryState, $Out> {
  OrderHistoryStateCopyWith<$R, OrderHistoryState, $Out> get $asOrderHistoryState =>
      $base.as((v, t, t2) => _OrderHistoryStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrderHistoryStateCopyWith<$R, $In extends OrderHistoryState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get activeOrders;
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get historyOrders;
  $R call({
    OrderHistoryStatus? status,
    List<Order>? activeOrders,
    List<Order>? historyOrders,
  });
  OrderHistoryStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrderHistoryStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrderHistoryState, $Out>
    implements OrderHistoryStateCopyWith<$R, OrderHistoryState, $Out> {
  _OrderHistoryStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrderHistoryState> $mapper =
      OrderHistoryStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get activeOrders =>
      ListCopyWith(
        $value.activeOrders,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(activeOrders: v),
      );
  @override
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get historyOrders =>
      ListCopyWith(
        $value.historyOrders,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(historyOrders: v),
      );
  @override
  $R call({
    OrderHistoryStatus? status,
    List<Order>? activeOrders,
    List<Order>? historyOrders,
  }) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (activeOrders != null) #activeOrders: activeOrders,
      if (historyOrders != null) #historyOrders: historyOrders,
    }),
  );
  @override
  OrderHistoryState $make(CopyWithData data) => OrderHistoryState(
    status: data.get(#status, or: $value.status),
    activeOrders: data.get(#activeOrders, or: $value.activeOrders),
    historyOrders: data.get(#historyOrders, or: $value.historyOrders),
  );

  @override
  OrderHistoryStateCopyWith<$R2, OrderHistoryState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrderHistoryStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

