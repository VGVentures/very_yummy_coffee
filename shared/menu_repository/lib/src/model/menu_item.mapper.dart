// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_item.dart';

class MenuItemMapper extends ClassMapperBase<MenuItem> {
  MenuItemMapper._();

  static MenuItemMapper? _instance;
  static MenuItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuItemMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MenuItem';

  static String _$id(MenuItem v) => v.id;
  static const Field<MenuItem, String> _f$id = Field('id', _$id);
  static String _$name(MenuItem v) => v.name;
  static const Field<MenuItem, String> _f$name = Field('name', _$name);
  static int _$price(MenuItem v) => v.price;
  static const Field<MenuItem, int> _f$price = Field('price', _$price);

  @override
  final MappableFields<MenuItem> fields = const {
    #id: _f$id,
    #name: _f$name,
    #price: _f$price,
  };

  static MenuItem _instantiate(DecodingData data) {
    return MenuItem(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      price: data.dec(_f$price),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MenuItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuItem>(map);
  }

  static MenuItem fromJson(String json) {
    return ensureInitialized().decodeJson<MenuItem>(json);
  }
}

mixin MenuItemMappable {
  String toJson() {
    return MenuItemMapper.ensureInitialized().encodeJson<MenuItem>(
      this as MenuItem,
    );
  }

  Map<String, dynamic> toMap() {
    return MenuItemMapper.ensureInitialized().encodeMap<MenuItem>(
      this as MenuItem,
    );
  }

  MenuItemCopyWith<MenuItem, MenuItem, MenuItem> get copyWith =>
      _MenuItemCopyWithImpl<MenuItem, MenuItem>(
        this as MenuItem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MenuItemMapper.ensureInitialized().stringifyValue(this as MenuItem);
  }

  @override
  bool operator ==(Object other) {
    return MenuItemMapper.ensureInitialized().equalsValue(
      this as MenuItem,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuItemMapper.ensureInitialized().hashValue(this as MenuItem);
  }
}

extension MenuItemValueCopy<$R, $Out> on ObjectCopyWith<$R, MenuItem, $Out> {
  MenuItemCopyWith<$R, MenuItem, $Out> get $asMenuItem =>
      $base.as((v, t, t2) => _MenuItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuItemCopyWith<$R, $In extends MenuItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? name, int? price});
  MenuItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MenuItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuItem, $Out>
    implements MenuItemCopyWith<$R, MenuItem, $Out> {
  _MenuItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuItem> $mapper =
      MenuItemMapper.ensureInitialized();
  @override
  $R call({String? id, String? name, int? price}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (price != null) #price: price,
    }),
  );
  @override
  MenuItem $make(CopyWithData data) => MenuItem(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    price: data.get(#price, or: $value.price),
  );

  @override
  MenuItemCopyWith<$R2, MenuItem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MenuItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

