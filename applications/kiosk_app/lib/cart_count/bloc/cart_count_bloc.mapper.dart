// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cart_count_bloc.dart';

class CartCountEventMapper extends ClassMapperBase<CartCountEvent> {
  CartCountEventMapper._();

  static CartCountEventMapper? _instance;
  static CartCountEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartCountEventMapper._());
      CartCountSubscriptionRequestedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CartCountEvent';

  @override
  final MappableFields<CartCountEvent> fields = const {};

  static CartCountEvent _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('CartCountEvent');
  }

  @override
  final Function instantiate = _instantiate;

  static CartCountEvent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartCountEvent>(map);
  }

  static CartCountEvent fromJson(String json) {
    return ensureInitialized().decodeJson<CartCountEvent>(json);
  }
}

mixin CartCountEventMappable {
  String toJson();
  Map<String, dynamic> toMap();
  CartCountEventCopyWith<CartCountEvent, CartCountEvent, CartCountEvent>
  get copyWith;
}

abstract class CartCountEventCopyWith<$R, $In extends CartCountEvent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  CartCountEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class CartCountSubscriptionRequestedMapper
    extends ClassMapperBase<CartCountSubscriptionRequested> {
  CartCountSubscriptionRequestedMapper._();

  static CartCountSubscriptionRequestedMapper? _instance;
  static CartCountSubscriptionRequestedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = CartCountSubscriptionRequestedMapper._(),
      );
      CartCountEventMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CartCountSubscriptionRequested';

  @override
  final MappableFields<CartCountSubscriptionRequested> fields = const {};

  static CartCountSubscriptionRequested _instantiate(DecodingData data) {
    return CartCountSubscriptionRequested();
  }

  @override
  final Function instantiate = _instantiate;

  static CartCountSubscriptionRequested fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartCountSubscriptionRequested>(map);
  }

  static CartCountSubscriptionRequested fromJson(String json) {
    return ensureInitialized().decodeJson<CartCountSubscriptionRequested>(json);
  }
}

mixin CartCountSubscriptionRequestedMappable {
  String toJson() {
    return CartCountSubscriptionRequestedMapper.ensureInitialized()
        .encodeJson<CartCountSubscriptionRequested>(
          this as CartCountSubscriptionRequested,
        );
  }

  Map<String, dynamic> toMap() {
    return CartCountSubscriptionRequestedMapper.ensureInitialized()
        .encodeMap<CartCountSubscriptionRequested>(
          this as CartCountSubscriptionRequested,
        );
  }

  CartCountSubscriptionRequestedCopyWith<
    CartCountSubscriptionRequested,
    CartCountSubscriptionRequested,
    CartCountSubscriptionRequested
  >
  get copyWith =>
      _CartCountSubscriptionRequestedCopyWithImpl<
        CartCountSubscriptionRequested,
        CartCountSubscriptionRequested
      >(this as CartCountSubscriptionRequested, $identity, $identity);
  @override
  String toString() {
    return CartCountSubscriptionRequestedMapper.ensureInitialized()
        .stringifyValue(this as CartCountSubscriptionRequested);
  }

  @override
  bool operator ==(Object other) {
    return CartCountSubscriptionRequestedMapper.ensureInitialized().equalsValue(
      this as CartCountSubscriptionRequested,
      other,
    );
  }

  @override
  int get hashCode {
    return CartCountSubscriptionRequestedMapper.ensureInitialized().hashValue(
      this as CartCountSubscriptionRequested,
    );
  }
}

extension CartCountSubscriptionRequestedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CartCountSubscriptionRequested, $Out> {
  CartCountSubscriptionRequestedCopyWith<
    $R,
    CartCountSubscriptionRequested,
    $Out
  >
  get $asCartCountSubscriptionRequested => $base.as(
    (v, t, t2) =>
        _CartCountSubscriptionRequestedCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CartCountSubscriptionRequestedCopyWith<
  $R,
  $In extends CartCountSubscriptionRequested,
  $Out
>
    implements CartCountEventCopyWith<$R, $In, $Out> {
  @override
  $R call();
  CartCountSubscriptionRequestedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CartCountSubscriptionRequestedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartCountSubscriptionRequested, $Out>
    implements
        CartCountSubscriptionRequestedCopyWith<
          $R,
          CartCountSubscriptionRequested,
          $Out
        > {
  _CartCountSubscriptionRequestedCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<CartCountSubscriptionRequested> $mapper =
      CartCountSubscriptionRequestedMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  CartCountSubscriptionRequested $make(CopyWithData data) =>
      CartCountSubscriptionRequested();

  @override
  CartCountSubscriptionRequestedCopyWith<
    $R2,
    CartCountSubscriptionRequested,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CartCountSubscriptionRequestedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CartCountStateMapper extends ClassMapperBase<CartCountState> {
  CartCountStateMapper._();

  static CartCountStateMapper? _instance;
  static CartCountStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartCountStateMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CartCountState';

  static int _$itemCount(CartCountState v) => v.itemCount;
  static const Field<CartCountState, int> _f$itemCount = Field(
    'itemCount',
    _$itemCount,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<CartCountState> fields = const {
    #itemCount: _f$itemCount,
  };

  static CartCountState _instantiate(DecodingData data) {
    return CartCountState(itemCount: data.dec(_f$itemCount));
  }

  @override
  final Function instantiate = _instantiate;

  static CartCountState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartCountState>(map);
  }

  static CartCountState fromJson(String json) {
    return ensureInitialized().decodeJson<CartCountState>(json);
  }
}

mixin CartCountStateMappable {
  String toJson() {
    return CartCountStateMapper.ensureInitialized().encodeJson<CartCountState>(
      this as CartCountState,
    );
  }

  Map<String, dynamic> toMap() {
    return CartCountStateMapper.ensureInitialized().encodeMap<CartCountState>(
      this as CartCountState,
    );
  }

  CartCountStateCopyWith<CartCountState, CartCountState, CartCountState>
  get copyWith => _CartCountStateCopyWithImpl<CartCountState, CartCountState>(
    this as CartCountState,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return CartCountStateMapper.ensureInitialized().stringifyValue(
      this as CartCountState,
    );
  }

  @override
  bool operator ==(Object other) {
    return CartCountStateMapper.ensureInitialized().equalsValue(
      this as CartCountState,
      other,
    );
  }

  @override
  int get hashCode {
    return CartCountStateMapper.ensureInitialized().hashValue(
      this as CartCountState,
    );
  }
}

extension CartCountStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CartCountState, $Out> {
  CartCountStateCopyWith<$R, CartCountState, $Out> get $asCartCountState =>
      $base.as((v, t, t2) => _CartCountStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CartCountStateCopyWith<$R, $In extends CartCountState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? itemCount});
  CartCountStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CartCountStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartCountState, $Out>
    implements CartCountStateCopyWith<$R, CartCountState, $Out> {
  _CartCountStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartCountState> $mapper =
      CartCountStateMapper.ensureInitialized();
  @override
  $R call({int? itemCount}) =>
      $apply(FieldCopyWithData({if (itemCount != null) #itemCount: itemCount}));
  @override
  CartCountState $make(CopyWithData data) =>
      CartCountState(itemCount: data.get(#itemCount, or: $value.itemCount));

  @override
  CartCountStateCopyWith<$R2, CartCountState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CartCountStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

