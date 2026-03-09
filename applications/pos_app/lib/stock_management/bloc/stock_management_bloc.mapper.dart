// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'stock_management_bloc.dart';

class StockManagementStateMapper extends ClassMapperBase<StockManagementState> {
  StockManagementStateMapper._();

  static StockManagementStateMapper? _instance;
  static StockManagementStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StockManagementStateMapper._());
      MenuGroupMapper.ensureInitialized();
      MenuItemMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'StockManagementState';

  static StockManagementStatus _$status(StockManagementState v) => v.status;
  static const Field<StockManagementState, StockManagementStatus> _f$status =
      Field('status', _$status, opt: true, def: StockManagementStatus.initial);
  static List<MenuGroup> _$groups(StockManagementState v) => v.groups;
  static const Field<StockManagementState, List<MenuGroup>> _f$groups = Field(
    'groups',
    _$groups,
    opt: true,
    def: const [],
  );
  static List<MenuItem> _$items(StockManagementState v) => v.items;
  static const Field<StockManagementState, List<MenuItem>> _f$items = Field(
    'items',
    _$items,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<StockManagementState> fields = const {
    #status: _f$status,
    #groups: _f$groups,
    #items: _f$items,
  };

  static StockManagementState _instantiate(DecodingData data) {
    return StockManagementState(
      status: data.dec(_f$status),
      groups: data.dec(_f$groups),
      items: data.dec(_f$items),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static StockManagementState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StockManagementState>(map);
  }

  static StockManagementState fromJson(String json) {
    return ensureInitialized().decodeJson<StockManagementState>(json);
  }
}

mixin StockManagementStateMappable {
  String toJson() {
    return StockManagementStateMapper.ensureInitialized()
        .encodeJson<StockManagementState>(this as StockManagementState);
  }

  Map<String, dynamic> toMap() {
    return StockManagementStateMapper.ensureInitialized()
        .encodeMap<StockManagementState>(this as StockManagementState);
  }

  StockManagementStateCopyWith<
    StockManagementState,
    StockManagementState,
    StockManagementState
  >
  get copyWith =>
      _StockManagementStateCopyWithImpl<
        StockManagementState,
        StockManagementState
      >(this as StockManagementState, $identity, $identity);
  @override
  String toString() {
    return StockManagementStateMapper.ensureInitialized().stringifyValue(
      this as StockManagementState,
    );
  }

  @override
  bool operator ==(Object other) {
    return StockManagementStateMapper.ensureInitialized().equalsValue(
      this as StockManagementState,
      other,
    );
  }

  @override
  int get hashCode {
    return StockManagementStateMapper.ensureInitialized().hashValue(
      this as StockManagementState,
    );
  }
}

extension StockManagementStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StockManagementState, $Out> {
  StockManagementStateCopyWith<$R, StockManagementState, $Out>
  get $asStockManagementState => $base.as(
    (v, t, t2) => _StockManagementStateCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class StockManagementStateCopyWith<
  $R,
  $In extends StockManagementState,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, MenuGroup, MenuGroupCopyWith<$R, MenuGroup, MenuGroup>>
  get groups;
  ListCopyWith<$R, MenuItem, MenuItemCopyWith<$R, MenuItem, MenuItem>>
  get items;
  $R call({
    StockManagementStatus? status,
    List<MenuGroup>? groups,
    List<MenuItem>? items,
  });
  StockManagementStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _StockManagementStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StockManagementState, $Out>
    implements StockManagementStateCopyWith<$R, StockManagementState, $Out> {
  _StockManagementStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StockManagementState> $mapper =
      StockManagementStateMapper.ensureInitialized();
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
    StockManagementStatus? status,
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
  StockManagementState $make(CopyWithData data) => StockManagementState(
    status: data.get(#status, or: $value.status),
    groups: data.get(#groups, or: $value.groups),
    items: data.get(#items, or: $value.items),
  );

  @override
  StockManagementStateCopyWith<$R2, StockManagementState, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _StockManagementStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

