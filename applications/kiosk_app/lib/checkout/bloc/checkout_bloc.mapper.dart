// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'checkout_bloc.dart';

class CheckoutStatusMapper extends EnumMapper<CheckoutStatus> {
  CheckoutStatusMapper._();

  static CheckoutStatusMapper? _instance;
  static CheckoutStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CheckoutStatusMapper._());
    }
    return _instance!;
  }

  static CheckoutStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  CheckoutStatus decode(dynamic value) {
    switch (value) {
      case r'loading':
        return CheckoutStatus.loading;
      case r'idle':
        return CheckoutStatus.idle;
      case r'submitting':
        return CheckoutStatus.submitting;
      case r'success':
        return CheckoutStatus.success;
      case r'failure':
        return CheckoutStatus.failure;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(CheckoutStatus self) {
    switch (self) {
      case CheckoutStatus.loading:
        return r'loading';
      case CheckoutStatus.idle:
        return r'idle';
      case CheckoutStatus.submitting:
        return r'submitting';
      case CheckoutStatus.success:
        return r'success';
      case CheckoutStatus.failure:
        return r'failure';
    }
  }
}

extension CheckoutStatusMapperExtension on CheckoutStatus {
  String toValue() {
    CheckoutStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<CheckoutStatus>(this) as String;
  }
}

class CheckoutEventMapper extends ClassMapperBase<CheckoutEvent> {
  CheckoutEventMapper._();

  static CheckoutEventMapper? _instance;
  static CheckoutEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CheckoutEventMapper._());
      CheckoutSubscriptionRequestedMapper.ensureInitialized();
      CheckoutConfirmedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CheckoutEvent';

  @override
  final MappableFields<CheckoutEvent> fields = const {};

  static CheckoutEvent _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('CheckoutEvent');
  }

  @override
  final Function instantiate = _instantiate;

  static CheckoutEvent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CheckoutEvent>(map);
  }

  static CheckoutEvent fromJson(String json) {
    return ensureInitialized().decodeJson<CheckoutEvent>(json);
  }
}

mixin CheckoutEventMappable {
  String toJson();
  Map<String, dynamic> toMap();
  CheckoutEventCopyWith<CheckoutEvent, CheckoutEvent, CheckoutEvent>
  get copyWith;
}

abstract class CheckoutEventCopyWith<$R, $In extends CheckoutEvent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  CheckoutEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class CheckoutSubscriptionRequestedMapper
    extends ClassMapperBase<CheckoutSubscriptionRequested> {
  CheckoutSubscriptionRequestedMapper._();

  static CheckoutSubscriptionRequestedMapper? _instance;
  static CheckoutSubscriptionRequestedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = CheckoutSubscriptionRequestedMapper._(),
      );
      CheckoutEventMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CheckoutSubscriptionRequested';

  @override
  final MappableFields<CheckoutSubscriptionRequested> fields = const {};

  static CheckoutSubscriptionRequested _instantiate(DecodingData data) {
    return CheckoutSubscriptionRequested();
  }

  @override
  final Function instantiate = _instantiate;

  static CheckoutSubscriptionRequested fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CheckoutSubscriptionRequested>(map);
  }

  static CheckoutSubscriptionRequested fromJson(String json) {
    return ensureInitialized().decodeJson<CheckoutSubscriptionRequested>(json);
  }
}

mixin CheckoutSubscriptionRequestedMappable {
  String toJson() {
    return CheckoutSubscriptionRequestedMapper.ensureInitialized()
        .encodeJson<CheckoutSubscriptionRequested>(
          this as CheckoutSubscriptionRequested,
        );
  }

  Map<String, dynamic> toMap() {
    return CheckoutSubscriptionRequestedMapper.ensureInitialized()
        .encodeMap<CheckoutSubscriptionRequested>(
          this as CheckoutSubscriptionRequested,
        );
  }

  CheckoutSubscriptionRequestedCopyWith<
    CheckoutSubscriptionRequested,
    CheckoutSubscriptionRequested,
    CheckoutSubscriptionRequested
  >
  get copyWith =>
      _CheckoutSubscriptionRequestedCopyWithImpl<
        CheckoutSubscriptionRequested,
        CheckoutSubscriptionRequested
      >(this as CheckoutSubscriptionRequested, $identity, $identity);
  @override
  String toString() {
    return CheckoutSubscriptionRequestedMapper.ensureInitialized()
        .stringifyValue(this as CheckoutSubscriptionRequested);
  }

  @override
  bool operator ==(Object other) {
    return CheckoutSubscriptionRequestedMapper.ensureInitialized().equalsValue(
      this as CheckoutSubscriptionRequested,
      other,
    );
  }

  @override
  int get hashCode {
    return CheckoutSubscriptionRequestedMapper.ensureInitialized().hashValue(
      this as CheckoutSubscriptionRequested,
    );
  }
}

extension CheckoutSubscriptionRequestedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CheckoutSubscriptionRequested, $Out> {
  CheckoutSubscriptionRequestedCopyWith<$R, CheckoutSubscriptionRequested, $Out>
  get $asCheckoutSubscriptionRequested => $base.as(
    (v, t, t2) =>
        _CheckoutSubscriptionRequestedCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CheckoutSubscriptionRequestedCopyWith<
  $R,
  $In extends CheckoutSubscriptionRequested,
  $Out
>
    implements CheckoutEventCopyWith<$R, $In, $Out> {
  @override
  $R call();
  CheckoutSubscriptionRequestedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CheckoutSubscriptionRequestedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CheckoutSubscriptionRequested, $Out>
    implements
        CheckoutSubscriptionRequestedCopyWith<
          $R,
          CheckoutSubscriptionRequested,
          $Out
        > {
  _CheckoutSubscriptionRequestedCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<CheckoutSubscriptionRequested> $mapper =
      CheckoutSubscriptionRequestedMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  CheckoutSubscriptionRequested $make(CopyWithData data) =>
      CheckoutSubscriptionRequested();

  @override
  CheckoutSubscriptionRequestedCopyWith<
    $R2,
    CheckoutSubscriptionRequested,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CheckoutSubscriptionRequestedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CheckoutConfirmedMapper extends ClassMapperBase<CheckoutConfirmed> {
  CheckoutConfirmedMapper._();

  static CheckoutConfirmedMapper? _instance;
  static CheckoutConfirmedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CheckoutConfirmedMapper._());
      CheckoutEventMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CheckoutConfirmed';

  @override
  final MappableFields<CheckoutConfirmed> fields = const {};

  static CheckoutConfirmed _instantiate(DecodingData data) {
    return CheckoutConfirmed();
  }

  @override
  final Function instantiate = _instantiate;

  static CheckoutConfirmed fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CheckoutConfirmed>(map);
  }

  static CheckoutConfirmed fromJson(String json) {
    return ensureInitialized().decodeJson<CheckoutConfirmed>(json);
  }
}

mixin CheckoutConfirmedMappable {
  String toJson() {
    return CheckoutConfirmedMapper.ensureInitialized()
        .encodeJson<CheckoutConfirmed>(this as CheckoutConfirmed);
  }

  Map<String, dynamic> toMap() {
    return CheckoutConfirmedMapper.ensureInitialized()
        .encodeMap<CheckoutConfirmed>(this as CheckoutConfirmed);
  }

  CheckoutConfirmedCopyWith<
    CheckoutConfirmed,
    CheckoutConfirmed,
    CheckoutConfirmed
  >
  get copyWith =>
      _CheckoutConfirmedCopyWithImpl<CheckoutConfirmed, CheckoutConfirmed>(
        this as CheckoutConfirmed,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CheckoutConfirmedMapper.ensureInitialized().stringifyValue(
      this as CheckoutConfirmed,
    );
  }

  @override
  bool operator ==(Object other) {
    return CheckoutConfirmedMapper.ensureInitialized().equalsValue(
      this as CheckoutConfirmed,
      other,
    );
  }

  @override
  int get hashCode {
    return CheckoutConfirmedMapper.ensureInitialized().hashValue(
      this as CheckoutConfirmed,
    );
  }
}

extension CheckoutConfirmedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CheckoutConfirmed, $Out> {
  CheckoutConfirmedCopyWith<$R, CheckoutConfirmed, $Out>
  get $asCheckoutConfirmed => $base.as(
    (v, t, t2) => _CheckoutConfirmedCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CheckoutConfirmedCopyWith<
  $R,
  $In extends CheckoutConfirmed,
  $Out
>
    implements CheckoutEventCopyWith<$R, $In, $Out> {
  @override
  $R call();
  CheckoutConfirmedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CheckoutConfirmedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CheckoutConfirmed, $Out>
    implements CheckoutConfirmedCopyWith<$R, CheckoutConfirmed, $Out> {
  _CheckoutConfirmedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CheckoutConfirmed> $mapper =
      CheckoutConfirmedMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  CheckoutConfirmed $make(CopyWithData data) => CheckoutConfirmed();

  @override
  CheckoutConfirmedCopyWith<$R2, CheckoutConfirmed, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CheckoutConfirmedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CheckoutStateMapper extends ClassMapperBase<CheckoutState> {
  CheckoutStateMapper._();

  static CheckoutStateMapper? _instance;
  static CheckoutStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CheckoutStateMapper._());
      CheckoutStatusMapper.ensureInitialized();
      OrderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CheckoutState';

  static CheckoutStatus _$status(CheckoutState v) => v.status;
  static const Field<CheckoutState, CheckoutStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: CheckoutStatus.loading,
  );
  static Order? _$order(CheckoutState v) => v.order;
  static const Field<CheckoutState, Order> _f$order = Field(
    'order',
    _$order,
    opt: true,
  );

  @override
  final MappableFields<CheckoutState> fields = const {
    #status: _f$status,
    #order: _f$order,
  };

  static CheckoutState _instantiate(DecodingData data) {
    return CheckoutState(
      status: data.dec(_f$status),
      order: data.dec(_f$order),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CheckoutState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CheckoutState>(map);
  }

  static CheckoutState fromJson(String json) {
    return ensureInitialized().decodeJson<CheckoutState>(json);
  }
}

mixin CheckoutStateMappable {
  String toJson() {
    return CheckoutStateMapper.ensureInitialized().encodeJson<CheckoutState>(
      this as CheckoutState,
    );
  }

  Map<String, dynamic> toMap() {
    return CheckoutStateMapper.ensureInitialized().encodeMap<CheckoutState>(
      this as CheckoutState,
    );
  }

  CheckoutStateCopyWith<CheckoutState, CheckoutState, CheckoutState>
  get copyWith => _CheckoutStateCopyWithImpl<CheckoutState, CheckoutState>(
    this as CheckoutState,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return CheckoutStateMapper.ensureInitialized().stringifyValue(
      this as CheckoutState,
    );
  }

  @override
  bool operator ==(Object other) {
    return CheckoutStateMapper.ensureInitialized().equalsValue(
      this as CheckoutState,
      other,
    );
  }

  @override
  int get hashCode {
    return CheckoutStateMapper.ensureInitialized().hashValue(
      this as CheckoutState,
    );
  }
}

extension CheckoutStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CheckoutState, $Out> {
  CheckoutStateCopyWith<$R, CheckoutState, $Out> get $asCheckoutState =>
      $base.as((v, t, t2) => _CheckoutStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CheckoutStateCopyWith<$R, $In extends CheckoutState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  OrderCopyWith<$R, Order, Order>? get order;
  $R call({CheckoutStatus? status, Order? order});
  CheckoutStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CheckoutStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CheckoutState, $Out>
    implements CheckoutStateCopyWith<$R, CheckoutState, $Out> {
  _CheckoutStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CheckoutState> $mapper =
      CheckoutStateMapper.ensureInitialized();
  @override
  OrderCopyWith<$R, Order, Order>? get order =>
      $value.order?.copyWith.$chain((v) => call(order: v));
  @override
  $R call({CheckoutStatus? status, Object? order = $none}) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (order != $none) #order: order,
    }),
  );
  @override
  CheckoutState $make(CopyWithData data) => CheckoutState(
    status: data.get(#status, or: $value.status),
    order: data.get(#order, or: $value.order),
  );

  @override
  CheckoutStateCopyWith<$R2, CheckoutState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CheckoutStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

