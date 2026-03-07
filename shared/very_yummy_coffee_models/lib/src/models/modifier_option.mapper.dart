// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'modifier_option.dart';

class ModifierOptionMapper extends ClassMapperBase<ModifierOption> {
  ModifierOptionMapper._();

  static ModifierOptionMapper? _instance;
  static ModifierOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ModifierOptionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ModifierOption';

  static String _$id(ModifierOption v) => v.id;
  static const Field<ModifierOption, String> _f$id = Field('id', _$id);
  static String _$name(ModifierOption v) => v.name;
  static const Field<ModifierOption, String> _f$name = Field('name', _$name);
  static int _$priceDeltaCents(ModifierOption v) => v.priceDeltaCents;
  static const Field<ModifierOption, int> _f$priceDeltaCents = Field(
    'priceDeltaCents',
    _$priceDeltaCents,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<ModifierOption> fields = const {
    #id: _f$id,
    #name: _f$name,
    #priceDeltaCents: _f$priceDeltaCents,
  };

  static ModifierOption _instantiate(DecodingData data) {
    return ModifierOption(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      priceDeltaCents: data.dec(_f$priceDeltaCents),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ModifierOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ModifierOption>(map);
  }

  static ModifierOption fromJson(String json) {
    return ensureInitialized().decodeJson<ModifierOption>(json);
  }
}

mixin ModifierOptionMappable {
  String toJson() {
    return ModifierOptionMapper.ensureInitialized().encodeJson<ModifierOption>(
      this as ModifierOption,
    );
  }

  Map<String, dynamic> toMap() {
    return ModifierOptionMapper.ensureInitialized().encodeMap<ModifierOption>(
      this as ModifierOption,
    );
  }

  ModifierOptionCopyWith<ModifierOption, ModifierOption, ModifierOption>
  get copyWith => _ModifierOptionCopyWithImpl<ModifierOption, ModifierOption>(
    this as ModifierOption,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ModifierOptionMapper.ensureInitialized().stringifyValue(
      this as ModifierOption,
    );
  }

  @override
  bool operator ==(Object other) {
    return ModifierOptionMapper.ensureInitialized().equalsValue(
      this as ModifierOption,
      other,
    );
  }

  @override
  int get hashCode {
    return ModifierOptionMapper.ensureInitialized().hashValue(
      this as ModifierOption,
    );
  }
}

extension ModifierOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ModifierOption, $Out> {
  ModifierOptionCopyWith<$R, ModifierOption, $Out> get $asModifierOption =>
      $base.as((v, t, t2) => _ModifierOptionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ModifierOptionCopyWith<$R, $In extends ModifierOption, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? name, int? priceDeltaCents});
  ModifierOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ModifierOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ModifierOption, $Out>
    implements ModifierOptionCopyWith<$R, ModifierOption, $Out> {
  _ModifierOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ModifierOption> $mapper =
      ModifierOptionMapper.ensureInitialized();
  @override
  $R call({String? id, String? name, int? priceDeltaCents}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (priceDeltaCents != null) #priceDeltaCents: priceDeltaCents,
    }),
  );
  @override
  ModifierOption $make(CopyWithData data) => ModifierOption(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    priceDeltaCents: data.get(#priceDeltaCents, or: $value.priceDeltaCents),
  );

  @override
  ModifierOptionCopyWith<$R2, ModifierOption, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ModifierOptionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

