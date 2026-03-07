// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'modifier_group.dart';

class SelectionModeMapper extends EnumMapper<SelectionMode> {
  SelectionModeMapper._();

  static SelectionModeMapper? _instance;
  static SelectionModeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SelectionModeMapper._());
    }
    return _instance!;
  }

  static SelectionMode fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  SelectionMode decode(dynamic value) {
    switch (value) {
      case r'single':
        return SelectionMode.single;
      case r'multi':
        return SelectionMode.multi;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(SelectionMode self) {
    switch (self) {
      case SelectionMode.single:
        return r'single';
      case SelectionMode.multi:
        return r'multi';
    }
  }
}

extension SelectionModeMapperExtension on SelectionMode {
  String toValue() {
    SelectionModeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<SelectionMode>(this) as String;
  }
}

class ModifierGroupMapper extends ClassMapperBase<ModifierGroup> {
  ModifierGroupMapper._();

  static ModifierGroupMapper? _instance;
  static ModifierGroupMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ModifierGroupMapper._());
      ModifierOptionMapper.ensureInitialized();
      SelectionModeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ModifierGroup';

  static String _$id(ModifierGroup v) => v.id;
  static const Field<ModifierGroup, String> _f$id = Field('id', _$id);
  static String _$name(ModifierGroup v) => v.name;
  static const Field<ModifierGroup, String> _f$name = Field('name', _$name);
  static List<ModifierOption> _$options(ModifierGroup v) => v.options;
  static const Field<ModifierGroup, List<ModifierOption>> _f$options = Field(
    'options',
    _$options,
  );
  static List<String> _$appliesToGroupIds(ModifierGroup v) =>
      v.appliesToGroupIds;
  static const Field<ModifierGroup, List<String>> _f$appliesToGroupIds = Field(
    'appliesToGroupIds',
    _$appliesToGroupIds,
    opt: true,
    def: const [],
  );
  static SelectionMode _$selectionMode(ModifierGroup v) => v.selectionMode;
  static const Field<ModifierGroup, SelectionMode> _f$selectionMode = Field(
    'selectionMode',
    _$selectionMode,
    opt: true,
    def: SelectionMode.single,
  );
  static bool _$required(ModifierGroup v) => v.required;
  static const Field<ModifierGroup, bool> _f$required = Field(
    'required',
    _$required,
    opt: true,
    def: false,
  );
  static String? _$defaultOptionId(ModifierGroup v) => v.defaultOptionId;
  static const Field<ModifierGroup, String> _f$defaultOptionId = Field(
    'defaultOptionId',
    _$defaultOptionId,
    opt: true,
  );

  @override
  final MappableFields<ModifierGroup> fields = const {
    #id: _f$id,
    #name: _f$name,
    #options: _f$options,
    #appliesToGroupIds: _f$appliesToGroupIds,
    #selectionMode: _f$selectionMode,
    #required: _f$required,
    #defaultOptionId: _f$defaultOptionId,
  };

  static ModifierGroup _instantiate(DecodingData data) {
    return ModifierGroup(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      options: data.dec(_f$options),
      appliesToGroupIds: data.dec(_f$appliesToGroupIds),
      selectionMode: data.dec(_f$selectionMode),
      required: data.dec(_f$required),
      defaultOptionId: data.dec(_f$defaultOptionId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ModifierGroup fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ModifierGroup>(map);
  }

  static ModifierGroup fromJson(String json) {
    return ensureInitialized().decodeJson<ModifierGroup>(json);
  }
}

mixin ModifierGroupMappable {
  String toJson() {
    return ModifierGroupMapper.ensureInitialized().encodeJson<ModifierGroup>(
      this as ModifierGroup,
    );
  }

  Map<String, dynamic> toMap() {
    return ModifierGroupMapper.ensureInitialized().encodeMap<ModifierGroup>(
      this as ModifierGroup,
    );
  }

  ModifierGroupCopyWith<ModifierGroup, ModifierGroup, ModifierGroup>
  get copyWith => _ModifierGroupCopyWithImpl<ModifierGroup, ModifierGroup>(
    this as ModifierGroup,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ModifierGroupMapper.ensureInitialized().stringifyValue(
      this as ModifierGroup,
    );
  }

  @override
  bool operator ==(Object other) {
    return ModifierGroupMapper.ensureInitialized().equalsValue(
      this as ModifierGroup,
      other,
    );
  }

  @override
  int get hashCode {
    return ModifierGroupMapper.ensureInitialized().hashValue(
      this as ModifierGroup,
    );
  }
}

extension ModifierGroupValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ModifierGroup, $Out> {
  ModifierGroupCopyWith<$R, ModifierGroup, $Out> get $asModifierGroup =>
      $base.as((v, t, t2) => _ModifierGroupCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ModifierGroupCopyWith<$R, $In extends ModifierGroup, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    ModifierOption,
    ModifierOptionCopyWith<$R, ModifierOption, ModifierOption>
  >
  get options;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get appliesToGroupIds;
  $R call({
    String? id,
    String? name,
    List<ModifierOption>? options,
    List<String>? appliesToGroupIds,
    SelectionMode? selectionMode,
    bool? required,
    String? defaultOptionId,
  });
  ModifierGroupCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ModifierGroupCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ModifierGroup, $Out>
    implements ModifierGroupCopyWith<$R, ModifierGroup, $Out> {
  _ModifierGroupCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ModifierGroup> $mapper =
      ModifierGroupMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    ModifierOption,
    ModifierOptionCopyWith<$R, ModifierOption, ModifierOption>
  >
  get options => ListCopyWith(
    $value.options,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(options: v),
  );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get appliesToGroupIds => ListCopyWith(
    $value.appliesToGroupIds,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(appliesToGroupIds: v),
  );
  @override
  $R call({
    String? id,
    String? name,
    List<ModifierOption>? options,
    List<String>? appliesToGroupIds,
    SelectionMode? selectionMode,
    bool? required,
    Object? defaultOptionId = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (options != null) #options: options,
      if (appliesToGroupIds != null) #appliesToGroupIds: appliesToGroupIds,
      if (selectionMode != null) #selectionMode: selectionMode,
      if (required != null) #required: required,
      if (defaultOptionId != $none) #defaultOptionId: defaultOptionId,
    }),
  );
  @override
  ModifierGroup $make(CopyWithData data) => ModifierGroup(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    options: data.get(#options, or: $value.options),
    appliesToGroupIds: data.get(
      #appliesToGroupIds,
      or: $value.appliesToGroupIds,
    ),
    selectionMode: data.get(#selectionMode, or: $value.selectionMode),
    required: data.get(#required, or: $value.required),
    defaultOptionId: data.get(#defaultOptionId, or: $value.defaultOptionId),
  );

  @override
  ModifierGroupCopyWith<$R2, ModifierGroup, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ModifierGroupCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

