// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'item_detail_bloc.dart';

class DrinkSizeMapper extends EnumMapper<DrinkSize> {
  DrinkSizeMapper._();

  static DrinkSizeMapper? _instance;
  static DrinkSizeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DrinkSizeMapper._());
    }
    return _instance!;
  }

  static DrinkSize fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  DrinkSize decode(dynamic value) {
    switch (value) {
      case r'small':
        return DrinkSize.small;
      case r'medium':
        return DrinkSize.medium;
      case r'large':
        return DrinkSize.large;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(DrinkSize self) {
    switch (self) {
      case DrinkSize.small:
        return r'small';
      case DrinkSize.medium:
        return r'medium';
      case DrinkSize.large:
        return r'large';
    }
  }
}

extension DrinkSizeMapperExtension on DrinkSize {
  String toValue() {
    DrinkSizeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<DrinkSize>(this) as String;
  }
}

class MilkOptionMapper extends EnumMapper<MilkOption> {
  MilkOptionMapper._();

  static MilkOptionMapper? _instance;
  static MilkOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MilkOptionMapper._());
    }
    return _instance!;
  }

  static MilkOption fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  MilkOption decode(dynamic value) {
    switch (value) {
      case r'whole':
        return MilkOption.whole;
      case r'oat':
        return MilkOption.oat;
      case r'almond':
        return MilkOption.almond;
      case r'soy':
        return MilkOption.soy;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(MilkOption self) {
    switch (self) {
      case MilkOption.whole:
        return r'whole';
      case MilkOption.oat:
        return r'oat';
      case MilkOption.almond:
        return r'almond';
      case MilkOption.soy:
        return r'soy';
    }
  }
}

extension MilkOptionMapperExtension on MilkOption {
  String toValue() {
    MilkOptionMapper.ensureInitialized();
    return MapperContainer.globals.toValue<MilkOption>(this) as String;
  }
}

class DrinkExtraMapper extends EnumMapper<DrinkExtra> {
  DrinkExtraMapper._();

  static DrinkExtraMapper? _instance;
  static DrinkExtraMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DrinkExtraMapper._());
    }
    return _instance!;
  }

  static DrinkExtra fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  DrinkExtra decode(dynamic value) {
    switch (value) {
      case r'extraShot':
        return DrinkExtra.extraShot;
      case r'vanillaSyrup':
        return DrinkExtra.vanillaSyrup;
      case r'caramel':
        return DrinkExtra.caramel;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(DrinkExtra self) {
    switch (self) {
      case DrinkExtra.extraShot:
        return r'extraShot';
      case DrinkExtra.vanillaSyrup:
        return r'vanillaSyrup';
      case DrinkExtra.caramel:
        return r'caramel';
    }
  }
}

extension DrinkExtraMapperExtension on DrinkExtra {
  String toValue() {
    DrinkExtraMapper.ensureInitialized();
    return MapperContainer.globals.toValue<DrinkExtra>(this) as String;
  }
}

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
      DrinkSizeMapper.ensureInitialized();
      MilkOptionMapper.ensureInitialized();
      DrinkExtraMapper.ensureInitialized();
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
  static DrinkSize _$selectedSize(ItemDetailState v) => v.selectedSize;
  static const Field<ItemDetailState, DrinkSize> _f$selectedSize = Field(
    'selectedSize',
    _$selectedSize,
    opt: true,
    def: DrinkSize.medium,
  );
  static MilkOption _$selectedMilk(ItemDetailState v) => v.selectedMilk;
  static const Field<ItemDetailState, MilkOption> _f$selectedMilk = Field(
    'selectedMilk',
    _$selectedMilk,
    opt: true,
    def: MilkOption.whole,
  );
  static List<DrinkExtra> _$selectedExtras(ItemDetailState v) =>
      v.selectedExtras;
  static const Field<ItemDetailState, List<DrinkExtra>> _f$selectedExtras =
      Field('selectedExtras', _$selectedExtras, opt: true, def: const []);
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
    #selectedSize: _f$selectedSize,
    #selectedMilk: _f$selectedMilk,
    #selectedExtras: _f$selectedExtras,
    #quantity: _f$quantity,
    #status: _f$status,
  };

  static ItemDetailState _instantiate(DecodingData data) {
    return ItemDetailState(
      item: data.dec(_f$item),
      selectedSize: data.dec(_f$selectedSize),
      selectedMilk: data.dec(_f$selectedMilk),
      selectedExtras: data.dec(_f$selectedExtras),
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
  ListCopyWith<$R, DrinkExtra, ObjectCopyWith<$R, DrinkExtra, DrinkExtra>>
  get selectedExtras;
  $R call({
    MenuItem? item,
    DrinkSize? selectedSize,
    MilkOption? selectedMilk,
    List<DrinkExtra>? selectedExtras,
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
  ListCopyWith<$R, DrinkExtra, ObjectCopyWith<$R, DrinkExtra, DrinkExtra>>
  get selectedExtras => ListCopyWith(
    $value.selectedExtras,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(selectedExtras: v),
  );
  @override
  $R call({
    Object? item = $none,
    DrinkSize? selectedSize,
    MilkOption? selectedMilk,
    List<DrinkExtra>? selectedExtras,
    int? quantity,
    ItemDetailStatus? status,
  }) => $apply(
    FieldCopyWithData({
      if (item != $none) #item: item,
      if (selectedSize != null) #selectedSize: selectedSize,
      if (selectedMilk != null) #selectedMilk: selectedMilk,
      if (selectedExtras != null) #selectedExtras: selectedExtras,
      if (quantity != null) #quantity: quantity,
      if (status != null) #status: status,
    }),
  );
  @override
  ItemDetailState $make(CopyWithData data) => ItemDetailState(
    item: data.get(#item, or: $value.item),
    selectedSize: data.get(#selectedSize, or: $value.selectedSize),
    selectedMilk: data.get(#selectedMilk, or: $value.selectedMilk),
    selectedExtras: data.get(#selectedExtras, or: $value.selectedExtras),
    quantity: data.get(#quantity, or: $value.quantity),
    status: data.get(#status, or: $value.status),
  );

  @override
  ItemDetailStateCopyWith<$R2, ItemDetailState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ItemDetailStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

