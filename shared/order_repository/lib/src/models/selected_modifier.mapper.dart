// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'selected_modifier.dart';

class SelectedModifierMapper extends ClassMapperBase<SelectedModifier> {
  SelectedModifierMapper._();

  static SelectedModifierMapper? _instance;
  static SelectedModifierMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SelectedModifierMapper._());
      SelectedOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SelectedModifier';

  static String _$modifierGroupId(SelectedModifier v) => v.modifierGroupId;
  static const Field<SelectedModifier, String> _f$modifierGroupId = Field(
    'modifierGroupId',
    _$modifierGroupId,
  );
  static String _$modifierGroupName(SelectedModifier v) => v.modifierGroupName;
  static const Field<SelectedModifier, String> _f$modifierGroupName = Field(
    'modifierGroupName',
    _$modifierGroupName,
  );
  static List<SelectedOption> _$options(SelectedModifier v) => v.options;
  static const Field<SelectedModifier, List<SelectedOption>> _f$options = Field(
    'options',
    _$options,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<SelectedModifier> fields = const {
    #modifierGroupId: _f$modifierGroupId,
    #modifierGroupName: _f$modifierGroupName,
    #options: _f$options,
  };

  static SelectedModifier _instantiate(DecodingData data) {
    return SelectedModifier(
      modifierGroupId: data.dec(_f$modifierGroupId),
      modifierGroupName: data.dec(_f$modifierGroupName),
      options: data.dec(_f$options),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SelectedModifier fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SelectedModifier>(map);
  }

  static SelectedModifier fromJson(String json) {
    return ensureInitialized().decodeJson<SelectedModifier>(json);
  }
}

mixin SelectedModifierMappable {
  String toJson() {
    return SelectedModifierMapper.ensureInitialized()
        .encodeJson<SelectedModifier>(this as SelectedModifier);
  }

  Map<String, dynamic> toMap() {
    return SelectedModifierMapper.ensureInitialized()
        .encodeMap<SelectedModifier>(this as SelectedModifier);
  }

  SelectedModifierCopyWith<SelectedModifier, SelectedModifier, SelectedModifier>
  get copyWith =>
      _SelectedModifierCopyWithImpl<SelectedModifier, SelectedModifier>(
        this as SelectedModifier,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SelectedModifierMapper.ensureInitialized().stringifyValue(
      this as SelectedModifier,
    );
  }

  @override
  bool operator ==(Object other) {
    return SelectedModifierMapper.ensureInitialized().equalsValue(
      this as SelectedModifier,
      other,
    );
  }

  @override
  int get hashCode {
    return SelectedModifierMapper.ensureInitialized().hashValue(
      this as SelectedModifier,
    );
  }
}

extension SelectedModifierValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SelectedModifier, $Out> {
  SelectedModifierCopyWith<$R, SelectedModifier, $Out>
  get $asSelectedModifier =>
      $base.as((v, t, t2) => _SelectedModifierCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SelectedModifierCopyWith<$R, $In extends SelectedModifier, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    SelectedOption,
    SelectedOptionCopyWith<$R, SelectedOption, SelectedOption>
  >
  get options;
  $R call({
    String? modifierGroupId,
    String? modifierGroupName,
    List<SelectedOption>? options,
  });
  SelectedModifierCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SelectedModifierCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SelectedModifier, $Out>
    implements SelectedModifierCopyWith<$R, SelectedModifier, $Out> {
  _SelectedModifierCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SelectedModifier> $mapper =
      SelectedModifierMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    SelectedOption,
    SelectedOptionCopyWith<$R, SelectedOption, SelectedOption>
  >
  get options => ListCopyWith(
    $value.options,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(options: v),
  );
  @override
  $R call({
    String? modifierGroupId,
    String? modifierGroupName,
    List<SelectedOption>? options,
  }) => $apply(
    FieldCopyWithData({
      if (modifierGroupId != null) #modifierGroupId: modifierGroupId,
      if (modifierGroupName != null) #modifierGroupName: modifierGroupName,
      if (options != null) #options: options,
    }),
  );
  @override
  SelectedModifier $make(CopyWithData data) => SelectedModifier(
    modifierGroupId: data.get(#modifierGroupId, or: $value.modifierGroupId),
    modifierGroupName: data.get(
      #modifierGroupName,
      or: $value.modifierGroupName,
    ),
    options: data.get(#options, or: $value.options),
  );

  @override
  SelectedModifierCopyWith<$R2, SelectedModifier, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SelectedModifierCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

