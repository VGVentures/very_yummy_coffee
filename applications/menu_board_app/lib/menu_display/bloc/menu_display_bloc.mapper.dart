// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_display_bloc.dart';

class MenuDisplayStateMapper extends ClassMapperBase<MenuDisplayState> {
  MenuDisplayStateMapper._();

  static MenuDisplayStateMapper? _instance;
  static MenuDisplayStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuDisplayStateMapper._());
      MenuGroupMapper.ensureInitialized();
      MenuItemMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MenuDisplayState';

  static MenuDisplayStatus _$status(MenuDisplayState v) => v.status;
  static const Field<MenuDisplayState, MenuDisplayStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: MenuDisplayStatus.initial,
  );
  static List<MenuGroup> _$groups(MenuDisplayState v) => v.groups;
  static const Field<MenuDisplayState, List<MenuGroup>> _f$groups = Field(
    'groups',
    _$groups,
    opt: true,
    def: const [],
  );
  static List<MenuItem> _$items(MenuDisplayState v) => v.items;
  static const Field<MenuDisplayState, List<MenuItem>> _f$items = Field(
    'items',
    _$items,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<MenuDisplayState> fields = const {
    #status: _f$status,
    #groups: _f$groups,
    #items: _f$items,
  };

  static MenuDisplayState _instantiate(DecodingData data) {
    return MenuDisplayState(
      status: data.dec(_f$status),
      groups: data.dec(_f$groups),
      items: data.dec(_f$items),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MenuDisplayState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuDisplayState>(map);
  }

  static MenuDisplayState fromJson(String json) {
    return ensureInitialized().decodeJson<MenuDisplayState>(json);
  }
}

mixin MenuDisplayStateMappable {
  String toJson() {
    return MenuDisplayStateMapper.ensureInitialized()
        .encodeJson<MenuDisplayState>(this as MenuDisplayState);
  }

  Map<String, dynamic> toMap() {
    return MenuDisplayStateMapper.ensureInitialized()
        .encodeMap<MenuDisplayState>(this as MenuDisplayState);
  }

  MenuDisplayStateCopyWith<MenuDisplayState, MenuDisplayState, MenuDisplayState>
  get copyWith =>
      _MenuDisplayStateCopyWithImpl<MenuDisplayState, MenuDisplayState>(
        this as MenuDisplayState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MenuDisplayStateMapper.ensureInitialized().stringifyValue(
      this as MenuDisplayState,
    );
  }

  @override
  bool operator ==(Object other) {
    return MenuDisplayStateMapper.ensureInitialized().equalsValue(
      this as MenuDisplayState,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuDisplayStateMapper.ensureInitialized().hashValue(
      this as MenuDisplayState,
    );
  }
}

extension MenuDisplayStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MenuDisplayState, $Out> {
  MenuDisplayStateCopyWith<$R, MenuDisplayState, $Out>
  get $asMenuDisplayState =>
      $base.as((v, t, t2) => _MenuDisplayStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuDisplayStateCopyWith<$R, $In extends MenuDisplayState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, MenuGroup, MenuGroupCopyWith<$R, MenuGroup, MenuGroup>>
  get groups;
  ListCopyWith<$R, MenuItem, MenuItemCopyWith<$R, MenuItem, MenuItem>>
  get items;
  $R call({
    MenuDisplayStatus? status,
    List<MenuGroup>? groups,
    List<MenuItem>? items,
  });
  MenuDisplayStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MenuDisplayStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuDisplayState, $Out>
    implements MenuDisplayStateCopyWith<$R, MenuDisplayState, $Out> {
  _MenuDisplayStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuDisplayState> $mapper =
      MenuDisplayStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, MenuGroup, MenuGroupCopyWith<$R, MenuGroup, MenuGroup>>
  get groups => ListCopyWith(
    $value.groups,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(groups: v),
  );
  @override
  ListCopyWith<$R, MenuItem, MenuItemCopyWith<$R, MenuItem, MenuItem>>
  get items => ListCopyWith(
    $value.items,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(items: v),
  );
  @override
  $R call({
    MenuDisplayStatus? status,
    List<MenuGroup>? groups,
    List<MenuItem>? items,
  }) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (groups != null) #groups: groups,
      if (items != null) #items: items,
    }),
  );
  @override
  MenuDisplayState $make(CopyWithData data) => MenuDisplayState(
    status: data.get(#status, or: $value.status),
    groups: data.get(#groups, or: $value.groups),
    items: data.get(#items, or: $value.items),
  );

  @override
  MenuDisplayStateCopyWith<$R2, MenuDisplayState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MenuDisplayStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

