// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'item_detail_bloc.dart';

class ItemDetailStatusMapper extends EnumMapper<ItemDetailStatus> {
  ItemDetailStatusMapper._();

  static ItemDetailStatusMapper? _instance;
  static ItemDetailStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ItemDetailStatusMapper._());
    }
    return _instance!;
  }

  static ItemDetailStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ItemDetailStatus decode(dynamic value) {
    switch (value) {
      case r'loading':
        return ItemDetailStatus.loading;
      case r'idle':
        return ItemDetailStatus.idle;
      case r'adding':
        return ItemDetailStatus.adding;
      case r'added':
        return ItemDetailStatus.added;
      case r'failure':
        return ItemDetailStatus.failure;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ItemDetailStatus self) {
    switch (self) {
      case ItemDetailStatus.loading:
        return r'loading';
      case ItemDetailStatus.idle:
        return r'idle';
      case ItemDetailStatus.adding:
        return r'adding';
      case ItemDetailStatus.added:
        return r'added';
      case ItemDetailStatus.failure:
        return r'failure';
    }
  }
}

extension ItemDetailStatusMapperExtension on ItemDetailStatus {
  String toValue() {
    ItemDetailStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ItemDetailStatus>(this) as String;
  }
}

class ItemDetailStateMapper extends ClassMapperBase<ItemDetailState> {
  ItemDetailStateMapper._();

  static ItemDetailStateMapper? _instance;
  static ItemDetailStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ItemDetailStateMapper._());
      MenuItemMapper.ensureInitialized();
      ModifierGroupMapper.ensureInitialized();
      ItemDetailStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ItemDetailState';

  static MenuItem? _$item(ItemDetailState v) => v.item;
  static const Field<ItemDetailState, MenuItem> _f$item = Field(
    'item',
    _$item,
    opt: true,
  );
  static List<ModifierGroup> _$applicableModifierGroups(ItemDetailState v) =>
      v.applicableModifierGroups;
  static const Field<ItemDetailState, List<ModifierGroup>>
  _f$applicableModifierGroups = Field(
    'applicableModifierGroups',
    _$applicableModifierGroups,
    opt: true,
    def: const [],
  );
  static Map<String, List<String>> _$selectedModifiers(ItemDetailState v) =>
      v.selectedModifiers;
  static const Field<ItemDetailState, Map<String, List<String>>>
  _f$selectedModifiers = Field(
    'selectedModifiers',
    _$selectedModifiers,
    opt: true,
    def: const {},
  );
  static int _$quantity(ItemDetailState v) => v.quantity;
  static const Field<ItemDetailState, int> _f$quantity = Field(
    'quantity',
    _$quantity,
    opt: true,
    def: 1,
  );
  static ItemDetailStatus _$status(ItemDetailState v) => v.status;
  static const Field<ItemDetailState, ItemDetailStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: ItemDetailStatus.loading,
  );

  @override
  final MappableFields<ItemDetailState> fields = const {
    #item: _f$item,
    #applicableModifierGroups: _f$applicableModifierGroups,
    #selectedModifiers: _f$selectedModifiers,
    #quantity: _f$quantity,
    #status: _f$status,
  };

  static ItemDetailState _instantiate(DecodingData data) {
    return ItemDetailState(
      item: data.dec(_f$item),
      applicableModifierGroups: data.dec(_f$applicableModifierGroups),
      selectedModifiers: data.dec(_f$selectedModifiers),
      quantity: data.dec(_f$quantity),
      status: data.dec(_f$status),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ItemDetailState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ItemDetailState>(map);
  }

  static ItemDetailState fromJson(String json) {
    return ensureInitialized().decodeJson<ItemDetailState>(json);
  }
}

mixin ItemDetailStateMappable {
  String toJson() {
    return ItemDetailStateMapper.ensureInitialized()
        .encodeJson<ItemDetailState>(this as ItemDetailState);
  }

  Map<String, dynamic> toMap() {
    return ItemDetailStateMapper.ensureInitialized().encodeMap<ItemDetailState>(
      this as ItemDetailState,
    );
  }

  ItemDetailStateCopyWith<ItemDetailState, ItemDetailState, ItemDetailState>
  get copyWith =>
      _ItemDetailStateCopyWithImpl<ItemDetailState, ItemDetailState>(
        this as ItemDetailState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ItemDetailStateMapper.ensureInitialized().stringifyValue(
      this as ItemDetailState,
    );
  }

  @override
  bool operator ==(Object other) {
    return ItemDetailStateMapper.ensureInitialized().equalsValue(
      this as ItemDetailState,
      other,
    );
  }

  @override
  int get hashCode {
    return ItemDetailStateMapper.ensureInitialized().hashValue(
      this as ItemDetailState,
    );
  }
}

extension ItemDetailStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ItemDetailState, $Out> {
  ItemDetailStateCopyWith<$R, ItemDetailState, $Out> get $asItemDetailState =>
      $base.as((v, t, t2) => _ItemDetailStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ItemDetailStateCopyWith<$R, $In extends ItemDetailState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MenuItemCopyWith<$R, MenuItem, MenuItem>? get item;
  ListCopyWith<
    $R,
    ModifierGroup,
    ModifierGroupCopyWith<$R, ModifierGroup, ModifierGroup>
  >
  get applicableModifierGroups;
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >
  get selectedModifiers;
  $R call({
    MenuItem? item,
    List<ModifierGroup>? applicableModifierGroups,
    Map<String, List<String>>? selectedModifiers,
    int? quantity,
    ItemDetailStatus? status,
  });
  ItemDetailStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ItemDetailStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ItemDetailState, $Out>
    implements ItemDetailStateCopyWith<$R, ItemDetailState, $Out> {
  _ItemDetailStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ItemDetailState> $mapper =
      ItemDetailStateMapper.ensureInitialized();
  @override
  MenuItemCopyWith<$R, MenuItem, MenuItem>? get item =>
      $value.item?.copyWith.$chain((v) => call(item: v));
  @override
  ListCopyWith<
    $R,
    ModifierGroup,
    ModifierGroupCopyWith<$R, ModifierGroup, ModifierGroup>
  >
  get applicableModifierGroups => ListCopyWith(
    $value.applicableModifierGroups,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(applicableModifierGroups: v),
  );
  @override
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >
  get selectedModifiers => MapCopyWith(
    $value.selectedModifiers,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(selectedModifiers: v),
  );
  @override
  $R call({
    Object? item = $none,
    List<ModifierGroup>? applicableModifierGroups,
    Map<String, List<String>>? selectedModifiers,
    int? quantity,
    ItemDetailStatus? status,
  }) => $apply(
    FieldCopyWithData({
      if (item != $none) #item: item,
      if (applicableModifierGroups != null)
        #applicableModifierGroups: applicableModifierGroups,
      if (selectedModifiers != null) #selectedModifiers: selectedModifiers,
      if (quantity != null) #quantity: quantity,
      if (status != null) #status: status,
    }),
  );
  @override
  ItemDetailState $make(CopyWithData data) => ItemDetailState(
    item: data.get(#item, or: $value.item),
    applicableModifierGroups: data.get(
      #applicableModifierGroups,
      or: $value.applicableModifierGroups,
    ),
    selectedModifiers: data.get(
      #selectedModifiers,
      or: $value.selectedModifiers,
    ),
    quantity: data.get(#quantity, or: $value.quantity),
    status: data.get(#status, or: $value.status),
  );

  @override
  ItemDetailStateCopyWith<$R2, ItemDetailState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ItemDetailStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

