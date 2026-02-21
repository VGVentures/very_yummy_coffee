// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_group.dart';

class MenuGroupMapper extends ClassMapperBase<MenuGroup> {
  MenuGroupMapper._();

  static MenuGroupMapper? _instance;
  static MenuGroupMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuGroupMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MenuGroup';

  static String _$id(MenuGroup v) => v.id;
  static const Field<MenuGroup, String> _f$id = Field('id', _$id);
  static String _$name(MenuGroup v) => v.name;
  static const Field<MenuGroup, String> _f$name = Field('name', _$name);
  static String _$description(MenuGroup v) => v.description;
  static const Field<MenuGroup, String> _f$description = Field(
    'description',
    _$description,
  );
  static int _$color(MenuGroup v) => v.color;
  static const Field<MenuGroup, int> _f$color = Field('color', _$color);
  static String? _$imageUrl(MenuGroup v) => v.imageUrl;
  static const Field<MenuGroup, String> _f$imageUrl = Field(
    'imageUrl',
    _$imageUrl,
    opt: true,
  );

  @override
  final MappableFields<MenuGroup> fields = const {
    #id: _f$id,
    #name: _f$name,
    #description: _f$description,
    #color: _f$color,
    #imageUrl: _f$imageUrl,
  };

  static MenuGroup _instantiate(DecodingData data) {
    return MenuGroup(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      description: data.dec(_f$description),
      color: data.dec(_f$color),
      imageUrl: data.dec(_f$imageUrl),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MenuGroup fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuGroup>(map);
  }

  static MenuGroup fromJson(String json) {
    return ensureInitialized().decodeJson<MenuGroup>(json);
  }
}

mixin MenuGroupMappable {
  String toJson() {
    return MenuGroupMapper.ensureInitialized().encodeJson<MenuGroup>(
      this as MenuGroup,
    );
  }

  Map<String, dynamic> toMap() {
    return MenuGroupMapper.ensureInitialized().encodeMap<MenuGroup>(
      this as MenuGroup,
    );
  }

  MenuGroupCopyWith<MenuGroup, MenuGroup, MenuGroup> get copyWith =>
      _MenuGroupCopyWithImpl<MenuGroup, MenuGroup>(
        this as MenuGroup,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MenuGroupMapper.ensureInitialized().stringifyValue(
      this as MenuGroup,
    );
  }

  @override
  bool operator ==(Object other) {
    return MenuGroupMapper.ensureInitialized().equalsValue(
      this as MenuGroup,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuGroupMapper.ensureInitialized().hashValue(this as MenuGroup);
  }
}

extension MenuGroupValueCopy<$R, $Out> on ObjectCopyWith<$R, MenuGroup, $Out> {
  MenuGroupCopyWith<$R, MenuGroup, $Out> get $asMenuGroup =>
      $base.as((v, t, t2) => _MenuGroupCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuGroupCopyWith<$R, $In extends MenuGroup, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? description,
    int? color,
    String? imageUrl,
  });
  MenuGroupCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MenuGroupCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuGroup, $Out>
    implements MenuGroupCopyWith<$R, MenuGroup, $Out> {
  _MenuGroupCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuGroup> $mapper =
      MenuGroupMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    String? description,
    int? color,
    Object? imageUrl = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (description != null) #description: description,
      if (color != null) #color: color,
      if (imageUrl != $none) #imageUrl: imageUrl,
    }),
  );
  @override
  MenuGroup $make(CopyWithData data) => MenuGroup(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    description: data.get(#description, or: $value.description),
    color: data.get(#color, or: $value.color),
    imageUrl: data.get(#imageUrl, or: $value.imageUrl),
  );

  @override
  MenuGroupCopyWith<$R2, MenuGroup, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MenuGroupCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

