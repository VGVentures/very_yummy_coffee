// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cart_bloc.dart';

class CartStatusMapper extends EnumMapper<CartStatus> {
  CartStatusMapper._();

  static CartStatusMapper? _instance;
  static CartStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartStatusMapper._());
    }
    return _instance!;
  }

  static CartStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  CartStatus decode(dynamic value) {
    switch (value) {
      case r'loading':
        return CartStatus.loading;
      case r'success':
        return CartStatus.success;
      case r'failure':
        return CartStatus.failure;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(CartStatus self) {
    switch (self) {
      case CartStatus.loading:
        return r'loading';
      case CartStatus.success:
        return r'success';
      case CartStatus.failure:
        return r'failure';
    }
  }
}

extension CartStatusMapperExtension on CartStatus {
  String toValue() {
    CartStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<CartStatus>(this) as String;
  }
}

class CartEventMapper extends ClassMapperBase<CartEvent> {
  CartEventMapper._();

  static CartEventMapper? _instance;
  static CartEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartEventMapper._());
      CartSubscriptionRequestedMapper.ensureInitialized();
      CartItemQuantityUpdatedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CartEvent';

  @override
  final MappableFields<CartEvent> fields = const {};

  static CartEvent _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('CartEvent');
  }

  @override
  final Function instantiate = _instantiate;

  static CartEvent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartEvent>(map);
  }

  static CartEvent fromJson(String json) {
    return ensureInitialized().decodeJson<CartEvent>(json);
  }
}

mixin CartEventMappable {
  String toJson();
  Map<String, dynamic> toMap();
  CartEventCopyWith<CartEvent, CartEvent, CartEvent> get copyWith;
}

abstract class CartEventCopyWith<$R, $In extends CartEvent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  CartEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class CartSubscriptionRequestedMapper
    extends ClassMapperBase<CartSubscriptionRequested> {
  CartSubscriptionRequestedMapper._();

  static CartSubscriptionRequestedMapper? _instance;
  static CartSubscriptionRequestedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = CartSubscriptionRequestedMapper._(),
      );
      CartEventMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CartSubscriptionRequested';

  @override
  final MappableFields<CartSubscriptionRequested> fields = const {};

  static CartSubscriptionRequested _instantiate(DecodingData data) {
    return CartSubscriptionRequested();
  }

  @override
  final Function instantiate = _instantiate;

  static CartSubscriptionRequested fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartSubscriptionRequested>(map);
  }

  static CartSubscriptionRequested fromJson(String json) {
    return ensureInitialized().decodeJson<CartSubscriptionRequested>(json);
  }
}

mixin CartSubscriptionRequestedMappable {
  String toJson() {
    return CartSubscriptionRequestedMapper.ensureInitialized()
        .encodeJson<CartSubscriptionRequested>(
          this as CartSubscriptionRequested,
        );
  }

  Map<String, dynamic> toMap() {
    return CartSubscriptionRequestedMapper.ensureInitialized()
        .encodeMap<CartSubscriptionRequested>(
          this as CartSubscriptionRequested,
        );
  }

  CartSubscriptionRequestedCopyWith<
    CartSubscriptionRequested,
    CartSubscriptionRequested,
    CartSubscriptionRequested
  >
  get copyWith =>
      _CartSubscriptionRequestedCopyWithImpl<
        CartSubscriptionRequested,
        CartSubscriptionRequested
      >(this as CartSubscriptionRequested, $identity, $identity);
  @override
  String toString() {
    return CartSubscriptionRequestedMapper.ensureInitialized().stringifyValue(
      this as CartSubscriptionRequested,
    );
  }

  @override
  bool operator ==(Object other) {
    return CartSubscriptionRequestedMapper.ensureInitialized().equalsValue(
      this as CartSubscriptionRequested,
      other,
    );
  }

  @override
  int get hashCode {
    return CartSubscriptionRequestedMapper.ensureInitialized().hashValue(
      this as CartSubscriptionRequested,
    );
  }
}

extension CartSubscriptionRequestedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CartSubscriptionRequested, $Out> {
  CartSubscriptionRequestedCopyWith<$R, CartSubscriptionRequested, $Out>
  get $asCartSubscriptionRequested => $base.as(
    (v, t, t2) => _CartSubscriptionRequestedCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CartSubscriptionRequestedCopyWith<
  $R,
  $In extends CartSubscriptionRequested,
  $Out
>
    implements CartEventCopyWith<$R, $In, $Out> {
  @override
  $R call();
  CartSubscriptionRequestedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CartSubscriptionRequestedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartSubscriptionRequested, $Out>
    implements
        CartSubscriptionRequestedCopyWith<$R, CartSubscriptionRequested, $Out> {
  _CartSubscriptionRequestedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartSubscriptionRequested> $mapper =
      CartSubscriptionRequestedMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  CartSubscriptionRequested $make(CopyWithData data) =>
      CartSubscriptionRequested();

  @override
  CartSubscriptionRequestedCopyWith<$R2, CartSubscriptionRequested, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CartSubscriptionRequestedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CartItemQuantityUpdatedMapper
    extends ClassMapperBase<CartItemQuantityUpdated> {
  CartItemQuantityUpdatedMapper._();

  static CartItemQuantityUpdatedMapper? _instance;
  static CartItemQuantityUpdatedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = CartItemQuantityUpdatedMapper._(),
      );
      CartEventMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CartItemQuantityUpdated';

  static String _$lineItemId(CartItemQuantityUpdated v) => v.lineItemId;
  static const Field<CartItemQuantityUpdated, String> _f$lineItemId = Field(
    'lineItemId',
    _$lineItemId,
  );
  static int _$quantity(CartItemQuantityUpdated v) => v.quantity;
  static const Field<CartItemQuantityUpdated, int> _f$quantity = Field(
    'quantity',
    _$quantity,
  );

  @override
  final MappableFields<CartItemQuantityUpdated> fields = const {
    #lineItemId: _f$lineItemId,
    #quantity: _f$quantity,
  };

  static CartItemQuantityUpdated _instantiate(DecodingData data) {
    return CartItemQuantityUpdated(
      lineItemId: data.dec(_f$lineItemId),
      quantity: data.dec(_f$quantity),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CartItemQuantityUpdated fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartItemQuantityUpdated>(map);
  }

  static CartItemQuantityUpdated fromJson(String json) {
    return ensureInitialized().decodeJson<CartItemQuantityUpdated>(json);
  }
}

mixin CartItemQuantityUpdatedMappable {
  String toJson() {
    return CartItemQuantityUpdatedMapper.ensureInitialized()
        .encodeJson<CartItemQuantityUpdated>(this as CartItemQuantityUpdated);
  }

  Map<String, dynamic> toMap() {
    return CartItemQuantityUpdatedMapper.ensureInitialized()
        .encodeMap<CartItemQuantityUpdated>(this as CartItemQuantityUpdated);
  }

  CartItemQuantityUpdatedCopyWith<
    CartItemQuantityUpdated,
    CartItemQuantityUpdated,
    CartItemQuantityUpdated
  >
  get copyWith =>
      _CartItemQuantityUpdatedCopyWithImpl<
        CartItemQuantityUpdated,
        CartItemQuantityUpdated
      >(this as CartItemQuantityUpdated, $identity, $identity);
  @override
  String toString() {
    return CartItemQuantityUpdatedMapper.ensureInitialized().stringifyValue(
      this as CartItemQuantityUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    return CartItemQuantityUpdatedMapper.ensureInitialized().equalsValue(
      this as CartItemQuantityUpdated,
      other,
    );
  }

  @override
  int get hashCode {
    return CartItemQuantityUpdatedMapper.ensureInitialized().hashValue(
      this as CartItemQuantityUpdated,
    );
  }
}

extension CartItemQuantityUpdatedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CartItemQuantityUpdated, $Out> {
  CartItemQuantityUpdatedCopyWith<$R, CartItemQuantityUpdated, $Out>
  get $asCartItemQuantityUpdated => $base.as(
    (v, t, t2) => _CartItemQuantityUpdatedCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CartItemQuantityUpdatedCopyWith<
  $R,
  $In extends CartItemQuantityUpdated,
  $Out
>
    implements CartEventCopyWith<$R, $In, $Out> {
  @override
  $R call({String? lineItemId, int? quantity});
  CartItemQuantityUpdatedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CartItemQuantityUpdatedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartItemQuantityUpdated, $Out>
    implements
        CartItemQuantityUpdatedCopyWith<$R, CartItemQuantityUpdated, $Out> {
  _CartItemQuantityUpdatedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartItemQuantityUpdated> $mapper =
      CartItemQuantityUpdatedMapper.ensureInitialized();
  @override
  $R call({String? lineItemId, int? quantity}) => $apply(
    FieldCopyWithData({
      if (lineItemId != null) #lineItemId: lineItemId,
      if (quantity != null) #quantity: quantity,
    }),
  );
  @override
  CartItemQuantityUpdated $make(CopyWithData data) => CartItemQuantityUpdated(
    lineItemId: data.get(#lineItemId, or: $value.lineItemId),
    quantity: data.get(#quantity, or: $value.quantity),
  );

  @override
  CartItemQuantityUpdatedCopyWith<$R2, CartItemQuantityUpdated, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CartItemQuantityUpdatedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CartStateMapper extends ClassMapperBase<CartState> {
  CartStateMapper._();

  static CartStateMapper? _instance;
  static CartStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartStateMapper._());
      OrderMapper.ensureInitialized();
      CartStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CartState';

  static Order? _$order(CartState v) => v.order;
  static const Field<CartState, Order> _f$order = Field(
    'order',
    _$order,
    opt: true,
  );
  static CartStatus _$status(CartState v) => v.status;
  static const Field<CartState, CartStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: CartStatus.loading,
  );

  @override
  final MappableFields<CartState> fields = const {
    #order: _f$order,
    #status: _f$status,
  };

  static CartState _instantiate(DecodingData data) {
    return CartState(order: data.dec(_f$order), status: data.dec(_f$status));
  }

  @override
  final Function instantiate = _instantiate;

  static CartState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartState>(map);
  }

  static CartState fromJson(String json) {
    return ensureInitialized().decodeJson<CartState>(json);
  }
}

mixin CartStateMappable {
  String toJson() {
    return CartStateMapper.ensureInitialized().encodeJson<CartState>(
      this as CartState,
    );
  }

  Map<String, dynamic> toMap() {
    return CartStateMapper.ensureInitialized().encodeMap<CartState>(
      this as CartState,
    );
  }

  CartStateCopyWith<CartState, CartState, CartState> get copyWith =>
      _CartStateCopyWithImpl<CartState, CartState>(
        this as CartState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CartStateMapper.ensureInitialized().stringifyValue(
      this as CartState,
    );
  }

  @override
  bool operator ==(Object other) {
    return CartStateMapper.ensureInitialized().equalsValue(
      this as CartState,
      other,
    );
  }

  @override
  int get hashCode {
    return CartStateMapper.ensureInitialized().hashValue(this as CartState);
  }
}

extension CartStateValueCopy<$R, $Out> on ObjectCopyWith<$R, CartState, $Out> {
  CartStateCopyWith<$R, CartState, $Out> get $asCartState =>
      $base.as((v, t, t2) => _CartStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CartStateCopyWith<$R, $In extends CartState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  OrderCopyWith<$R, Order, Order>? get order;
  $R call({Order? order, CartStatus? status});
  CartStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CartStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartState, $Out>
    implements CartStateCopyWith<$R, CartState, $Out> {
  _CartStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartState> $mapper =
      CartStateMapper.ensureInitialized();
  @override
  OrderCopyWith<$R, Order, Order>? get order =>
      $value.order?.copyWith.$chain((v) => call(order: v));
  @override
  $R call({Object? order = $none, CartStatus? status}) => $apply(
    FieldCopyWithData({
      if (order != $none) #order: order,
      if (status != null) #status: status,
    }),
  );
  @override
  CartState $make(CopyWithData data) => CartState(
    order: data.get(#order, or: $value.order),
    status: data.get(#status, or: $value.status),
  );

  @override
  CartStateCopyWith<$R2, CartState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CartStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

