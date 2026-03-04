// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_bloc.dart';

class MenuStateMapper extends ClassMapperBase<MenuState> {
  MenuStateMapper._();

  static MenuStateMapper? _instance;
  static MenuStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuStateMapper._());
      MenuGroupMapper.ensureInitialized();
      MenuItemMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MenuState';

  static MenuStatus _$status(MenuState v) => v.status;
  static const Field<MenuState, MenuStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: MenuStatus.loading,
  );
  static List<MenuGroup> _$groups(MenuState v) => v.groups;
  static const Field<MenuState, List<MenuGroup>> _f$groups = Field(
    'groups',
    _$groups,
    opt: true,
    def: const [],
  );
  static List<MenuItem> _$allItems(MenuState v) => v.allItems;
  static const Field<MenuState, List<MenuItem>> _f$allItems = Field(
    'allItems',
    _$allItems,
    opt: true,
    def: const [],
  );
  static String? _$selectedGroupId(MenuState v) => v.selectedGroupId;
  static const Field<MenuState, String> _f$selectedGroupId = Field(
    'selectedGroupId',
    _$selectedGroupId,
    opt: true,
  );

  @override
  final MappableFields<MenuState> fields = const {
    #status: _f$status,
    #groups: _f$groups,
    #allItems: _f$allItems,
    #selectedGroupId: _f$selectedGroupId,
  };

  static MenuState _instantiate(DecodingData data) {
    return MenuState(
      status: data.dec(_f$status),
      groups: data.dec(_f$groups),
      allItems: data.dec(_f$allItems),
      selectedGroupId: data.dec(_f$selectedGroupId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MenuState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuState>(map);
  }

  static MenuState fromJson(String json) {
    return ensureInitialized().decodeJson<MenuState>(json);
  }
}

mixin MenuStateMappable {
  String toJson() {
    return MenuStateMapper.ensureInitialized().encodeJson<MenuState>(
      this as MenuState,
    );
  }

  Map<String, dynamic> toMap() {
    return MenuStateMapper.ensureInitialized().encodeMap<MenuState>(
      this as MenuState,
    );
  }

  MenuStateCopyWith<MenuState, MenuState, MenuState> get copyWith =>
      _MenuStateCopyWithImpl<MenuState, MenuState>(
        this as MenuState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MenuStateMapper.ensureInitialized().stringifyValue(
      this as MenuState,
    );
  }

  @override
  bool operator ==(Object other) {
    return MenuStateMapper.ensureInitialized().equalsValue(
      this as MenuState,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuStateMapper.ensureInitialized().hashValue(this as MenuState);
  }
}

extension MenuStateValueCopy<$R, $Out> on ObjectCopyWith<$R, MenuState, $Out> {
  MenuStateCopyWith<$R, MenuState, $Out> get $asMenuState =>
      $base.as((v, t, t2) => _MenuStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuStateCopyWith<$R, $In extends MenuState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, MenuGroup, MenuGroupCopyWith<$R, MenuGroup, MenuGroup>>
  get groups;
  ListCopyWith<$R, MenuItem, MenuItemCopyWith<$R, MenuItem, MenuItem>>
  get allItems;
  $R call({
    MenuStatus? status,
    List<MenuGroup>? groups,
    List<MenuItem>? allItems,
    String? selectedGroupId,
  });
  MenuStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MenuStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuState, $Out>
    implements MenuStateCopyWith<$R, MenuState, $Out> {
  _MenuStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuState> $mapper =
      MenuStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, MenuGroup, MenuGroupCopyWith<$R, MenuGroup, MenuGroup>>
  get groups => ListCopyWith(
    $value.groups,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(groups: v),
  );
  @override
  ListCopyWith<$R, MenuItem, MenuItemCopyWith<$R, MenuItem, MenuItem>>
  get allItems => ListCopyWith(
    $value.allItems,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(allItems: v),
  );
  @override
  $R call({
    MenuStatus? status,
    List<MenuGroup>? groups,
    List<MenuItem>? allItems,
    Object? selectedGroupId = $none,
  }) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (groups != null) #groups: groups,
      if (allItems != null) #allItems: allItems,
      if (selectedGroupId != $none) #selectedGroupId: selectedGroupId,
    }),
  );
  @override
  MenuState $make(CopyWithData data) => MenuState(
    status: data.get(#status, or: $value.status),
    groups: data.get(#groups, or: $value.groups),
    allItems: data.get(#allItems, or: $value.allItems),
    selectedGroupId: data.get(#selectedGroupId, or: $value.selectedGroupId),
  );

  @override
  MenuStateCopyWith<$R2, MenuState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MenuStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

