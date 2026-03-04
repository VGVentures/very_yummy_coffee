// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'pos_orders_bloc.dart';

class PosOrdersStateMapper extends ClassMapperBase<PosOrdersState> {
  PosOrdersStateMapper._();

  static PosOrdersStateMapper? _instance;
  static PosOrdersStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PosOrdersStateMapper._());
      OrderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PosOrdersState';

  static PosOrdersStatus _$status(PosOrdersState v) => v.status;
  static const Field<PosOrdersState, PosOrdersStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: PosOrdersStatus.loading,
  );
  static List<Order> _$activeOrders(PosOrdersState v) => v.activeOrders;
  static const Field<PosOrdersState, List<Order>> _f$activeOrders = Field(
    'activeOrders',
    _$activeOrders,
    opt: true,
    def: const [],
  );
  static List<Order> _$historyOrders(PosOrdersState v) => v.historyOrders;
  static const Field<PosOrdersState, List<Order>> _f$historyOrders = Field(
    'historyOrders',
    _$historyOrders,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<PosOrdersState> fields = const {
    #status: _f$status,
    #activeOrders: _f$activeOrders,
    #historyOrders: _f$historyOrders,
  };

  static PosOrdersState _instantiate(DecodingData data) {
    return PosOrdersState(
      status: data.dec(_f$status),
      activeOrders: data.dec(_f$activeOrders),
      historyOrders: data.dec(_f$historyOrders),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PosOrdersState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PosOrdersState>(map);
  }

  static PosOrdersState fromJson(String json) {
    return ensureInitialized().decodeJson<PosOrdersState>(json);
  }
}

mixin PosOrdersStateMappable {
  String toJson() {
    return PosOrdersStateMapper.ensureInitialized().encodeJson<PosOrdersState>(
      this as PosOrdersState,
    );
  }

  Map<String, dynamic> toMap() {
    return PosOrdersStateMapper.ensureInitialized().encodeMap<PosOrdersState>(
      this as PosOrdersState,
    );
  }

  PosOrdersStateCopyWith<PosOrdersState, PosOrdersState, PosOrdersState>
  get copyWith => _PosOrdersStateCopyWithImpl<PosOrdersState, PosOrdersState>(
    this as PosOrdersState,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return PosOrdersStateMapper.ensureInitialized().stringifyValue(
      this as PosOrdersState,
    );
  }

  @override
  bool operator ==(Object other) {
    return PosOrdersStateMapper.ensureInitialized().equalsValue(
      this as PosOrdersState,
      other,
    );
  }

  @override
  int get hashCode {
    return PosOrdersStateMapper.ensureInitialized().hashValue(
      this as PosOrdersState,
    );
  }
}

extension PosOrdersStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PosOrdersState, $Out> {
  PosOrdersStateCopyWith<$R, PosOrdersState, $Out> get $asPosOrdersState =>
      $base.as((v, t, t2) => _PosOrdersStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PosOrdersStateCopyWith<$R, $In extends PosOrdersState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get activeOrders;
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get historyOrders;
  $R call({
    PosOrdersStatus? status,
    List<Order>? activeOrders,
    List<Order>? historyOrders,
  });
  PosOrdersStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PosOrdersStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PosOrdersState, $Out>
    implements PosOrdersStateCopyWith<$R, PosOrdersState, $Out> {
  _PosOrdersStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PosOrdersState> $mapper =
      PosOrdersStateMapper.ensureInitialized();
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
    PosOrdersStatus? status,
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
  PosOrdersState $make(CopyWithData data) => PosOrdersState(
    status: data.get(#status, or: $value.status),
    activeOrders: data.get(#activeOrders, or: $value.activeOrders),
    historyOrders: data.get(#historyOrders, or: $value.historyOrders),
  );

  @override
  PosOrdersStateCopyWith<$R2, PosOrdersState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PosOrdersStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

