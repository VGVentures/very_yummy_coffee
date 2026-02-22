// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_items_bloc.dart';

class MenuItemsStatusMapper extends EnumMapper<MenuItemsStatus> {
  MenuItemsStatusMapper._();

  static MenuItemsStatusMapper? _instance;
  static MenuItemsStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuItemsStatusMapper._());
    }
    return _instance!;
  }

  static MenuItemsStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  MenuItemsStatus decode(dynamic value) {
    switch (value) {
      case r'initial':
        return MenuItemsStatus.initial;
      case r'loading':
        return MenuItemsStatus.loading;
      case r'success':
        return MenuItemsStatus.success;
      case r'failure':
        return MenuItemsStatus.failure;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(MenuItemsStatus self) {
    switch (self) {
      case MenuItemsStatus.initial:
        return r'initial';
      case MenuItemsStatus.loading:
        return r'loading';
      case MenuItemsStatus.success:
        return r'success';
      case MenuItemsStatus.failure:
        return r'failure';
    }
  }
}

extension MenuItemsStatusMapperExtension on MenuItemsStatus {
  String toValue() {
    MenuItemsStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<MenuItemsStatus>(this) as String;
  }
}

class MenuItemsEventMapper extends ClassMapperBase<MenuItemsEvent> {
  MenuItemsEventMapper._();

  static MenuItemsEventMapper? _instance;
  static MenuItemsEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuItemsEventMapper._());
      MenuItemsSubscriptionRequestedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MenuItemsEvent';

  @override
  final MappableFields<MenuItemsEvent> fields = const {};

  static MenuItemsEvent _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('MenuItemsEvent');
  }

  @override
  final Function instantiate = _instantiate;

  static MenuItemsEvent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuItemsEvent>(map);
  }

  static MenuItemsEvent fromJson(String json) {
    return ensureInitialized().decodeJson<MenuItemsEvent>(json);
  }
}

mixin MenuItemsEventMappable {
  String toJson();
  Map<String, dynamic> toMap();
  MenuItemsEventCopyWith<MenuItemsEvent, MenuItemsEvent, MenuItemsEvent>
  get copyWith;
}

abstract class MenuItemsEventCopyWith<$R, $In extends MenuItemsEvent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  MenuItemsEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class MenuItemsSubscriptionRequestedMapper
    extends ClassMapperBase<MenuItemsSubscriptionRequested> {
  MenuItemsSubscriptionRequestedMapper._();

  static MenuItemsSubscriptionRequestedMapper? _instance;
  static MenuItemsSubscriptionRequestedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = MenuItemsSubscriptionRequestedMapper._(),
      );
      MenuItemsEventMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MenuItemsSubscriptionRequested';

  @override
  final MappableFields<MenuItemsSubscriptionRequested> fields = const {};

  static MenuItemsSubscriptionRequested _instantiate(DecodingData data) {
    return MenuItemsSubscriptionRequested();
  }

  @override
  final Function instantiate = _instantiate;

  static MenuItemsSubscriptionRequested fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuItemsSubscriptionRequested>(map);
  }

  static MenuItemsSubscriptionRequested fromJson(String json) {
    return ensureInitialized().decodeJson<MenuItemsSubscriptionRequested>(json);
  }
}

mixin MenuItemsSubscriptionRequestedMappable {
  String toJson() {
    return MenuItemsSubscriptionRequestedMapper.ensureInitialized()
        .encodeJson<MenuItemsSubscriptionRequested>(
          this as MenuItemsSubscriptionRequested,
        );
  }

  Map<String, dynamic> toMap() {
    return MenuItemsSubscriptionRequestedMapper.ensureInitialized()
        .encodeMap<MenuItemsSubscriptionRequested>(
          this as MenuItemsSubscriptionRequested,
        );
  }

  MenuItemsSubscriptionRequestedCopyWith<
    MenuItemsSubscriptionRequested,
    MenuItemsSubscriptionRequested,
    MenuItemsSubscriptionRequested
  >
  get copyWith =>
      _MenuItemsSubscriptionRequestedCopyWithImpl<
        MenuItemsSubscriptionRequested,
        MenuItemsSubscriptionRequested
      >(this as MenuItemsSubscriptionRequested, $identity, $identity);
  @override
  String toString() {
    return MenuItemsSubscriptionRequestedMapper.ensureInitialized()
        .stringifyValue(this as MenuItemsSubscriptionRequested);
  }

  @override
  bool operator ==(Object other) {
    return MenuItemsSubscriptionRequestedMapper.ensureInitialized().equalsValue(
      this as MenuItemsSubscriptionRequested,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuItemsSubscriptionRequestedMapper.ensureInitialized().hashValue(
      this as MenuItemsSubscriptionRequested,
    );
  }
}

extension MenuItemsSubscriptionRequestedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MenuItemsSubscriptionRequested, $Out> {
  MenuItemsSubscriptionRequestedCopyWith<
    $R,
    MenuItemsSubscriptionRequested,
    $Out
  >
  get $asMenuItemsSubscriptionRequested => $base.as(
    (v, t, t2) =>
        _MenuItemsSubscriptionRequestedCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MenuItemsSubscriptionRequestedCopyWith<
  $R,
  $In extends MenuItemsSubscriptionRequested,
  $Out
>
    implements MenuItemsEventCopyWith<$R, $In, $Out> {
  @override
  $R call();
  MenuItemsSubscriptionRequestedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MenuItemsSubscriptionRequestedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuItemsSubscriptionRequested, $Out>
    implements
        MenuItemsSubscriptionRequestedCopyWith<
          $R,
          MenuItemsSubscriptionRequested,
          $Out
        > {
  _MenuItemsSubscriptionRequestedCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<MenuItemsSubscriptionRequested> $mapper =
      MenuItemsSubscriptionRequestedMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  MenuItemsSubscriptionRequested $make(CopyWithData data) =>
      MenuItemsSubscriptionRequested();

  @override
  MenuItemsSubscriptionRequestedCopyWith<
    $R2,
    MenuItemsSubscriptionRequested,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MenuItemsSubscriptionRequestedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MenuItemsStateMapper extends ClassMapperBase<MenuItemsState> {
  MenuItemsStateMapper._();

  static MenuItemsStateMapper? _instance;
  static MenuItemsStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuItemsStateMapper._());
      MenuItemsStatusMapper.ensureInitialized();
      MenuGroupMapper.ensureInitialized();
      MenuItemMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MenuItemsState';

  static MenuItemsStatus _$status(MenuItemsState v) => v.status;
  static const Field<MenuItemsState, MenuItemsStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: MenuItemsStatus.initial,
  );
  static MenuGroup? _$group(MenuItemsState v) => v.group;
  static const Field<MenuItemsState, MenuGroup> _f$group = Field(
    'group',
    _$group,
    opt: true,
  );
  static List<MenuItem> _$menuItems(MenuItemsState v) => v.menuItems;
  static const Field<MenuItemsState, List<MenuItem>> _f$menuItems = Field(
    'menuItems',
    _$menuItems,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<MenuItemsState> fields = const {
    #status: _f$status,
    #group: _f$group,
    #menuItems: _f$menuItems,
  };

  static MenuItemsState _instantiate(DecodingData data) {
    return MenuItemsState(
      status: data.dec(_f$status),
      group: data.dec(_f$group),
      menuItems: data.dec(_f$menuItems),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MenuItemsState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuItemsState>(map);
  }

  static MenuItemsState fromJson(String json) {
    return ensureInitialized().decodeJson<MenuItemsState>(json);
  }
}

mixin MenuItemsStateMappable {
  String toJson() {
    return MenuItemsStateMapper.ensureInitialized().encodeJson<MenuItemsState>(
      this as MenuItemsState,
    );
  }

  Map<String, dynamic> toMap() {
    return MenuItemsStateMapper.ensureInitialized().encodeMap<MenuItemsState>(
      this as MenuItemsState,
    );
  }

  MenuItemsStateCopyWith<MenuItemsState, MenuItemsState, MenuItemsState>
  get copyWith => _MenuItemsStateCopyWithImpl<MenuItemsState, MenuItemsState>(
    this as MenuItemsState,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return MenuItemsStateMapper.ensureInitialized().stringifyValue(
      this as MenuItemsState,
    );
  }

  @override
  bool operator ==(Object other) {
    return MenuItemsStateMapper.ensureInitialized().equalsValue(
      this as MenuItemsState,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuItemsStateMapper.ensureInitialized().hashValue(
      this as MenuItemsState,
    );
  }
}

extension MenuItemsStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MenuItemsState, $Out> {
  MenuItemsStateCopyWith<$R, MenuItemsState, $Out> get $asMenuItemsState =>
      $base.as((v, t, t2) => _MenuItemsStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuItemsStateCopyWith<$R, $In extends MenuItemsState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MenuGroupCopyWith<$R, MenuGroup, MenuGroup>? get group;
  ListCopyWith<$R, MenuItem, MenuItemCopyWith<$R, MenuItem, MenuItem>>
  get menuItems;
  $R call({
    MenuItemsStatus? status,
    MenuGroup? group,
    List<MenuItem>? menuItems,
  });
  MenuItemsStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MenuItemsStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuItemsState, $Out>
    implements MenuItemsStateCopyWith<$R, MenuItemsState, $Out> {
  _MenuItemsStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuItemsState> $mapper =
      MenuItemsStateMapper.ensureInitialized();
  @override
  MenuGroupCopyWith<$R, MenuGroup, MenuGroup>? get group =>
      $value.group?.copyWith.$chain((v) => call(group: v));
  @override
  ListCopyWith<$R, MenuItem, MenuItemCopyWith<$R, MenuItem, MenuItem>>
  get menuItems => ListCopyWith(
    $value.menuItems,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(menuItems: v),
  );
  @override
  $R call({
    MenuItemsStatus? status,
    Object? group = $none,
    List<MenuItem>? menuItems,
  }) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (group != $none) #group: group,
      if (menuItems != null) #menuItems: menuItems,
    }),
  );
  @override
  MenuItemsState $make(CopyWithData data) => MenuItemsState(
    status: data.get(#status, or: $value.status),
    group: data.get(#group, or: $value.group),
    menuItems: data.get(#menuItems, or: $value.menuItems),
  );

  @override
  MenuItemsStateCopyWith<$R2, MenuItemsState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MenuItemsStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

