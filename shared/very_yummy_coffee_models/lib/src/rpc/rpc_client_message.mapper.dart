// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'rpc_client_message.dart';

class RpcClientMessageMapper extends ClassMapperBase<RpcClientMessage> {
  RpcClientMessageMapper._();

  static RpcClientMessageMapper? _instance;
  static RpcClientMessageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RpcClientMessageMapper._());
      RpcSubscribeMessageMapper.ensureInitialized();
      RpcUnsubscribeMessageMapper.ensureInitialized();
      RpcActionClientMessageMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'RpcClientMessage';

  @override
  final MappableFields<RpcClientMessage> fields = const {};

  static RpcClientMessage _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'RpcClientMessage',
      'type',
      '${data.value['type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RpcClientMessage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RpcClientMessage>(map);
  }

  static RpcClientMessage fromJson(String json) {
    return ensureInitialized().decodeJson<RpcClientMessage>(json);
  }
}

mixin RpcClientMessageMappable {
  String toJson();
  Map<String, dynamic> toMap();
  RpcClientMessageCopyWith<RpcClientMessage, RpcClientMessage, RpcClientMessage>
  get copyWith;
}

abstract class RpcClientMessageCopyWith<$R, $In extends RpcClientMessage, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  RpcClientMessageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class RpcSubscribeMessageMapper
    extends SubClassMapperBase<RpcSubscribeMessage> {
  RpcSubscribeMessageMapper._();

  static RpcSubscribeMessageMapper? _instance;
  static RpcSubscribeMessageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RpcSubscribeMessageMapper._());
      RpcClientMessageMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'RpcSubscribeMessage';

  static String _$topic(RpcSubscribeMessage v) => v.topic;
  static const Field<RpcSubscribeMessage, String> _f$topic = Field(
    'topic',
    _$topic,
  );

  @override
  final MappableFields<RpcSubscribeMessage> fields = const {#topic: _f$topic};

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'subscribe';
  @override
  late final ClassMapperBase superMapper =
      RpcClientMessageMapper.ensureInitialized();

  static RpcSubscribeMessage _instantiate(DecodingData data) {
    return RpcSubscribeMessage(topic: data.dec(_f$topic));
  }

  @override
  final Function instantiate = _instantiate;

  static RpcSubscribeMessage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RpcSubscribeMessage>(map);
  }

  static RpcSubscribeMessage fromJson(String json) {
    return ensureInitialized().decodeJson<RpcSubscribeMessage>(json);
  }
}

mixin RpcSubscribeMessageMappable {
  String toJson() {
    return RpcSubscribeMessageMapper.ensureInitialized()
        .encodeJson<RpcSubscribeMessage>(this as RpcSubscribeMessage);
  }

  Map<String, dynamic> toMap() {
    return RpcSubscribeMessageMapper.ensureInitialized()
        .encodeMap<RpcSubscribeMessage>(this as RpcSubscribeMessage);
  }

  RpcSubscribeMessageCopyWith<
    RpcSubscribeMessage,
    RpcSubscribeMessage,
    RpcSubscribeMessage
  >
  get copyWith =>
      _RpcSubscribeMessageCopyWithImpl<
        RpcSubscribeMessage,
        RpcSubscribeMessage
      >(this as RpcSubscribeMessage, $identity, $identity);
  @override
  String toString() {
    return RpcSubscribeMessageMapper.ensureInitialized().stringifyValue(
      this as RpcSubscribeMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return RpcSubscribeMessageMapper.ensureInitialized().equalsValue(
      this as RpcSubscribeMessage,
      other,
    );
  }

  @override
  int get hashCode {
    return RpcSubscribeMessageMapper.ensureInitialized().hashValue(
      this as RpcSubscribeMessage,
    );
  }
}

extension RpcSubscribeMessageValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RpcSubscribeMessage, $Out> {
  RpcSubscribeMessageCopyWith<$R, RpcSubscribeMessage, $Out>
  get $asRpcSubscribeMessage => $base.as(
    (v, t, t2) => _RpcSubscribeMessageCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class RpcSubscribeMessageCopyWith<
  $R,
  $In extends RpcSubscribeMessage,
  $Out
>
    implements RpcClientMessageCopyWith<$R, $In, $Out> {
  @override
  $R call({String? topic});
  RpcSubscribeMessageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _RpcSubscribeMessageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RpcSubscribeMessage, $Out>
    implements RpcSubscribeMessageCopyWith<$R, RpcSubscribeMessage, $Out> {
  _RpcSubscribeMessageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RpcSubscribeMessage> $mapper =
      RpcSubscribeMessageMapper.ensureInitialized();
  @override
  $R call({String? topic}) =>
      $apply(FieldCopyWithData({if (topic != null) #topic: topic}));
  @override
  RpcSubscribeMessage $make(CopyWithData data) =>
      RpcSubscribeMessage(topic: data.get(#topic, or: $value.topic));

  @override
  RpcSubscribeMessageCopyWith<$R2, RpcSubscribeMessage, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _RpcSubscribeMessageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RpcUnsubscribeMessageMapper
    extends SubClassMapperBase<RpcUnsubscribeMessage> {
  RpcUnsubscribeMessageMapper._();

  static RpcUnsubscribeMessageMapper? _instance;
  static RpcUnsubscribeMessageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RpcUnsubscribeMessageMapper._());
      RpcClientMessageMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'RpcUnsubscribeMessage';

  static String _$topic(RpcUnsubscribeMessage v) => v.topic;
  static const Field<RpcUnsubscribeMessage, String> _f$topic = Field(
    'topic',
    _$topic,
  );

  @override
  final MappableFields<RpcUnsubscribeMessage> fields = const {#topic: _f$topic};

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'unsubscribe';
  @override
  late final ClassMapperBase superMapper =
      RpcClientMessageMapper.ensureInitialized();

  static RpcUnsubscribeMessage _instantiate(DecodingData data) {
    return RpcUnsubscribeMessage(topic: data.dec(_f$topic));
  }

  @override
  final Function instantiate = _instantiate;

  static RpcUnsubscribeMessage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RpcUnsubscribeMessage>(map);
  }

  static RpcUnsubscribeMessage fromJson(String json) {
    return ensureInitialized().decodeJson<RpcUnsubscribeMessage>(json);
  }
}

mixin RpcUnsubscribeMessageMappable {
  String toJson() {
    return RpcUnsubscribeMessageMapper.ensureInitialized()
        .encodeJson<RpcUnsubscribeMessage>(this as RpcUnsubscribeMessage);
  }

  Map<String, dynamic> toMap() {
    return RpcUnsubscribeMessageMapper.ensureInitialized()
        .encodeMap<RpcUnsubscribeMessage>(this as RpcUnsubscribeMessage);
  }

  RpcUnsubscribeMessageCopyWith<
    RpcUnsubscribeMessage,
    RpcUnsubscribeMessage,
    RpcUnsubscribeMessage
  >
  get copyWith =>
      _RpcUnsubscribeMessageCopyWithImpl<
        RpcUnsubscribeMessage,
        RpcUnsubscribeMessage
      >(this as RpcUnsubscribeMessage, $identity, $identity);
  @override
  String toString() {
    return RpcUnsubscribeMessageMapper.ensureInitialized().stringifyValue(
      this as RpcUnsubscribeMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return RpcUnsubscribeMessageMapper.ensureInitialized().equalsValue(
      this as RpcUnsubscribeMessage,
      other,
    );
  }

  @override
  int get hashCode {
    return RpcUnsubscribeMessageMapper.ensureInitialized().hashValue(
      this as RpcUnsubscribeMessage,
    );
  }
}

extension RpcUnsubscribeMessageValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RpcUnsubscribeMessage, $Out> {
  RpcUnsubscribeMessageCopyWith<$R, RpcUnsubscribeMessage, $Out>
  get $asRpcUnsubscribeMessage => $base.as(
    (v, t, t2) => _RpcUnsubscribeMessageCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class RpcUnsubscribeMessageCopyWith<
  $R,
  $In extends RpcUnsubscribeMessage,
  $Out
>
    implements RpcClientMessageCopyWith<$R, $In, $Out> {
  @override
  $R call({String? topic});
  RpcUnsubscribeMessageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _RpcUnsubscribeMessageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RpcUnsubscribeMessage, $Out>
    implements RpcUnsubscribeMessageCopyWith<$R, RpcUnsubscribeMessage, $Out> {
  _RpcUnsubscribeMessageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RpcUnsubscribeMessage> $mapper =
      RpcUnsubscribeMessageMapper.ensureInitialized();
  @override
  $R call({String? topic}) =>
      $apply(FieldCopyWithData({if (topic != null) #topic: topic}));
  @override
  RpcUnsubscribeMessage $make(CopyWithData data) =>
      RpcUnsubscribeMessage(topic: data.get(#topic, or: $value.topic));

  @override
  RpcUnsubscribeMessageCopyWith<$R2, RpcUnsubscribeMessage, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _RpcUnsubscribeMessageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class RpcActionClientMessageMapper
    extends SubClassMapperBase<RpcActionClientMessage> {
  RpcActionClientMessageMapper._();

  static RpcActionClientMessageMapper? _instance;
  static RpcActionClientMessageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RpcActionClientMessageMapper._());
      RpcClientMessageMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'RpcActionClientMessage';

  static String _$action(RpcActionClientMessage v) => v.action;
  static const Field<RpcActionClientMessage, String> _f$action = Field(
    'action',
    _$action,
  );
  static Map<String, dynamic> _$payload(RpcActionClientMessage v) => v.payload;
  static const Field<RpcActionClientMessage, Map<String, dynamic>> _f$payload =
      Field('payload', _$payload);

  @override
  final MappableFields<RpcActionClientMessage> fields = const {
    #action: _f$action,
    #payload: _f$payload,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'action';
  @override
  late final ClassMapperBase superMapper =
      RpcClientMessageMapper.ensureInitialized();

  static RpcActionClientMessage _instantiate(DecodingData data) {
    return RpcActionClientMessage(
      action: data.dec(_f$action),
      payload: data.dec(_f$payload),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RpcActionClientMessage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RpcActionClientMessage>(map);
  }

  static RpcActionClientMessage fromJson(String json) {
    return ensureInitialized().decodeJson<RpcActionClientMessage>(json);
  }
}

mixin RpcActionClientMessageMappable {
  String toJson() {
    return RpcActionClientMessageMapper.ensureInitialized()
        .encodeJson<RpcActionClientMessage>(this as RpcActionClientMessage);
  }

  Map<String, dynamic> toMap() {
    return RpcActionClientMessageMapper.ensureInitialized()
        .encodeMap<RpcActionClientMessage>(this as RpcActionClientMessage);
  }

  RpcActionClientMessageCopyWith<
    RpcActionClientMessage,
    RpcActionClientMessage,
    RpcActionClientMessage
  >
  get copyWith =>
      _RpcActionClientMessageCopyWithImpl<
        RpcActionClientMessage,
        RpcActionClientMessage
      >(this as RpcActionClientMessage, $identity, $identity);
  @override
  String toString() {
    return RpcActionClientMessageMapper.ensureInitialized().stringifyValue(
      this as RpcActionClientMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return RpcActionClientMessageMapper.ensureInitialized().equalsValue(
      this as RpcActionClientMessage,
      other,
    );
  }

  @override
  int get hashCode {
    return RpcActionClientMessageMapper.ensureInitialized().hashValue(
      this as RpcActionClientMessage,
    );
  }
}

extension RpcActionClientMessageValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RpcActionClientMessage, $Out> {
  RpcActionClientMessageCopyWith<$R, RpcActionClientMessage, $Out>
  get $asRpcActionClientMessage => $base.as(
    (v, t, t2) => _RpcActionClientMessageCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class RpcActionClientMessageCopyWith<
  $R,
  $In extends RpcActionClientMessage,
  $Out
>
    implements RpcClientMessageCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>
  get payload;
  @override
  $R call({String? action, Map<String, dynamic>? payload});
  RpcActionClientMessageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _RpcActionClientMessageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RpcActionClientMessage, $Out>
    implements
        RpcActionClientMessageCopyWith<$R, RpcActionClientMessage, $Out> {
  _RpcActionClientMessageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RpcActionClientMessage> $mapper =
      RpcActionClientMessageMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>
  get payload => MapCopyWith(
    $value.payload,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(payload: v),
  );
  @override
  $R call({String? action, Map<String, dynamic>? payload}) => $apply(
    FieldCopyWithData({
      if (action != null) #action: action,
      if (payload != null) #payload: payload,
    }),
  );
  @override
  RpcActionClientMessage $make(CopyWithData data) => RpcActionClientMessage(
    action: data.get(#action, or: $value.action),
    payload: data.get(#payload, or: $value.payload),
  );

  @override
  RpcActionClientMessageCopyWith<$R2, RpcActionClientMessage, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _RpcActionClientMessageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

