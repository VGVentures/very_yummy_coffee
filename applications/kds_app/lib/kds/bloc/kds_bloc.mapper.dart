// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'kds_bloc.dart';

class KdsStatusMapper extends EnumMapper<KdsStatus> {
  KdsStatusMapper._();

  static KdsStatusMapper? _instance;
  static KdsStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = KdsStatusMapper._());
    }
    return _instance!;
  }

  static KdsStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  KdsStatus decode(dynamic value) {
    switch (value) {
      case r'initial':
        return KdsStatus.initial;
      case r'loading':
        return KdsStatus.loading;
      case r'success':
        return KdsStatus.success;
      case r'failure':
        return KdsStatus.failure;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(KdsStatus self) {
    switch (self) {
      case KdsStatus.initial:
        return r'initial';
      case KdsStatus.loading:
        return r'loading';
      case KdsStatus.success:
        return r'success';
      case KdsStatus.failure:
        return r'failure';
    }
  }
}

extension KdsStatusMapperExtension on KdsStatus {
  String toValue() {
    KdsStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<KdsStatus>(this) as String;
  }
}

class KdsStateMapper extends ClassMapperBase<KdsState> {
  KdsStateMapper._();

  static KdsStateMapper? _instance;
  static KdsStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = KdsStateMapper._());
      KdsStatusMapper.ensureInitialized();
      OrderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'KdsState';

  static KdsStatus _$status(KdsState v) => v.status;
  static const Field<KdsState, KdsStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: KdsStatus.initial,
  );
  static List<Order> _$pendingOrders(KdsState v) => v.pendingOrders;
  static const Field<KdsState, List<Order>> _f$pendingOrders = Field(
    'pendingOrders',
    _$pendingOrders,
    opt: true,
    def: const [],
  );
  static List<Order> _$newOrders(KdsState v) => v.newOrders;
  static const Field<KdsState, List<Order>> _f$newOrders = Field(
    'newOrders',
    _$newOrders,
    opt: true,
    def: const [],
  );
  static List<Order> _$inProgressOrders(KdsState v) => v.inProgressOrders;
  static const Field<KdsState, List<Order>> _f$inProgressOrders = Field(
    'inProgressOrders',
    _$inProgressOrders,
    opt: true,
    def: const [],
  );
  static List<Order> _$readyOrders(KdsState v) => v.readyOrders;
  static const Field<KdsState, List<Order>> _f$readyOrders = Field(
    'readyOrders',
    _$readyOrders,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<KdsState> fields = const {
    #status: _f$status,
    #pendingOrders: _f$pendingOrders,
    #newOrders: _f$newOrders,
    #inProgressOrders: _f$inProgressOrders,
    #readyOrders: _f$readyOrders,
  };

  static KdsState _instantiate(DecodingData data) {
    return KdsState(
      status: data.dec(_f$status),
      pendingOrders: data.dec(_f$pendingOrders),
      newOrders: data.dec(_f$newOrders),
      inProgressOrders: data.dec(_f$inProgressOrders),
      readyOrders: data.dec(_f$readyOrders),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static KdsState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<KdsState>(map);
  }

  static KdsState fromJson(String json) {
    return ensureInitialized().decodeJson<KdsState>(json);
  }
}

mixin KdsStateMappable {
  String toJson() {
    return KdsStateMapper.ensureInitialized().encodeJson<KdsState>(
      this as KdsState,
    );
  }

  Map<String, dynamic> toMap() {
    return KdsStateMapper.ensureInitialized().encodeMap<KdsState>(
      this as KdsState,
    );
  }

  KdsStateCopyWith<KdsState, KdsState, KdsState> get copyWith =>
      _KdsStateCopyWithImpl<KdsState, KdsState>(
        this as KdsState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return KdsStateMapper.ensureInitialized().stringifyValue(this as KdsState);
  }

  @override
  bool operator ==(Object other) {
    return KdsStateMapper.ensureInitialized().equalsValue(
      this as KdsState,
      other,
    );
  }

  @override
  int get hashCode {
    return KdsStateMapper.ensureInitialized().hashValue(this as KdsState);
  }
}

extension KdsStateValueCopy<$R, $Out> on ObjectCopyWith<$R, KdsState, $Out> {
  KdsStateCopyWith<$R, KdsState, $Out> get $asKdsState =>
      $base.as((v, t, t2) => _KdsStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class KdsStateCopyWith<$R, $In extends KdsState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get pendingOrders;
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get newOrders;
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get inProgressOrders;
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get readyOrders;
  $R call({
    KdsStatus? status,
    List<Order>? pendingOrders,
    List<Order>? newOrders,
    List<Order>? inProgressOrders,
    List<Order>? readyOrders,
  });
  KdsStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _KdsStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, KdsState, $Out>
    implements KdsStateCopyWith<$R, KdsState, $Out> {
  _KdsStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<KdsState> $mapper =
      KdsStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get pendingOrders =>
      ListCopyWith(
        $value.pendingOrders,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(pendingOrders: v),
      );
  @override
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get newOrders =>
      ListCopyWith(
        $value.newOrders,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(newOrders: v),
      );
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
    KdsStatus? status,
    List<Order>? pendingOrders,
    List<Order>? newOrders,
    List<Order>? inProgressOrders,
    List<Order>? readyOrders,
  }) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (pendingOrders != null) #pendingOrders: pendingOrders,
      if (newOrders != null) #newOrders: newOrders,
      if (inProgressOrders != null) #inProgressOrders: inProgressOrders,
      if (readyOrders != null) #readyOrders: readyOrders,
    }),
  );
  @override
  KdsState $make(CopyWithData data) => KdsState(
    status: data.get(#status, or: $value.status),
    pendingOrders: data.get(#pendingOrders, or: $value.pendingOrders),
    newOrders: data.get(#newOrders, or: $value.newOrders),
    inProgressOrders: data.get(#inProgressOrders, or: $value.inProgressOrders),
    readyOrders: data.get(#readyOrders, or: $value.readyOrders),
  );

  @override
  KdsStateCopyWith<$R2, KdsState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _KdsStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

