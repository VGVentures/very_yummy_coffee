// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'pos_order_complete_bloc.dart';

class PosOrderCompleteStateMapper
    extends ClassMapperBase<PosOrderCompleteState> {
  PosOrderCompleteStateMapper._();

  static PosOrderCompleteStateMapper? _instance;
  static PosOrderCompleteStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PosOrderCompleteStateMapper._());
      OrderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PosOrderCompleteState';

  static PosOrderCompleteStatus _$status(PosOrderCompleteState v) => v.status;
  static const Field<PosOrderCompleteState, PosOrderCompleteStatus> _f$status =
      Field('status', _$status, opt: true, def: PosOrderCompleteStatus.loading);
  static Order? _$order(PosOrderCompleteState v) => v.order;
  static const Field<PosOrderCompleteState, Order> _f$order = Field(
    'order',
    _$order,
    opt: true,
  );

  @override
  final MappableFields<PosOrderCompleteState> fields = const {
    #status: _f$status,
    #order: _f$order,
  };

  static PosOrderCompleteState _instantiate(DecodingData data) {
    return PosOrderCompleteState(
      status: data.dec(_f$status),
      order: data.dec(_f$order),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PosOrderCompleteState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PosOrderCompleteState>(map);
  }

  static PosOrderCompleteState fromJson(String json) {
    return ensureInitialized().decodeJson<PosOrderCompleteState>(json);
  }
}

mixin PosOrderCompleteStateMappable {
  String toJson() {
    return PosOrderCompleteStateMapper.ensureInitialized()
        .encodeJson<PosOrderCompleteState>(this as PosOrderCompleteState);
  }

  Map<String, dynamic> toMap() {
    return PosOrderCompleteStateMapper.ensureInitialized()
        .encodeMap<PosOrderCompleteState>(this as PosOrderCompleteState);
  }

  PosOrderCompleteStateCopyWith<
    PosOrderCompleteState,
    PosOrderCompleteState,
    PosOrderCompleteState
  >
  get copyWith =>
      _PosOrderCompleteStateCopyWithImpl<
        PosOrderCompleteState,
        PosOrderCompleteState
      >(this as PosOrderCompleteState, $identity, $identity);
  @override
  String toString() {
    return PosOrderCompleteStateMapper.ensureInitialized().stringifyValue(
      this as PosOrderCompleteState,
    );
  }

  @override
  bool operator ==(Object other) {
    return PosOrderCompleteStateMapper.ensureInitialized().equalsValue(
      this as PosOrderCompleteState,
      other,
    );
  }

  @override
  int get hashCode {
    return PosOrderCompleteStateMapper.ensureInitialized().hashValue(
      this as PosOrderCompleteState,
    );
  }
}

extension PosOrderCompleteStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PosOrderCompleteState, $Out> {
  PosOrderCompleteStateCopyWith<$R, PosOrderCompleteState, $Out>
  get $asPosOrderCompleteState => $base.as(
    (v, t, t2) => _PosOrderCompleteStateCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class PosOrderCompleteStateCopyWith<
  $R,
  $In extends PosOrderCompleteState,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  OrderCopyWith<$R, Order, Order>? get order;
  $R call({PosOrderCompleteStatus? status, Order? order});
  PosOrderCompleteStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PosOrderCompleteStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PosOrderCompleteState, $Out>
    implements PosOrderCompleteStateCopyWith<$R, PosOrderCompleteState, $Out> {
  _PosOrderCompleteStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PosOrderCompleteState> $mapper =
      PosOrderCompleteStateMapper.ensureInitialized();
  @override
  OrderCopyWith<$R, Order, Order>? get order =>
      $value.order?.copyWith.$chain((v) => call(order: v));
  @override
  $R call({PosOrderCompleteStatus? status, Object? order = $none}) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (order != $none) #order: order,
    }),
  );
  @override
  PosOrderCompleteState $make(CopyWithData data) => PosOrderCompleteState(
    status: data.get(#status, or: $value.status),
    order: data.get(#order, or: $value.order),
  );

  @override
  PosOrderCompleteStateCopyWith<$R2, PosOrderCompleteState, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PosOrderCompleteStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

