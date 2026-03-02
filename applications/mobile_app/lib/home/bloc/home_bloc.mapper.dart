// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'home_bloc.dart';

class HomeStatusMapper extends EnumMapper<HomeStatus> {
  HomeStatusMapper._();

  static HomeStatusMapper? _instance;
  static HomeStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HomeStatusMapper._());
    }
    return _instance!;
  }

  static HomeStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  HomeStatus decode(dynamic value) {
    switch (value) {
      case r'loading':
        return HomeStatus.loading;
      case r'success':
        return HomeStatus.success;
      case r'failure':
        return HomeStatus.failure;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(HomeStatus self) {
    switch (self) {
      case HomeStatus.loading:
        return r'loading';
      case HomeStatus.success:
        return r'success';
      case HomeStatus.failure:
        return r'failure';
    }
  }
}

extension HomeStatusMapperExtension on HomeStatus {
  String toValue() {
    HomeStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<HomeStatus>(this) as String;
  }
}

class HomeEventMapper extends ClassMapperBase<HomeEvent> {
  HomeEventMapper._();

  static HomeEventMapper? _instance;
  static HomeEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HomeEventMapper._());
      HomeSubscriptionRequestedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'HomeEvent';

  @override
  final MappableFields<HomeEvent> fields = const {};

  static HomeEvent _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('HomeEvent');
  }

  @override
  final Function instantiate = _instantiate;

  static HomeEvent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HomeEvent>(map);
  }

  static HomeEvent fromJson(String json) {
    return ensureInitialized().decodeJson<HomeEvent>(json);
  }
}

mixin HomeEventMappable {
  String toJson();
  Map<String, dynamic> toMap();
  HomeEventCopyWith<HomeEvent, HomeEvent, HomeEvent> get copyWith;
}

abstract class HomeEventCopyWith<$R, $In extends HomeEvent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  HomeEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class HomeSubscriptionRequestedMapper
    extends ClassMapperBase<HomeSubscriptionRequested> {
  HomeSubscriptionRequestedMapper._();

  static HomeSubscriptionRequestedMapper? _instance;
  static HomeSubscriptionRequestedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = HomeSubscriptionRequestedMapper._(),
      );
      HomeEventMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'HomeSubscriptionRequested';

  @override
  final MappableFields<HomeSubscriptionRequested> fields = const {};

  static HomeSubscriptionRequested _instantiate(DecodingData data) {
    return HomeSubscriptionRequested();
  }

  @override
  final Function instantiate = _instantiate;

  static HomeSubscriptionRequested fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HomeSubscriptionRequested>(map);
  }

  static HomeSubscriptionRequested fromJson(String json) {
    return ensureInitialized().decodeJson<HomeSubscriptionRequested>(json);
  }
}

mixin HomeSubscriptionRequestedMappable {
  String toJson() {
    return HomeSubscriptionRequestedMapper.ensureInitialized()
        .encodeJson<HomeSubscriptionRequested>(
          this as HomeSubscriptionRequested,
        );
  }

  Map<String, dynamic> toMap() {
    return HomeSubscriptionRequestedMapper.ensureInitialized()
        .encodeMap<HomeSubscriptionRequested>(
          this as HomeSubscriptionRequested,
        );
  }

  HomeSubscriptionRequestedCopyWith<
    HomeSubscriptionRequested,
    HomeSubscriptionRequested,
    HomeSubscriptionRequested
  >
  get copyWith =>
      _HomeSubscriptionRequestedCopyWithImpl<
        HomeSubscriptionRequested,
        HomeSubscriptionRequested
      >(this as HomeSubscriptionRequested, $identity, $identity);
  @override
  String toString() {
    return HomeSubscriptionRequestedMapper.ensureInitialized().stringifyValue(
      this as HomeSubscriptionRequested,
    );
  }

  @override
  bool operator ==(Object other) {
    return HomeSubscriptionRequestedMapper.ensureInitialized().equalsValue(
      this as HomeSubscriptionRequested,
      other,
    );
  }

  @override
  int get hashCode {
    return HomeSubscriptionRequestedMapper.ensureInitialized().hashValue(
      this as HomeSubscriptionRequested,
    );
  }
}

extension HomeSubscriptionRequestedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HomeSubscriptionRequested, $Out> {
  HomeSubscriptionRequestedCopyWith<$R, HomeSubscriptionRequested, $Out>
  get $asHomeSubscriptionRequested => $base.as(
    (v, t, t2) => _HomeSubscriptionRequestedCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class HomeSubscriptionRequestedCopyWith<
  $R,
  $In extends HomeSubscriptionRequested,
  $Out
>
    implements HomeEventCopyWith<$R, $In, $Out> {
  @override
  $R call();
  HomeSubscriptionRequestedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _HomeSubscriptionRequestedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HomeSubscriptionRequested, $Out>
    implements
        HomeSubscriptionRequestedCopyWith<$R, HomeSubscriptionRequested, $Out> {
  _HomeSubscriptionRequestedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HomeSubscriptionRequested> $mapper =
      HomeSubscriptionRequestedMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  HomeSubscriptionRequested $make(CopyWithData data) =>
      HomeSubscriptionRequested();

  @override
  HomeSubscriptionRequestedCopyWith<$R2, HomeSubscriptionRequested, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _HomeSubscriptionRequestedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class HomeStateMapper extends ClassMapperBase<HomeState> {
  HomeStateMapper._();

  static HomeStateMapper? _instance;
  static HomeStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HomeStateMapper._());
      HomeStatusMapper.ensureInitialized();
      OrderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'HomeState';

  static HomeStatus _$status(HomeState v) => v.status;
  static const Field<HomeState, HomeStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: HomeStatus.loading,
  );
  static List<Order> _$orders(HomeState v) => v.orders;
  static const Field<HomeState, List<Order>> _f$orders = Field(
    'orders',
    _$orders,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<HomeState> fields = const {
    #status: _f$status,
    #orders: _f$orders,
  };

  static HomeState _instantiate(DecodingData data) {
    return HomeState(status: data.dec(_f$status), orders: data.dec(_f$orders));
  }

  @override
  final Function instantiate = _instantiate;

  static HomeState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HomeState>(map);
  }

  static HomeState fromJson(String json) {
    return ensureInitialized().decodeJson<HomeState>(json);
  }
}

mixin HomeStateMappable {
  String toJson() {
    return HomeStateMapper.ensureInitialized().encodeJson<HomeState>(
      this as HomeState,
    );
  }

  Map<String, dynamic> toMap() {
    return HomeStateMapper.ensureInitialized().encodeMap<HomeState>(
      this as HomeState,
    );
  }

  HomeStateCopyWith<HomeState, HomeState, HomeState> get copyWith =>
      _HomeStateCopyWithImpl<HomeState, HomeState>(
        this as HomeState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HomeStateMapper.ensureInitialized().stringifyValue(
      this as HomeState,
    );
  }

  @override
  bool operator ==(Object other) {
    return HomeStateMapper.ensureInitialized().equalsValue(
      this as HomeState,
      other,
    );
  }

  @override
  int get hashCode {
    return HomeStateMapper.ensureInitialized().hashValue(this as HomeState);
  }
}

extension HomeStateValueCopy<$R, $Out> on ObjectCopyWith<$R, HomeState, $Out> {
  HomeStateCopyWith<$R, HomeState, $Out> get $asHomeState =>
      $base.as((v, t, t2) => _HomeStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HomeStateCopyWith<$R, $In extends HomeState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get orders;
  $R call({HomeStatus? status, List<Order>? orders});
  HomeStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _HomeStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HomeState, $Out>
    implements HomeStateCopyWith<$R, HomeState, $Out> {
  _HomeStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HomeState> $mapper =
      HomeStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get orders =>
      ListCopyWith(
        $value.orders,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(orders: v),
      );
  @override
  $R call({HomeStatus? status, List<Order>? orders}) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (orders != null) #orders: orders,
    }),
  );
  @override
  HomeState $make(CopyWithData data) => HomeState(
    status: data.get(#status, or: $value.status),
    orders: data.get(#orders, or: $value.orders),
  );

  @override
  HomeStateCopyWith<$R2, HomeState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _HomeStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

