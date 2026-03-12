// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'menu_groups_bloc.dart';

class MenuGroupsStatusMapper extends EnumMapper<MenuGroupsStatus> {
  MenuGroupsStatusMapper._();

  static MenuGroupsStatusMapper? _instance;
  static MenuGroupsStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuGroupsStatusMapper._());
    }
    return _instance!;
  }

  static MenuGroupsStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  MenuGroupsStatus decode(dynamic value) {
    switch (value) {
      case r'initial':
        return MenuGroupsStatus.initial;
      case r'loading':
        return MenuGroupsStatus.loading;
      case r'success':
        return MenuGroupsStatus.success;
      case r'failure':
        return MenuGroupsStatus.failure;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(MenuGroupsStatus self) {
    switch (self) {
      case MenuGroupsStatus.initial:
        return r'initial';
      case MenuGroupsStatus.loading:
        return r'loading';
      case MenuGroupsStatus.success:
        return r'success';
      case MenuGroupsStatus.failure:
        return r'failure';
    }
  }
}

extension MenuGroupsStatusMapperExtension on MenuGroupsStatus {
  String toValue() {
    MenuGroupsStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<MenuGroupsStatus>(this) as String;
  }
}

class MenuGroupsEventMapper extends ClassMapperBase<MenuGroupsEvent> {
  MenuGroupsEventMapper._();

  static MenuGroupsEventMapper? _instance;
  static MenuGroupsEventMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuGroupsEventMapper._());
      MenuGroupsSubscriptionRequestedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MenuGroupsEvent';

  @override
  final MappableFields<MenuGroupsEvent> fields = const {};

  static MenuGroupsEvent _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('MenuGroupsEvent');
  }

  @override
  final Function instantiate = _instantiate;

  static MenuGroupsEvent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuGroupsEvent>(map);
  }

  static MenuGroupsEvent fromJson(String json) {
    return ensureInitialized().decodeJson<MenuGroupsEvent>(json);
  }
}

mixin MenuGroupsEventMappable {
  String toJson();
  Map<String, dynamic> toMap();
  MenuGroupsEventCopyWith<MenuGroupsEvent, MenuGroupsEvent, MenuGroupsEvent>
  get copyWith;
}

abstract class MenuGroupsEventCopyWith<$R, $In extends MenuGroupsEvent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  MenuGroupsEventCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class MenuGroupsSubscriptionRequestedMapper
    extends ClassMapperBase<MenuGroupsSubscriptionRequested> {
  MenuGroupsSubscriptionRequestedMapper._();

  static MenuGroupsSubscriptionRequestedMapper? _instance;
  static MenuGroupsSubscriptionRequestedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = MenuGroupsSubscriptionRequestedMapper._(),
      );
      MenuGroupsEventMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MenuGroupsSubscriptionRequested';

  @override
  final MappableFields<MenuGroupsSubscriptionRequested> fields = const {};

  static MenuGroupsSubscriptionRequested _instantiate(DecodingData data) {
    return MenuGroupsSubscriptionRequested();
  }

  @override
  final Function instantiate = _instantiate;

  static MenuGroupsSubscriptionRequested fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuGroupsSubscriptionRequested>(map);
  }

  static MenuGroupsSubscriptionRequested fromJson(String json) {
    return ensureInitialized().decodeJson<MenuGroupsSubscriptionRequested>(
      json,
    );
  }
}

mixin MenuGroupsSubscriptionRequestedMappable {
  String toJson() {
    return MenuGroupsSubscriptionRequestedMapper.ensureInitialized()
        .encodeJson<MenuGroupsSubscriptionRequested>(
          this as MenuGroupsSubscriptionRequested,
        );
  }

  Map<String, dynamic> toMap() {
    return MenuGroupsSubscriptionRequestedMapper.ensureInitialized()
        .encodeMap<MenuGroupsSubscriptionRequested>(
          this as MenuGroupsSubscriptionRequested,
        );
  }

  MenuGroupsSubscriptionRequestedCopyWith<
    MenuGroupsSubscriptionRequested,
    MenuGroupsSubscriptionRequested,
    MenuGroupsSubscriptionRequested
  >
  get copyWith =>
      _MenuGroupsSubscriptionRequestedCopyWithImpl<
        MenuGroupsSubscriptionRequested,
        MenuGroupsSubscriptionRequested
      >(this as MenuGroupsSubscriptionRequested, $identity, $identity);
  @override
  String toString() {
    return MenuGroupsSubscriptionRequestedMapper.ensureInitialized()
        .stringifyValue(this as MenuGroupsSubscriptionRequested);
  }

  @override
  bool operator ==(Object other) {
    return MenuGroupsSubscriptionRequestedMapper.ensureInitialized()
        .equalsValue(this as MenuGroupsSubscriptionRequested, other);
  }

  @override
  int get hashCode {
    return MenuGroupsSubscriptionRequestedMapper.ensureInitialized().hashValue(
      this as MenuGroupsSubscriptionRequested,
    );
  }
}

extension MenuGroupsSubscriptionRequestedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MenuGroupsSubscriptionRequested, $Out> {
  MenuGroupsSubscriptionRequestedCopyWith<
    $R,
    MenuGroupsSubscriptionRequested,
    $Out
  >
  get $asMenuGroupsSubscriptionRequested => $base.as(
    (v, t, t2) =>
        _MenuGroupsSubscriptionRequestedCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MenuGroupsSubscriptionRequestedCopyWith<
  $R,
  $In extends MenuGroupsSubscriptionRequested,
  $Out
>
    implements MenuGroupsEventCopyWith<$R, $In, $Out> {
  @override
  $R call();
  MenuGroupsSubscriptionRequestedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MenuGroupsSubscriptionRequestedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuGroupsSubscriptionRequested, $Out>
    implements
        MenuGroupsSubscriptionRequestedCopyWith<
          $R,
          MenuGroupsSubscriptionRequested,
          $Out
        > {
  _MenuGroupsSubscriptionRequestedCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<MenuGroupsSubscriptionRequested> $mapper =
      MenuGroupsSubscriptionRequestedMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  MenuGroupsSubscriptionRequested $make(CopyWithData data) =>
      MenuGroupsSubscriptionRequested();

  @override
  MenuGroupsSubscriptionRequestedCopyWith<
    $R2,
    MenuGroupsSubscriptionRequested,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MenuGroupsSubscriptionRequestedCopyWithImpl<$R2, $Out2>(
        $value,
        $cast,
        t,
      );
}

class MenuGroupsStateMapper extends ClassMapperBase<MenuGroupsState> {
  MenuGroupsStateMapper._();

  static MenuGroupsStateMapper? _instance;
  static MenuGroupsStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MenuGroupsStateMapper._());
      MenuGroupsStatusMapper.ensureInitialized();
      MenuGroupMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MenuGroupsState';

  static MenuGroupsStatus _$status(MenuGroupsState v) => v.status;
  static const Field<MenuGroupsState, MenuGroupsStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: MenuGroupsStatus.initial,
  );
  static List<MenuGroup> _$menuGroups(MenuGroupsState v) => v.menuGroups;
  static const Field<MenuGroupsState, List<MenuGroup>> _f$menuGroups = Field(
    'menuGroups',
    _$menuGroups,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<MenuGroupsState> fields = const {
    #status: _f$status,
    #menuGroups: _f$menuGroups,
  };

  static MenuGroupsState _instantiate(DecodingData data) {
    return MenuGroupsState(
      status: data.dec(_f$status),
      menuGroups: data.dec(_f$menuGroups),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MenuGroupsState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MenuGroupsState>(map);
  }

  static MenuGroupsState fromJson(String json) {
    return ensureInitialized().decodeJson<MenuGroupsState>(json);
  }
}

mixin MenuGroupsStateMappable {
  String toJson() {
    return MenuGroupsStateMapper.ensureInitialized()
        .encodeJson<MenuGroupsState>(this as MenuGroupsState);
  }

  Map<String, dynamic> toMap() {
    return MenuGroupsStateMapper.ensureInitialized().encodeMap<MenuGroupsState>(
      this as MenuGroupsState,
    );
  }

  MenuGroupsStateCopyWith<MenuGroupsState, MenuGroupsState, MenuGroupsState>
  get copyWith =>
      _MenuGroupsStateCopyWithImpl<MenuGroupsState, MenuGroupsState>(
        this as MenuGroupsState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MenuGroupsStateMapper.ensureInitialized().stringifyValue(
      this as MenuGroupsState,
    );
  }

  @override
  bool operator ==(Object other) {
    return MenuGroupsStateMapper.ensureInitialized().equalsValue(
      this as MenuGroupsState,
      other,
    );
  }

  @override
  int get hashCode {
    return MenuGroupsStateMapper.ensureInitialized().hashValue(
      this as MenuGroupsState,
    );
  }
}

extension MenuGroupsStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MenuGroupsState, $Out> {
  MenuGroupsStateCopyWith<$R, MenuGroupsState, $Out> get $asMenuGroupsState =>
      $base.as((v, t, t2) => _MenuGroupsStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MenuGroupsStateCopyWith<$R, $In extends MenuGroupsState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, MenuGroup, MenuGroupCopyWith<$R, MenuGroup, MenuGroup>>
  get menuGroups;
  $R call({MenuGroupsStatus? status, List<MenuGroup>? menuGroups});
  MenuGroupsStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MenuGroupsStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MenuGroupsState, $Out>
    implements MenuGroupsStateCopyWith<$R, MenuGroupsState, $Out> {
  _MenuGroupsStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MenuGroupsState> $mapper =
      MenuGroupsStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, MenuGroup, MenuGroupCopyWith<$R, MenuGroup, MenuGroup>>
  get menuGroups => ListCopyWith(
    $value.menuGroups,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(menuGroups: v),
  );
  @override
  $R call({MenuGroupsStatus? status, List<MenuGroup>? menuGroups}) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (menuGroups != null) #menuGroups: menuGroups,
    }),
  );
  @override
  MenuGroupsState $make(CopyWithData data) => MenuGroupsState(
    status: data.get(#status, or: $value.status),
    menuGroups: data.get(#menuGroups, or: $value.menuGroups),
  );

  @override
  MenuGroupsStateCopyWith<$R2, MenuGroupsState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MenuGroupsStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

