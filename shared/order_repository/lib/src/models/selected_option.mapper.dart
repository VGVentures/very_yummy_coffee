// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'selected_option.dart';

class SelectedOptionMapper extends ClassMapperBase<SelectedOption> {
  SelectedOptionMapper._();

  static SelectedOptionMapper? _instance;
  static SelectedOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SelectedOptionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SelectedOption';

  static String _$id(SelectedOption v) => v.id;
  static const Field<SelectedOption, String> _f$id = Field('id', _$id);
  static String _$name(SelectedOption v) => v.name;
  static const Field<SelectedOption, String> _f$name = Field('name', _$name);
  static int _$priceDeltaCents(SelectedOption v) => v.priceDeltaCents;
  static const Field<SelectedOption, int> _f$priceDeltaCents = Field(
    'priceDeltaCents',
    _$priceDeltaCents,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<SelectedOption> fields = const {
    #id: _f$id,
    #name: _f$name,
    #priceDeltaCents: _f$priceDeltaCents,
  };

  static SelectedOption _instantiate(DecodingData data) {
    return SelectedOption(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      priceDeltaCents: data.dec(_f$priceDeltaCents),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SelectedOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SelectedOption>(map);
  }

  static SelectedOption fromJson(String json) {
    return ensureInitialized().decodeJson<SelectedOption>(json);
  }
}

mixin SelectedOptionMappable {
  String toJson() {
    return SelectedOptionMapper.ensureInitialized().encodeJson<SelectedOption>(
      this as SelectedOption,
    );
  }

  Map<String, dynamic> toMap() {
    return SelectedOptionMapper.ensureInitialized().encodeMap<SelectedOption>(
      this as SelectedOption,
    );
  }

  SelectedOptionCopyWith<SelectedOption, SelectedOption, SelectedOption>
  get copyWith => _SelectedOptionCopyWithImpl<SelectedOption, SelectedOption>(
    this as SelectedOption,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return SelectedOptionMapper.ensureInitialized().stringifyValue(
      this as SelectedOption,
    );
  }

  @override
  bool operator ==(Object other) {
    return SelectedOptionMapper.ensureInitialized().equalsValue(
      this as SelectedOption,
      other,
    );
  }

  @override
  int get hashCode {
    return SelectedOptionMapper.ensureInitialized().hashValue(
      this as SelectedOption,
    );
  }
}

extension SelectedOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SelectedOption, $Out> {
  SelectedOptionCopyWith<$R, SelectedOption, $Out> get $asSelectedOption =>
      $base.as((v, t, t2) => _SelectedOptionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SelectedOptionCopyWith<$R, $In extends SelectedOption, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? name, int? priceDeltaCents});
  SelectedOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SelectedOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SelectedOption, $Out>
    implements SelectedOptionCopyWith<$R, SelectedOption, $Out> {
  _SelectedOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SelectedOption> $mapper =
      SelectedOptionMapper.ensureInitialized();
  @override
  $R call({String? id, String? name, int? priceDeltaCents}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (priceDeltaCents != null) #priceDeltaCents: priceDeltaCents,
    }),
  );
  @override
  SelectedOption $make(CopyWithData data) => SelectedOption(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    priceDeltaCents: data.get(#priceDeltaCents, or: $value.priceDeltaCents),
  );

  @override
  SelectedOptionCopyWith<$R2, SelectedOption, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SelectedOptionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

