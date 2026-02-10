// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'line_item.dart';

class LineItemMapper extends ClassMapperBase<LineItem> {
  LineItemMapper._();

  static LineItemMapper? _instance;
  static LineItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LineItemMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LineItem';

  static String _$id(LineItem v) => v.id;
  static const Field<LineItem, String> _f$id = Field('id', _$id);
  static String _$name(LineItem v) => v.name;
  static const Field<LineItem, String> _f$name = Field('name', _$name);
  static int _$price(LineItem v) => v.price;
  static const Field<LineItem, int> _f$price = Field('price', _$price);

  @override
  final MappableFields<LineItem> fields = const {
    #id: _f$id,
    #name: _f$name,
    #price: _f$price,
  };

  static LineItem _instantiate(DecodingData data) {
    return LineItem(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      price: data.dec(_f$price),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LineItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LineItem>(map);
  }

  static LineItem fromJson(String json) {
    return ensureInitialized().decodeJson<LineItem>(json);
  }
}

mixin LineItemMappable {
  String toJson() {
    return LineItemMapper.ensureInitialized().encodeJson<LineItem>(
      this as LineItem,
    );
  }

  Map<String, dynamic> toMap() {
    return LineItemMapper.ensureInitialized().encodeMap<LineItem>(
      this as LineItem,
    );
  }

  LineItemCopyWith<LineItem, LineItem, LineItem> get copyWith =>
      _LineItemCopyWithImpl<LineItem, LineItem>(
        this as LineItem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LineItemMapper.ensureInitialized().stringifyValue(this as LineItem);
  }

  @override
  bool operator ==(Object other) {
    return LineItemMapper.ensureInitialized().equalsValue(
      this as LineItem,
      other,
    );
  }

  @override
  int get hashCode {
    return LineItemMapper.ensureInitialized().hashValue(this as LineItem);
  }
}

extension LineItemValueCopy<$R, $Out> on ObjectCopyWith<$R, LineItem, $Out> {
  LineItemCopyWith<$R, LineItem, $Out> get $asLineItem =>
      $base.as((v, t, t2) => _LineItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LineItemCopyWith<$R, $In extends LineItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? name, int? price});
  LineItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LineItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LineItem, $Out>
    implements LineItemCopyWith<$R, LineItem, $Out> {
  _LineItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LineItem> $mapper =
      LineItemMapper.ensureInitialized();
  @override
  $R call({String? id, String? name, int? price}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (price != null) #price: price,
    }),
  );
  @override
  LineItem $make(CopyWithData data) => LineItem(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    price: data.get(#price, or: $value.price),
  );

  @override
  LineItemCopyWith<$R2, LineItem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LineItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

