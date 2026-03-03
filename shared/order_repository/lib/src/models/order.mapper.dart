// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'order.dart';

class OrderStatusMapper extends EnumMapper<OrderStatus> {
  OrderStatusMapper._();

  static OrderStatusMapper? _instance;
  static OrderStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderStatusMapper._());
    }
    return _instance!;
  }

  static OrderStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  OrderStatus decode(dynamic value) {
    switch (value) {
      case r'pending':
        return OrderStatus.pending;
      case r'submitted':
        return OrderStatus.submitted;
      case r'inProgress':
        return OrderStatus.inProgress;
      case r'ready':
        return OrderStatus.ready;
      case r'completed':
        return OrderStatus.completed;
      case r'cancelled':
        return OrderStatus.cancelled;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(OrderStatus self) {
    switch (self) {
      case OrderStatus.pending:
        return r'pending';
      case OrderStatus.submitted:
        return r'submitted';
      case OrderStatus.inProgress:
        return r'inProgress';
      case OrderStatus.ready:
        return r'ready';
      case OrderStatus.completed:
        return r'completed';
      case OrderStatus.cancelled:
        return r'cancelled';
    }
  }
}

extension OrderStatusMapperExtension on OrderStatus {
  String toValue() {
    OrderStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<OrderStatus>(this) as String;
  }
}

class OrderMapper extends ClassMapperBase<Order> {
  OrderMapper._();

  static OrderMapper? _instance;
  static OrderMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrderMapper._());
      LineItemMapper.ensureInitialized();
      OrderStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Order';

  static String _$id(Order v) => v.id;
  static const Field<Order, String> _f$id = Field('id', _$id);
  static List<LineItem> _$items(Order v) => v.items;
  static const Field<Order, List<LineItem>> _f$items = Field('items', _$items);
  static OrderStatus _$status(Order v) => v.status;
  static const Field<Order, OrderStatus> _f$status = Field('status', _$status);
  static DateTime? _$submittedAt(Order v) => v.submittedAt;
  static const Field<Order, DateTime> _f$submittedAt = Field(
    'submittedAt',
    _$submittedAt,
    opt: true,
  );

  @override
  final MappableFields<Order> fields = const {
    #id: _f$id,
    #items: _f$items,
    #status: _f$status,
    #submittedAt: _f$submittedAt,
  };

  static Order _instantiate(DecodingData data) {
    return Order(
      id: data.dec(_f$id),
      items: data.dec(_f$items),
      status: data.dec(_f$status),
      submittedAt: data.dec(_f$submittedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Order fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Order>(map);
  }

  static Order fromJson(String json) {
    return ensureInitialized().decodeJson<Order>(json);
  }
}

mixin OrderMappable {
  String toJson() {
    return OrderMapper.ensureInitialized().encodeJson<Order>(this as Order);
  }

  Map<String, dynamic> toMap() {
    return OrderMapper.ensureInitialized().encodeMap<Order>(this as Order);
  }

  OrderCopyWith<Order, Order, Order> get copyWith =>
      _OrderCopyWithImpl<Order, Order>(this as Order, $identity, $identity);
  @override
  String toString() {
    return OrderMapper.ensureInitialized().stringifyValue(this as Order);
  }

  @override
  bool operator ==(Object other) {
    return OrderMapper.ensureInitialized().equalsValue(this as Order, other);
  }

  @override
  int get hashCode {
    return OrderMapper.ensureInitialized().hashValue(this as Order);
  }
}

extension OrderValueCopy<$R, $Out> on ObjectCopyWith<$R, Order, $Out> {
  OrderCopyWith<$R, Order, $Out> get $asOrder =>
      $base.as((v, t, t2) => _OrderCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrderCopyWith<$R, $In extends Order, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, LineItem, LineItemCopyWith<$R, LineItem, LineItem>>
  get items;
  $R call({
    String? id,
    List<LineItem>? items,
    OrderStatus? status,
    DateTime? submittedAt,
  });
  OrderCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OrderCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Order, $Out>
    implements OrderCopyWith<$R, Order, $Out> {
  _OrderCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Order> $mapper = OrderMapper.ensureInitialized();
  @override
  ListCopyWith<$R, LineItem, LineItemCopyWith<$R, LineItem, LineItem>>
  get items => ListCopyWith(
    $value.items,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(items: v),
  );
  @override
  $R call({
    String? id,
    List<LineItem>? items,
    OrderStatus? status,
    Object? submittedAt = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (items != null) #items: items,
      if (status != null) #status: status,
      if (submittedAt != $none) #submittedAt: submittedAt,
    }),
  );
  @override
  Order $make(CopyWithData data) => Order(
    id: data.get(#id, or: $value.id),
    items: data.get(#items, or: $value.items),
    status: data.get(#status, or: $value.status),
    submittedAt: data.get(#submittedAt, or: $value.submittedAt),
  );

  @override
  OrderCopyWith<$R2, Order, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrderCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class OrdersMapper extends ClassMapperBase<Orders> {
  OrdersMapper._();

  static OrdersMapper? _instance;
  static OrdersMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrdersMapper._());
      OrderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Orders';

  static List<Order> _$orders(Orders v) => v.orders;
  static const Field<Orders, List<Order>> _f$orders = Field('orders', _$orders);

  @override
  final MappableFields<Orders> fields = const {#orders: _f$orders};

  static Orders _instantiate(DecodingData data) {
    return Orders(orders: data.dec(_f$orders));
  }

  @override
  final Function instantiate = _instantiate;

  static Orders fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Orders>(map);
  }

  static Orders fromJson(String json) {
    return ensureInitialized().decodeJson<Orders>(json);
  }
}

mixin OrdersMappable {
  String toJson() {
    return OrdersMapper.ensureInitialized().encodeJson<Orders>(this as Orders);
  }

  Map<String, dynamic> toMap() {
    return OrdersMapper.ensureInitialized().encodeMap<Orders>(this as Orders);
  }

  OrdersCopyWith<Orders, Orders, Orders> get copyWith =>
      _OrdersCopyWithImpl<Orders, Orders>(this as Orders, $identity, $identity);
  @override
  String toString() {
    return OrdersMapper.ensureInitialized().stringifyValue(this as Orders);
  }

  @override
  bool operator ==(Object other) {
    return OrdersMapper.ensureInitialized().equalsValue(this as Orders, other);
  }

  @override
  int get hashCode {
    return OrdersMapper.ensureInitialized().hashValue(this as Orders);
  }
}

extension OrdersValueCopy<$R, $Out> on ObjectCopyWith<$R, Orders, $Out> {
  OrdersCopyWith<$R, Orders, $Out> get $asOrders =>
      $base.as((v, t, t2) => _OrdersCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrdersCopyWith<$R, $In extends Orders, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get orders;
  $R call({List<Order>? orders});
  OrdersCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OrdersCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Orders, $Out>
    implements OrdersCopyWith<$R, Orders, $Out> {
  _OrdersCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Orders> $mapper = OrdersMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Order, OrderCopyWith<$R, Order, Order>> get orders =>
      ListCopyWith(
        $value.orders,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(orders: v),
      );
  @override
  $R call({List<Order>? orders}) =>
      $apply(FieldCopyWithData({if (orders != null) #orders: orders}));
  @override
  Orders $make(CopyWithData data) =>
      Orders(orders: data.get(#orders, or: $value.orders));

  @override
  OrdersCopyWith<$R2, Orders, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _OrdersCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

