// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ConnectionsTable extends Connections
    with TableInfo<$ConnectionsTable, Connection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConnectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MqttProtocol, String> protocol =
      GeneratedColumn<String>(
        'protocol',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MqttProtocol>($ConnectionsTable.$converterprotocol);
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keepAliveSecondsMeta = const VerificationMeta(
    'keepAliveSeconds',
  );
  @override
  late final GeneratedColumn<int> keepAliveSeconds = GeneratedColumn<int>(
    'keep_alive_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _autoConnectMeta = const VerificationMeta(
    'autoConnect',
  );
  @override
  late final GeneratedColumn<bool> autoConnect = GeneratedColumn<bool>(
    'auto_connect',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_connect" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _homeDashboardIdMeta = const VerificationMeta(
    'homeDashboardId',
  );
  @override
  late final GeneratedColumn<String> homeDashboardId = GeneratedColumn<String>(
    'home_dashboard_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteHostMeta = const VerificationMeta(
    'remoteHost',
  );
  @override
  late final GeneratedColumn<String> remoteHost = GeneratedColumn<String>(
    'remote_host',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _devicesSeenAtMeta = const VerificationMeta(
    'devicesSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> devicesSeenAt =
      GeneratedColumn<DateTime>(
        'devices_seen_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _z2mBaseTopicMeta = const VerificationMeta(
    'z2mBaseTopic',
  );
  @override
  late final GeneratedColumn<String> z2mBaseTopic = GeneratedColumn<String>(
    'z2m_base_topic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    host,
    port,
    protocol,
    username,
    keepAliveSeconds,
    autoConnect,
    homeDashboardId,
    remoteHost,
    devicesSeenAt,
    z2mBaseTopic,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Connection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('keep_alive_seconds')) {
      context.handle(
        _keepAliveSecondsMeta,
        keepAliveSeconds.isAcceptableOrUnknown(
          data['keep_alive_seconds']!,
          _keepAliveSecondsMeta,
        ),
      );
    }
    if (data.containsKey('auto_connect')) {
      context.handle(
        _autoConnectMeta,
        autoConnect.isAcceptableOrUnknown(
          data['auto_connect']!,
          _autoConnectMeta,
        ),
      );
    }
    if (data.containsKey('home_dashboard_id')) {
      context.handle(
        _homeDashboardIdMeta,
        homeDashboardId.isAcceptableOrUnknown(
          data['home_dashboard_id']!,
          _homeDashboardIdMeta,
        ),
      );
    }
    if (data.containsKey('remote_host')) {
      context.handle(
        _remoteHostMeta,
        remoteHost.isAcceptableOrUnknown(data['remote_host']!, _remoteHostMeta),
      );
    }
    if (data.containsKey('devices_seen_at')) {
      context.handle(
        _devicesSeenAtMeta,
        devicesSeenAt.isAcceptableOrUnknown(
          data['devices_seen_at']!,
          _devicesSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('z2m_base_topic')) {
      context.handle(
        _z2mBaseTopicMeta,
        z2mBaseTopic.isAcceptableOrUnknown(
          data['z2m_base_topic']!,
          _z2mBaseTopicMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Connection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Connection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      protocol: $ConnectionsTable.$converterprotocol.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}protocol'],
        )!,
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      keepAliveSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}keep_alive_seconds'],
      )!,
      autoConnect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_connect'],
      )!,
      homeDashboardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_dashboard_id'],
      ),
      remoteHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_host'],
      ),
      devicesSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}devices_seen_at'],
      ),
      z2mBaseTopic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}z2m_base_topic'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ConnectionsTable createAlias(String alias) {
    return $ConnectionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MqttProtocol, String, String> $converterprotocol =
      const EnumNameConverter<MqttProtocol>(MqttProtocol.values);
}

class Connection extends DataClass implements Insertable<Connection> {
  final String id;
  final String name;
  final String host;
  final int port;
  final MqttProtocol protocol;
  final String? username;
  final int keepAliveSeconds;
  final bool autoConnect;
  final String? homeDashboardId;
  final String? remoteHost;

  /// When the home's existing devices were recorded as seen (first connect
  /// after 1.12 setup or upgrade). Null until then; only devices paired
  /// later count as new.
  final DateTime? devicesSeenAt;

  /// The Zigbee2MQTT base topic set for this home (Settings › home, or the
  /// setup retry). Null keeps the pre-1.13 derivation from a dashboard's
  /// topic prefix; see `homeBaseTopic`.
  final String? z2mBaseTopic;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Connection({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.protocol,
    this.username,
    required this.keepAliveSeconds,
    required this.autoConnect,
    this.homeDashboardId,
    this.remoteHost,
    this.devicesSeenAt,
    this.z2mBaseTopic,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['host'] = Variable<String>(host);
    map['port'] = Variable<int>(port);
    {
      map['protocol'] = Variable<String>(
        $ConnectionsTable.$converterprotocol.toSql(protocol),
      );
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    map['keep_alive_seconds'] = Variable<int>(keepAliveSeconds);
    map['auto_connect'] = Variable<bool>(autoConnect);
    if (!nullToAbsent || homeDashboardId != null) {
      map['home_dashboard_id'] = Variable<String>(homeDashboardId);
    }
    if (!nullToAbsent || remoteHost != null) {
      map['remote_host'] = Variable<String>(remoteHost);
    }
    if (!nullToAbsent || devicesSeenAt != null) {
      map['devices_seen_at'] = Variable<DateTime>(devicesSeenAt);
    }
    if (!nullToAbsent || z2mBaseTopic != null) {
      map['z2m_base_topic'] = Variable<String>(z2mBaseTopic);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConnectionsCompanion toCompanion(bool nullToAbsent) {
    return ConnectionsCompanion(
      id: Value(id),
      name: Value(name),
      host: Value(host),
      port: Value(port),
      protocol: Value(protocol),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      keepAliveSeconds: Value(keepAliveSeconds),
      autoConnect: Value(autoConnect),
      homeDashboardId: homeDashboardId == null && nullToAbsent
          ? const Value.absent()
          : Value(homeDashboardId),
      remoteHost: remoteHost == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteHost),
      devicesSeenAt: devicesSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(devicesSeenAt),
      z2mBaseTopic: z2mBaseTopic == null && nullToAbsent
          ? const Value.absent()
          : Value(z2mBaseTopic),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Connection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Connection(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      host: serializer.fromJson<String>(json['host']),
      port: serializer.fromJson<int>(json['port']),
      protocol: $ConnectionsTable.$converterprotocol.fromJson(
        serializer.fromJson<String>(json['protocol']),
      ),
      username: serializer.fromJson<String?>(json['username']),
      keepAliveSeconds: serializer.fromJson<int>(json['keepAliveSeconds']),
      autoConnect: serializer.fromJson<bool>(json['autoConnect']),
      homeDashboardId: serializer.fromJson<String?>(json['homeDashboardId']),
      remoteHost: serializer.fromJson<String?>(json['remoteHost']),
      devicesSeenAt: serializer.fromJson<DateTime?>(json['devicesSeenAt']),
      z2mBaseTopic: serializer.fromJson<String?>(json['z2mBaseTopic']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'host': serializer.toJson<String>(host),
      'port': serializer.toJson<int>(port),
      'protocol': serializer.toJson<String>(
        $ConnectionsTable.$converterprotocol.toJson(protocol),
      ),
      'username': serializer.toJson<String?>(username),
      'keepAliveSeconds': serializer.toJson<int>(keepAliveSeconds),
      'autoConnect': serializer.toJson<bool>(autoConnect),
      'homeDashboardId': serializer.toJson<String?>(homeDashboardId),
      'remoteHost': serializer.toJson<String?>(remoteHost),
      'devicesSeenAt': serializer.toJson<DateTime?>(devicesSeenAt),
      'z2mBaseTopic': serializer.toJson<String?>(z2mBaseTopic),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Connection copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    MqttProtocol? protocol,
    Value<String?> username = const Value.absent(),
    int? keepAliveSeconds,
    bool? autoConnect,
    Value<String?> homeDashboardId = const Value.absent(),
    Value<String?> remoteHost = const Value.absent(),
    Value<DateTime?> devicesSeenAt = const Value.absent(),
    Value<String?> z2mBaseTopic = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Connection(
    id: id ?? this.id,
    name: name ?? this.name,
    host: host ?? this.host,
    port: port ?? this.port,
    protocol: protocol ?? this.protocol,
    username: username.present ? username.value : this.username,
    keepAliveSeconds: keepAliveSeconds ?? this.keepAliveSeconds,
    autoConnect: autoConnect ?? this.autoConnect,
    homeDashboardId: homeDashboardId.present
        ? homeDashboardId.value
        : this.homeDashboardId,
    remoteHost: remoteHost.present ? remoteHost.value : this.remoteHost,
    devicesSeenAt: devicesSeenAt.present
        ? devicesSeenAt.value
        : this.devicesSeenAt,
    z2mBaseTopic: z2mBaseTopic.present ? z2mBaseTopic.value : this.z2mBaseTopic,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Connection copyWithCompanion(ConnectionsCompanion data) {
    return Connection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      host: data.host.present ? data.host.value : this.host,
      port: data.port.present ? data.port.value : this.port,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      username: data.username.present ? data.username.value : this.username,
      keepAliveSeconds: data.keepAliveSeconds.present
          ? data.keepAliveSeconds.value
          : this.keepAliveSeconds,
      autoConnect: data.autoConnect.present
          ? data.autoConnect.value
          : this.autoConnect,
      homeDashboardId: data.homeDashboardId.present
          ? data.homeDashboardId.value
          : this.homeDashboardId,
      remoteHost: data.remoteHost.present
          ? data.remoteHost.value
          : this.remoteHost,
      devicesSeenAt: data.devicesSeenAt.present
          ? data.devicesSeenAt.value
          : this.devicesSeenAt,
      z2mBaseTopic: data.z2mBaseTopic.present
          ? data.z2mBaseTopic.value
          : this.z2mBaseTopic,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Connection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('protocol: $protocol, ')
          ..write('username: $username, ')
          ..write('keepAliveSeconds: $keepAliveSeconds, ')
          ..write('autoConnect: $autoConnect, ')
          ..write('homeDashboardId: $homeDashboardId, ')
          ..write('remoteHost: $remoteHost, ')
          ..write('devicesSeenAt: $devicesSeenAt, ')
          ..write('z2mBaseTopic: $z2mBaseTopic, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    host,
    port,
    protocol,
    username,
    keepAliveSeconds,
    autoConnect,
    homeDashboardId,
    remoteHost,
    devicesSeenAt,
    z2mBaseTopic,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Connection &&
          other.id == this.id &&
          other.name == this.name &&
          other.host == this.host &&
          other.port == this.port &&
          other.protocol == this.protocol &&
          other.username == this.username &&
          other.keepAliveSeconds == this.keepAliveSeconds &&
          other.autoConnect == this.autoConnect &&
          other.homeDashboardId == this.homeDashboardId &&
          other.remoteHost == this.remoteHost &&
          other.devicesSeenAt == this.devicesSeenAt &&
          other.z2mBaseTopic == this.z2mBaseTopic &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ConnectionsCompanion extends UpdateCompanion<Connection> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> host;
  final Value<int> port;
  final Value<MqttProtocol> protocol;
  final Value<String?> username;
  final Value<int> keepAliveSeconds;
  final Value<bool> autoConnect;
  final Value<String?> homeDashboardId;
  final Value<String?> remoteHost;
  final Value<DateTime?> devicesSeenAt;
  final Value<String?> z2mBaseTopic;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ConnectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.host = const Value.absent(),
    this.port = const Value.absent(),
    this.protocol = const Value.absent(),
    this.username = const Value.absent(),
    this.keepAliveSeconds = const Value.absent(),
    this.autoConnect = const Value.absent(),
    this.homeDashboardId = const Value.absent(),
    this.remoteHost = const Value.absent(),
    this.devicesSeenAt = const Value.absent(),
    this.z2mBaseTopic = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConnectionsCompanion.insert({
    required String id,
    required String name,
    required String host,
    required int port,
    required MqttProtocol protocol,
    this.username = const Value.absent(),
    this.keepAliveSeconds = const Value.absent(),
    this.autoConnect = const Value.absent(),
    this.homeDashboardId = const Value.absent(),
    this.remoteHost = const Value.absent(),
    this.devicesSeenAt = const Value.absent(),
    this.z2mBaseTopic = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       host = Value(host),
       port = Value(port),
       protocol = Value(protocol),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Connection> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? host,
    Expression<int>? port,
    Expression<String>? protocol,
    Expression<String>? username,
    Expression<int>? keepAliveSeconds,
    Expression<bool>? autoConnect,
    Expression<String>? homeDashboardId,
    Expression<String>? remoteHost,
    Expression<DateTime>? devicesSeenAt,
    Expression<String>? z2mBaseTopic,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (protocol != null) 'protocol': protocol,
      if (username != null) 'username': username,
      if (keepAliveSeconds != null) 'keep_alive_seconds': keepAliveSeconds,
      if (autoConnect != null) 'auto_connect': autoConnect,
      if (homeDashboardId != null) 'home_dashboard_id': homeDashboardId,
      if (remoteHost != null) 'remote_host': remoteHost,
      if (devicesSeenAt != null) 'devices_seen_at': devicesSeenAt,
      if (z2mBaseTopic != null) 'z2m_base_topic': z2mBaseTopic,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConnectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? host,
    Value<int>? port,
    Value<MqttProtocol>? protocol,
    Value<String?>? username,
    Value<int>? keepAliveSeconds,
    Value<bool>? autoConnect,
    Value<String?>? homeDashboardId,
    Value<String?>? remoteHost,
    Value<DateTime?>? devicesSeenAt,
    Value<String?>? z2mBaseTopic,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ConnectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      protocol: protocol ?? this.protocol,
      username: username ?? this.username,
      keepAliveSeconds: keepAliveSeconds ?? this.keepAliveSeconds,
      autoConnect: autoConnect ?? this.autoConnect,
      homeDashboardId: homeDashboardId ?? this.homeDashboardId,
      remoteHost: remoteHost ?? this.remoteHost,
      devicesSeenAt: devicesSeenAt ?? this.devicesSeenAt,
      z2mBaseTopic: z2mBaseTopic ?? this.z2mBaseTopic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (protocol.present) {
      map['protocol'] = Variable<String>(
        $ConnectionsTable.$converterprotocol.toSql(protocol.value),
      );
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (keepAliveSeconds.present) {
      map['keep_alive_seconds'] = Variable<int>(keepAliveSeconds.value);
    }
    if (autoConnect.present) {
      map['auto_connect'] = Variable<bool>(autoConnect.value);
    }
    if (homeDashboardId.present) {
      map['home_dashboard_id'] = Variable<String>(homeDashboardId.value);
    }
    if (remoteHost.present) {
      map['remote_host'] = Variable<String>(remoteHost.value);
    }
    if (devicesSeenAt.present) {
      map['devices_seen_at'] = Variable<DateTime>(devicesSeenAt.value);
    }
    if (z2mBaseTopic.present) {
      map['z2m_base_topic'] = Variable<String>(z2mBaseTopic.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('protocol: $protocol, ')
          ..write('username: $username, ')
          ..write('keepAliveSeconds: $keepAliveSeconds, ')
          ..write('autoConnect: $autoConnect, ')
          ..write('homeDashboardId: $homeDashboardId, ')
          ..write('remoteHost: $remoteHost, ')
          ..write('devicesSeenAt: $devicesSeenAt, ')
          ..write('z2mBaseTopic: $z2mBaseTopic, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DashboardsTable extends Dashboards
    with TableInfo<$DashboardsTable, Dashboard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DashboardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  @override
  late final GeneratedColumn<String> connectionId = GeneratedColumn<String>(
    'connection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES connections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicPrefixMeta = const VerificationMeta(
    'topicPrefix',
  );
  @override
  late final GeneratedColumn<String> topicPrefix = GeneratedColumn<String>(
    'topic_prefix',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorSeedMeta = const VerificationMeta(
    'colorSeed',
  );
  @override
  late final GeneratedColumn<int> colorSeed = GeneratedColumn<int>(
    'color_seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodepointMeta = const VerificationMeta(
    'iconCodepoint',
  );
  @override
  late final GeneratedColumn<int> iconCodepoint = GeneratedColumn<int>(
    'icon_codepoint',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    connectionId,
    name,
    topicPrefix,
    colorSeed,
    iconCodepoint,
    locked,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dashboards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dashboard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('connection_id')) {
      context.handle(
        _connectionIdMeta,
        connectionId.isAcceptableOrUnknown(
          data['connection_id']!,
          _connectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('topic_prefix')) {
      context.handle(
        _topicPrefixMeta,
        topicPrefix.isAcceptableOrUnknown(
          data['topic_prefix']!,
          _topicPrefixMeta,
        ),
      );
    }
    if (data.containsKey('color_seed')) {
      context.handle(
        _colorSeedMeta,
        colorSeed.isAcceptableOrUnknown(data['color_seed']!, _colorSeedMeta),
      );
    } else if (isInserting) {
      context.missing(_colorSeedMeta);
    }
    if (data.containsKey('icon_codepoint')) {
      context.handle(
        _iconCodepointMeta,
        iconCodepoint.isAcceptableOrUnknown(
          data['icon_codepoint']!,
          _iconCodepointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iconCodepointMeta);
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dashboard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dashboard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      topicPrefix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_prefix'],
      ),
      colorSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_seed'],
      )!,
      iconCodepoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_codepoint'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DashboardsTable createAlias(String alias) {
    return $DashboardsTable(attachedDatabase, alias);
  }
}

class Dashboard extends DataClass implements Insertable<Dashboard> {
  final String id;
  final String connectionId;
  final String name;
  final String? topicPrefix;
  final int colorSeed;
  final int iconCodepoint;
  final bool locked;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Dashboard({
    required this.id,
    required this.connectionId,
    required this.name,
    this.topicPrefix,
    required this.colorSeed,
    required this.iconCodepoint,
    required this.locked,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['connection_id'] = Variable<String>(connectionId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || topicPrefix != null) {
      map['topic_prefix'] = Variable<String>(topicPrefix);
    }
    map['color_seed'] = Variable<int>(colorSeed);
    map['icon_codepoint'] = Variable<int>(iconCodepoint);
    map['locked'] = Variable<bool>(locked);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DashboardsCompanion toCompanion(bool nullToAbsent) {
    return DashboardsCompanion(
      id: Value(id),
      connectionId: Value(connectionId),
      name: Value(name),
      topicPrefix: topicPrefix == null && nullToAbsent
          ? const Value.absent()
          : Value(topicPrefix),
      colorSeed: Value(colorSeed),
      iconCodepoint: Value(iconCodepoint),
      locked: Value(locked),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Dashboard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dashboard(
      id: serializer.fromJson<String>(json['id']),
      connectionId: serializer.fromJson<String>(json['connectionId']),
      name: serializer.fromJson<String>(json['name']),
      topicPrefix: serializer.fromJson<String?>(json['topicPrefix']),
      colorSeed: serializer.fromJson<int>(json['colorSeed']),
      iconCodepoint: serializer.fromJson<int>(json['iconCodepoint']),
      locked: serializer.fromJson<bool>(json['locked']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'connectionId': serializer.toJson<String>(connectionId),
      'name': serializer.toJson<String>(name),
      'topicPrefix': serializer.toJson<String?>(topicPrefix),
      'colorSeed': serializer.toJson<int>(colorSeed),
      'iconCodepoint': serializer.toJson<int>(iconCodepoint),
      'locked': serializer.toJson<bool>(locked),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Dashboard copyWith({
    String? id,
    String? connectionId,
    String? name,
    Value<String?> topicPrefix = const Value.absent(),
    int? colorSeed,
    int? iconCodepoint,
    bool? locked,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Dashboard(
    id: id ?? this.id,
    connectionId: connectionId ?? this.connectionId,
    name: name ?? this.name,
    topicPrefix: topicPrefix.present ? topicPrefix.value : this.topicPrefix,
    colorSeed: colorSeed ?? this.colorSeed,
    iconCodepoint: iconCodepoint ?? this.iconCodepoint,
    locked: locked ?? this.locked,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Dashboard copyWithCompanion(DashboardsCompanion data) {
    return Dashboard(
      id: data.id.present ? data.id.value : this.id,
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      name: data.name.present ? data.name.value : this.name,
      topicPrefix: data.topicPrefix.present
          ? data.topicPrefix.value
          : this.topicPrefix,
      colorSeed: data.colorSeed.present ? data.colorSeed.value : this.colorSeed,
      iconCodepoint: data.iconCodepoint.present
          ? data.iconCodepoint.value
          : this.iconCodepoint,
      locked: data.locked.present ? data.locked.value : this.locked,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dashboard(')
          ..write('id: $id, ')
          ..write('connectionId: $connectionId, ')
          ..write('name: $name, ')
          ..write('topicPrefix: $topicPrefix, ')
          ..write('colorSeed: $colorSeed, ')
          ..write('iconCodepoint: $iconCodepoint, ')
          ..write('locked: $locked, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    connectionId,
    name,
    topicPrefix,
    colorSeed,
    iconCodepoint,
    locked,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dashboard &&
          other.id == this.id &&
          other.connectionId == this.connectionId &&
          other.name == this.name &&
          other.topicPrefix == this.topicPrefix &&
          other.colorSeed == this.colorSeed &&
          other.iconCodepoint == this.iconCodepoint &&
          other.locked == this.locked &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DashboardsCompanion extends UpdateCompanion<Dashboard> {
  final Value<String> id;
  final Value<String> connectionId;
  final Value<String> name;
  final Value<String?> topicPrefix;
  final Value<int> colorSeed;
  final Value<int> iconCodepoint;
  final Value<bool> locked;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DashboardsCompanion({
    this.id = const Value.absent(),
    this.connectionId = const Value.absent(),
    this.name = const Value.absent(),
    this.topicPrefix = const Value.absent(),
    this.colorSeed = const Value.absent(),
    this.iconCodepoint = const Value.absent(),
    this.locked = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DashboardsCompanion.insert({
    required String id,
    required String connectionId,
    required String name,
    this.topicPrefix = const Value.absent(),
    required int colorSeed,
    required int iconCodepoint,
    this.locked = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       connectionId = Value(connectionId),
       name = Value(name),
       colorSeed = Value(colorSeed),
       iconCodepoint = Value(iconCodepoint),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Dashboard> custom({
    Expression<String>? id,
    Expression<String>? connectionId,
    Expression<String>? name,
    Expression<String>? topicPrefix,
    Expression<int>? colorSeed,
    Expression<int>? iconCodepoint,
    Expression<bool>? locked,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (connectionId != null) 'connection_id': connectionId,
      if (name != null) 'name': name,
      if (topicPrefix != null) 'topic_prefix': topicPrefix,
      if (colorSeed != null) 'color_seed': colorSeed,
      if (iconCodepoint != null) 'icon_codepoint': iconCodepoint,
      if (locked != null) 'locked': locked,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DashboardsCompanion copyWith({
    Value<String>? id,
    Value<String>? connectionId,
    Value<String>? name,
    Value<String?>? topicPrefix,
    Value<int>? colorSeed,
    Value<int>? iconCodepoint,
    Value<bool>? locked,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DashboardsCompanion(
      id: id ?? this.id,
      connectionId: connectionId ?? this.connectionId,
      name: name ?? this.name,
      topicPrefix: topicPrefix ?? this.topicPrefix,
      colorSeed: colorSeed ?? this.colorSeed,
      iconCodepoint: iconCodepoint ?? this.iconCodepoint,
      locked: locked ?? this.locked,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (connectionId.present) {
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (topicPrefix.present) {
      map['topic_prefix'] = Variable<String>(topicPrefix.value);
    }
    if (colorSeed.present) {
      map['color_seed'] = Variable<int>(colorSeed.value);
    }
    if (iconCodepoint.present) {
      map['icon_codepoint'] = Variable<int>(iconCodepoint.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DashboardsCompanion(')
          ..write('id: $id, ')
          ..write('connectionId: $connectionId, ')
          ..write('name: $name, ')
          ..write('topicPrefix: $topicPrefix, ')
          ..write('colorSeed: $colorSeed, ')
          ..write('iconCodepoint: $iconCodepoint, ')
          ..write('locked: $locked, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SectionsTable extends Sections with TableInfo<$SectionsTable, Section> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dashboardIdMeta = const VerificationMeta(
    'dashboardId',
  );
  @override
  late final GeneratedColumn<String> dashboardId = GeneratedColumn<String>(
    'dashboard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dashboards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dashboardId,
    name,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Section> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dashboard_id')) {
      context.handle(
        _dashboardIdMeta,
        dashboardId.isAcceptableOrUnknown(
          data['dashboard_id']!,
          _dashboardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dashboardIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Section map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Section(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dashboardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dashboard_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SectionsTable createAlias(String alias) {
    return $SectionsTable(attachedDatabase, alias);
  }
}

class Section extends DataClass implements Insertable<Section> {
  final String id;
  final String dashboardId;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Section({
    required this.id,
    required this.dashboardId,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dashboard_id'] = Variable<String>(dashboardId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SectionsCompanion toCompanion(bool nullToAbsent) {
    return SectionsCompanion(
      id: Value(id),
      dashboardId: Value(dashboardId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Section.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Section(
      id: serializer.fromJson<String>(json['id']),
      dashboardId: serializer.fromJson<String>(json['dashboardId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dashboardId': serializer.toJson<String>(dashboardId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Section copyWith({
    String? id,
    String? dashboardId,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Section(
    id: id ?? this.id,
    dashboardId: dashboardId ?? this.dashboardId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Section copyWithCompanion(SectionsCompanion data) {
    return Section(
      id: data.id.present ? data.id.value : this.id,
      dashboardId: data.dashboardId.present
          ? data.dashboardId.value
          : this.dashboardId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Section(')
          ..write('id: $id, ')
          ..write('dashboardId: $dashboardId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dashboardId, name, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Section &&
          other.id == this.id &&
          other.dashboardId == this.dashboardId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SectionsCompanion extends UpdateCompanion<Section> {
  final Value<String> id;
  final Value<String> dashboardId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SectionsCompanion({
    this.id = const Value.absent(),
    this.dashboardId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SectionsCompanion.insert({
    required String id,
    required String dashboardId,
    required String name,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dashboardId = Value(dashboardId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Section> custom({
    Expression<String>? id,
    Expression<String>? dashboardId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dashboardId != null) 'dashboard_id': dashboardId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? dashboardId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SectionsCompanion(
      id: id ?? this.id,
      dashboardId: dashboardId ?? this.dashboardId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dashboardId.present) {
      map['dashboard_id'] = Variable<String>(dashboardId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionsCompanion(')
          ..write('id: $id, ')
          ..write('dashboardId: $dashboardId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PanelsTable extends Panels with TableInfo<$PanelsTable, Panel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PanelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dashboardIdMeta = const VerificationMeta(
    'dashboardId',
  );
  @override
  late final GeneratedColumn<String> dashboardId = GeneratedColumn<String>(
    'dashboard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dashboards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PanelType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PanelType>($PanelsTable.$convertertype);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subscribeTopicMeta = const VerificationMeta(
    'subscribeTopic',
  );
  @override
  late final GeneratedColumn<String> subscribeTopic = GeneratedColumn<String>(
    'subscribe_topic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topicPrefixOverrideMeta =
      const VerificationMeta('topicPrefixOverride');
  @override
  late final GeneratedColumn<String> topicPrefixOverride =
      GeneratedColumn<String>(
        'topic_prefix_override',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _qosMeta = const VerificationMeta('qos');
  @override
  late final GeneratedColumn<int> qos = GeneratedColumn<int>(
    'qos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _retainMeta = const VerificationMeta('retain');
  @override
  late final GeneratedColumn<bool> retain = GeneratedColumn<bool>(
    'retain',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("retain" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PanelWidth, String> width =
      GeneratedColumn<String>(
        'width',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PanelWidth>($PanelsTable.$converterwidth);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String> config = GeneratedColumn<String>(
    'config',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mergeFlagsMeta = const VerificationMeta(
    'mergeFlags',
  );
  @override
  late final GeneratedColumn<int> mergeFlags = GeneratedColumn<int>(
    'merge_flags',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sections (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _deviceIeeeMeta = const VerificationMeta(
    'deviceIeee',
  );
  @override
  late final GeneratedColumn<String> deviceIeee = GeneratedColumn<String>(
    'device_ieee',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dashboardId,
    name,
    type,
    topic,
    subscribeTopic,
    topicPrefixOverride,
    qos,
    retain,
    width,
    sortOrder,
    config,
    mergeFlags,
    createdAt,
    updatedAt,
    sectionId,
    deviceIeee,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'panels';
  @override
  VerificationContext validateIntegrity(
    Insertable<Panel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dashboard_id')) {
      context.handle(
        _dashboardIdMeta,
        dashboardId.isAcceptableOrUnknown(
          data['dashboard_id']!,
          _dashboardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dashboardIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('subscribe_topic')) {
      context.handle(
        _subscribeTopicMeta,
        subscribeTopic.isAcceptableOrUnknown(
          data['subscribe_topic']!,
          _subscribeTopicMeta,
        ),
      );
    }
    if (data.containsKey('topic_prefix_override')) {
      context.handle(
        _topicPrefixOverrideMeta,
        topicPrefixOverride.isAcceptableOrUnknown(
          data['topic_prefix_override']!,
          _topicPrefixOverrideMeta,
        ),
      );
    }
    if (data.containsKey('qos')) {
      context.handle(
        _qosMeta,
        qos.isAcceptableOrUnknown(data['qos']!, _qosMeta),
      );
    }
    if (data.containsKey('retain')) {
      context.handle(
        _retainMeta,
        retain.isAcceptableOrUnknown(data['retain']!, _retainMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('config')) {
      context.handle(
        _configMeta,
        config.isAcceptableOrUnknown(data['config']!, _configMeta),
      );
    } else if (isInserting) {
      context.missing(_configMeta);
    }
    if (data.containsKey('merge_flags')) {
      context.handle(
        _mergeFlagsMeta,
        mergeFlags.isAcceptableOrUnknown(data['merge_flags']!, _mergeFlagsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    }
    if (data.containsKey('device_ieee')) {
      context.handle(
        _deviceIeeeMeta,
        deviceIeee.isAcceptableOrUnknown(data['device_ieee']!, _deviceIeeeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Panel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Panel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dashboardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dashboard_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $PanelsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      )!,
      subscribeTopic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscribe_topic'],
      ),
      topicPrefixOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_prefix_override'],
      ),
      qos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qos'],
      )!,
      retain: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}retain'],
      )!,
      width: $PanelsTable.$converterwidth.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}width'],
        )!,
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      config: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config'],
      )!,
      mergeFlags: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}merge_flags'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      ),
      deviceIeee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_ieee'],
      ),
    );
  }

  @override
  $PanelsTable createAlias(String alias) {
    return $PanelsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PanelType, String, String> $convertertype =
      const EnumNameConverter<PanelType>(PanelType.values);
  static JsonTypeConverter2<PanelWidth, String, String> $converterwidth =
      const EnumNameConverter<PanelWidth>(PanelWidth.values);
}

class Panel extends DataClass implements Insertable<Panel> {
  final String id;
  final String dashboardId;
  final String name;
  final PanelType type;
  final String topic;
  final String? subscribeTopic;
  final String? topicPrefixOverride;
  final int qos;
  final bool retain;
  final PanelWidth width;
  final int sortOrder;
  final String config;
  final int mergeFlags;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// The section this tile sits in; null renders it first, without a header.
  final String? sectionId;

  /// IEEE address of the device this tile shows, if any. Decides whether a
  /// device is on a dashboard.
  final String? deviceIeee;
  const Panel({
    required this.id,
    required this.dashboardId,
    required this.name,
    required this.type,
    required this.topic,
    this.subscribeTopic,
    this.topicPrefixOverride,
    required this.qos,
    required this.retain,
    required this.width,
    required this.sortOrder,
    required this.config,
    required this.mergeFlags,
    required this.createdAt,
    required this.updatedAt,
    this.sectionId,
    this.deviceIeee,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dashboard_id'] = Variable<String>(dashboardId);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($PanelsTable.$convertertype.toSql(type));
    }
    map['topic'] = Variable<String>(topic);
    if (!nullToAbsent || subscribeTopic != null) {
      map['subscribe_topic'] = Variable<String>(subscribeTopic);
    }
    if (!nullToAbsent || topicPrefixOverride != null) {
      map['topic_prefix_override'] = Variable<String>(topicPrefixOverride);
    }
    map['qos'] = Variable<int>(qos);
    map['retain'] = Variable<bool>(retain);
    {
      map['width'] = Variable<String>(
        $PanelsTable.$converterwidth.toSql(width),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['config'] = Variable<String>(config);
    map['merge_flags'] = Variable<int>(mergeFlags);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || sectionId != null) {
      map['section_id'] = Variable<String>(sectionId);
    }
    if (!nullToAbsent || deviceIeee != null) {
      map['device_ieee'] = Variable<String>(deviceIeee);
    }
    return map;
  }

  PanelsCompanion toCompanion(bool nullToAbsent) {
    return PanelsCompanion(
      id: Value(id),
      dashboardId: Value(dashboardId),
      name: Value(name),
      type: Value(type),
      topic: Value(topic),
      subscribeTopic: subscribeTopic == null && nullToAbsent
          ? const Value.absent()
          : Value(subscribeTopic),
      topicPrefixOverride: topicPrefixOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(topicPrefixOverride),
      qos: Value(qos),
      retain: Value(retain),
      width: Value(width),
      sortOrder: Value(sortOrder),
      config: Value(config),
      mergeFlags: Value(mergeFlags),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sectionId: sectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sectionId),
      deviceIeee: deviceIeee == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceIeee),
    );
  }

  factory Panel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Panel(
      id: serializer.fromJson<String>(json['id']),
      dashboardId: serializer.fromJson<String>(json['dashboardId']),
      name: serializer.fromJson<String>(json['name']),
      type: $PanelsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      topic: serializer.fromJson<String>(json['topic']),
      subscribeTopic: serializer.fromJson<String?>(json['subscribeTopic']),
      topicPrefixOverride: serializer.fromJson<String?>(
        json['topicPrefixOverride'],
      ),
      qos: serializer.fromJson<int>(json['qos']),
      retain: serializer.fromJson<bool>(json['retain']),
      width: $PanelsTable.$converterwidth.fromJson(
        serializer.fromJson<String>(json['width']),
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      config: serializer.fromJson<String>(json['config']),
      mergeFlags: serializer.fromJson<int>(json['mergeFlags']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sectionId: serializer.fromJson<String?>(json['sectionId']),
      deviceIeee: serializer.fromJson<String?>(json['deviceIeee']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dashboardId': serializer.toJson<String>(dashboardId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $PanelsTable.$convertertype.toJson(type),
      ),
      'topic': serializer.toJson<String>(topic),
      'subscribeTopic': serializer.toJson<String?>(subscribeTopic),
      'topicPrefixOverride': serializer.toJson<String?>(topicPrefixOverride),
      'qos': serializer.toJson<int>(qos),
      'retain': serializer.toJson<bool>(retain),
      'width': serializer.toJson<String>(
        $PanelsTable.$converterwidth.toJson(width),
      ),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'config': serializer.toJson<String>(config),
      'mergeFlags': serializer.toJson<int>(mergeFlags),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sectionId': serializer.toJson<String?>(sectionId),
      'deviceIeee': serializer.toJson<String?>(deviceIeee),
    };
  }

  Panel copyWith({
    String? id,
    String? dashboardId,
    String? name,
    PanelType? type,
    String? topic,
    Value<String?> subscribeTopic = const Value.absent(),
    Value<String?> topicPrefixOverride = const Value.absent(),
    int? qos,
    bool? retain,
    PanelWidth? width,
    int? sortOrder,
    String? config,
    int? mergeFlags,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> sectionId = const Value.absent(),
    Value<String?> deviceIeee = const Value.absent(),
  }) => Panel(
    id: id ?? this.id,
    dashboardId: dashboardId ?? this.dashboardId,
    name: name ?? this.name,
    type: type ?? this.type,
    topic: topic ?? this.topic,
    subscribeTopic: subscribeTopic.present
        ? subscribeTopic.value
        : this.subscribeTopic,
    topicPrefixOverride: topicPrefixOverride.present
        ? topicPrefixOverride.value
        : this.topicPrefixOverride,
    qos: qos ?? this.qos,
    retain: retain ?? this.retain,
    width: width ?? this.width,
    sortOrder: sortOrder ?? this.sortOrder,
    config: config ?? this.config,
    mergeFlags: mergeFlags ?? this.mergeFlags,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sectionId: sectionId.present ? sectionId.value : this.sectionId,
    deviceIeee: deviceIeee.present ? deviceIeee.value : this.deviceIeee,
  );
  Panel copyWithCompanion(PanelsCompanion data) {
    return Panel(
      id: data.id.present ? data.id.value : this.id,
      dashboardId: data.dashboardId.present
          ? data.dashboardId.value
          : this.dashboardId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      topic: data.topic.present ? data.topic.value : this.topic,
      subscribeTopic: data.subscribeTopic.present
          ? data.subscribeTopic.value
          : this.subscribeTopic,
      topicPrefixOverride: data.topicPrefixOverride.present
          ? data.topicPrefixOverride.value
          : this.topicPrefixOverride,
      qos: data.qos.present ? data.qos.value : this.qos,
      retain: data.retain.present ? data.retain.value : this.retain,
      width: data.width.present ? data.width.value : this.width,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      config: data.config.present ? data.config.value : this.config,
      mergeFlags: data.mergeFlags.present
          ? data.mergeFlags.value
          : this.mergeFlags,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      deviceIeee: data.deviceIeee.present
          ? data.deviceIeee.value
          : this.deviceIeee,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Panel(')
          ..write('id: $id, ')
          ..write('dashboardId: $dashboardId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('topic: $topic, ')
          ..write('subscribeTopic: $subscribeTopic, ')
          ..write('topicPrefixOverride: $topicPrefixOverride, ')
          ..write('qos: $qos, ')
          ..write('retain: $retain, ')
          ..write('width: $width, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('config: $config, ')
          ..write('mergeFlags: $mergeFlags, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sectionId: $sectionId, ')
          ..write('deviceIeee: $deviceIeee')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dashboardId,
    name,
    type,
    topic,
    subscribeTopic,
    topicPrefixOverride,
    qos,
    retain,
    width,
    sortOrder,
    config,
    mergeFlags,
    createdAt,
    updatedAt,
    sectionId,
    deviceIeee,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Panel &&
          other.id == this.id &&
          other.dashboardId == this.dashboardId &&
          other.name == this.name &&
          other.type == this.type &&
          other.topic == this.topic &&
          other.subscribeTopic == this.subscribeTopic &&
          other.topicPrefixOverride == this.topicPrefixOverride &&
          other.qos == this.qos &&
          other.retain == this.retain &&
          other.width == this.width &&
          other.sortOrder == this.sortOrder &&
          other.config == this.config &&
          other.mergeFlags == this.mergeFlags &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sectionId == this.sectionId &&
          other.deviceIeee == this.deviceIeee);
}

class PanelsCompanion extends UpdateCompanion<Panel> {
  final Value<String> id;
  final Value<String> dashboardId;
  final Value<String> name;
  final Value<PanelType> type;
  final Value<String> topic;
  final Value<String?> subscribeTopic;
  final Value<String?> topicPrefixOverride;
  final Value<int> qos;
  final Value<bool> retain;
  final Value<PanelWidth> width;
  final Value<int> sortOrder;
  final Value<String> config;
  final Value<int> mergeFlags;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> sectionId;
  final Value<String?> deviceIeee;
  final Value<int> rowid;
  const PanelsCompanion({
    this.id = const Value.absent(),
    this.dashboardId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.topic = const Value.absent(),
    this.subscribeTopic = const Value.absent(),
    this.topicPrefixOverride = const Value.absent(),
    this.qos = const Value.absent(),
    this.retain = const Value.absent(),
    this.width = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.config = const Value.absent(),
    this.mergeFlags = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.deviceIeee = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PanelsCompanion.insert({
    required String id,
    required String dashboardId,
    required String name,
    required PanelType type,
    required String topic,
    this.subscribeTopic = const Value.absent(),
    this.topicPrefixOverride = const Value.absent(),
    this.qos = const Value.absent(),
    this.retain = const Value.absent(),
    required PanelWidth width,
    this.sortOrder = const Value.absent(),
    required String config,
    this.mergeFlags = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.sectionId = const Value.absent(),
    this.deviceIeee = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dashboardId = Value(dashboardId),
       name = Value(name),
       type = Value(type),
       topic = Value(topic),
       width = Value(width),
       config = Value(config),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Panel> custom({
    Expression<String>? id,
    Expression<String>? dashboardId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? topic,
    Expression<String>? subscribeTopic,
    Expression<String>? topicPrefixOverride,
    Expression<int>? qos,
    Expression<bool>? retain,
    Expression<String>? width,
    Expression<int>? sortOrder,
    Expression<String>? config,
    Expression<int>? mergeFlags,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? sectionId,
    Expression<String>? deviceIeee,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dashboardId != null) 'dashboard_id': dashboardId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (topic != null) 'topic': topic,
      if (subscribeTopic != null) 'subscribe_topic': subscribeTopic,
      if (topicPrefixOverride != null)
        'topic_prefix_override': topicPrefixOverride,
      if (qos != null) 'qos': qos,
      if (retain != null) 'retain': retain,
      if (width != null) 'width': width,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (config != null) 'config': config,
      if (mergeFlags != null) 'merge_flags': mergeFlags,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sectionId != null) 'section_id': sectionId,
      if (deviceIeee != null) 'device_ieee': deviceIeee,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PanelsCompanion copyWith({
    Value<String>? id,
    Value<String>? dashboardId,
    Value<String>? name,
    Value<PanelType>? type,
    Value<String>? topic,
    Value<String?>? subscribeTopic,
    Value<String?>? topicPrefixOverride,
    Value<int>? qos,
    Value<bool>? retain,
    Value<PanelWidth>? width,
    Value<int>? sortOrder,
    Value<String>? config,
    Value<int>? mergeFlags,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? sectionId,
    Value<String?>? deviceIeee,
    Value<int>? rowid,
  }) {
    return PanelsCompanion(
      id: id ?? this.id,
      dashboardId: dashboardId ?? this.dashboardId,
      name: name ?? this.name,
      type: type ?? this.type,
      topic: topic ?? this.topic,
      subscribeTopic: subscribeTopic ?? this.subscribeTopic,
      topicPrefixOverride: topicPrefixOverride ?? this.topicPrefixOverride,
      qos: qos ?? this.qos,
      retain: retain ?? this.retain,
      width: width ?? this.width,
      sortOrder: sortOrder ?? this.sortOrder,
      config: config ?? this.config,
      mergeFlags: mergeFlags ?? this.mergeFlags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sectionId: sectionId ?? this.sectionId,
      deviceIeee: deviceIeee ?? this.deviceIeee,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dashboardId.present) {
      map['dashboard_id'] = Variable<String>(dashboardId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $PanelsTable.$convertertype.toSql(type.value),
      );
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (subscribeTopic.present) {
      map['subscribe_topic'] = Variable<String>(subscribeTopic.value);
    }
    if (topicPrefixOverride.present) {
      map['topic_prefix_override'] = Variable<String>(
        topicPrefixOverride.value,
      );
    }
    if (qos.present) {
      map['qos'] = Variable<int>(qos.value);
    }
    if (retain.present) {
      map['retain'] = Variable<bool>(retain.value);
    }
    if (width.present) {
      map['width'] = Variable<String>(
        $PanelsTable.$converterwidth.toSql(width.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    if (mergeFlags.present) {
      map['merge_flags'] = Variable<int>(mergeFlags.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (deviceIeee.present) {
      map['device_ieee'] = Variable<String>(deviceIeee.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PanelsCompanion(')
          ..write('id: $id, ')
          ..write('dashboardId: $dashboardId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('topic: $topic, ')
          ..write('subscribeTopic: $subscribeTopic, ')
          ..write('topicPrefixOverride: $topicPrefixOverride, ')
          ..write('qos: $qos, ')
          ..write('retain: $retain, ')
          ..write('width: $width, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('config: $config, ')
          ..write('mergeFlags: $mergeFlags, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sectionId: $sectionId, ')
          ..write('deviceIeee: $deviceIeee, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScenesTable extends Scenes with TableInfo<$ScenesTable, Scene> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  @override
  late final GeneratedColumn<String> connectionId = GeneratedColumn<String>(
    'connection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES connections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodepointMeta = const VerificationMeta(
    'iconCodepoint',
  );
  @override
  late final GeneratedColumn<int> iconCodepoint = GeneratedColumn<int>(
    'icon_codepoint',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorSeedMeta = const VerificationMeta(
    'colorSeed',
  );
  @override
  late final GeneratedColumn<int> colorSeed = GeneratedColumn<int>(
    'color_seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionsMeta = const VerificationMeta(
    'actions',
  );
  @override
  late final GeneratedColumn<String> actions = GeneratedColumn<String>(
    'actions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    connectionId,
    name,
    iconCodepoint,
    colorSeed,
    actions,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scenes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Scene> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('connection_id')) {
      context.handle(
        _connectionIdMeta,
        connectionId.isAcceptableOrUnknown(
          data['connection_id']!,
          _connectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_codepoint')) {
      context.handle(
        _iconCodepointMeta,
        iconCodepoint.isAcceptableOrUnknown(
          data['icon_codepoint']!,
          _iconCodepointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iconCodepointMeta);
    }
    if (data.containsKey('color_seed')) {
      context.handle(
        _colorSeedMeta,
        colorSeed.isAcceptableOrUnknown(data['color_seed']!, _colorSeedMeta),
      );
    } else if (isInserting) {
      context.missing(_colorSeedMeta);
    }
    if (data.containsKey('actions')) {
      context.handle(
        _actionsMeta,
        actions.isAcceptableOrUnknown(data['actions']!, _actionsMeta),
      );
    } else if (isInserting) {
      context.missing(_actionsMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Scene map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Scene(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconCodepoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_codepoint'],
      )!,
      colorSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_seed'],
      )!,
      actions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actions'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ScenesTable createAlias(String alias) {
    return $ScenesTable(attachedDatabase, alias);
  }
}

class Scene extends DataClass implements Insertable<Scene> {
  final String id;
  final String connectionId;
  final String name;
  final int iconCodepoint;
  final int colorSeed;
  final String actions;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Scene({
    required this.id,
    required this.connectionId,
    required this.name,
    required this.iconCodepoint,
    required this.colorSeed,
    required this.actions,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['connection_id'] = Variable<String>(connectionId);
    map['name'] = Variable<String>(name);
    map['icon_codepoint'] = Variable<int>(iconCodepoint);
    map['color_seed'] = Variable<int>(colorSeed);
    map['actions'] = Variable<String>(actions);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScenesCompanion toCompanion(bool nullToAbsent) {
    return ScenesCompanion(
      id: Value(id),
      connectionId: Value(connectionId),
      name: Value(name),
      iconCodepoint: Value(iconCodepoint),
      colorSeed: Value(colorSeed),
      actions: Value(actions),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Scene.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Scene(
      id: serializer.fromJson<String>(json['id']),
      connectionId: serializer.fromJson<String>(json['connectionId']),
      name: serializer.fromJson<String>(json['name']),
      iconCodepoint: serializer.fromJson<int>(json['iconCodepoint']),
      colorSeed: serializer.fromJson<int>(json['colorSeed']),
      actions: serializer.fromJson<String>(json['actions']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'connectionId': serializer.toJson<String>(connectionId),
      'name': serializer.toJson<String>(name),
      'iconCodepoint': serializer.toJson<int>(iconCodepoint),
      'colorSeed': serializer.toJson<int>(colorSeed),
      'actions': serializer.toJson<String>(actions),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Scene copyWith({
    String? id,
    String? connectionId,
    String? name,
    int? iconCodepoint,
    int? colorSeed,
    String? actions,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Scene(
    id: id ?? this.id,
    connectionId: connectionId ?? this.connectionId,
    name: name ?? this.name,
    iconCodepoint: iconCodepoint ?? this.iconCodepoint,
    colorSeed: colorSeed ?? this.colorSeed,
    actions: actions ?? this.actions,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Scene copyWithCompanion(ScenesCompanion data) {
    return Scene(
      id: data.id.present ? data.id.value : this.id,
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      name: data.name.present ? data.name.value : this.name,
      iconCodepoint: data.iconCodepoint.present
          ? data.iconCodepoint.value
          : this.iconCodepoint,
      colorSeed: data.colorSeed.present ? data.colorSeed.value : this.colorSeed,
      actions: data.actions.present ? data.actions.value : this.actions,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Scene(')
          ..write('id: $id, ')
          ..write('connectionId: $connectionId, ')
          ..write('name: $name, ')
          ..write('iconCodepoint: $iconCodepoint, ')
          ..write('colorSeed: $colorSeed, ')
          ..write('actions: $actions, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    connectionId,
    name,
    iconCodepoint,
    colorSeed,
    actions,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Scene &&
          other.id == this.id &&
          other.connectionId == this.connectionId &&
          other.name == this.name &&
          other.iconCodepoint == this.iconCodepoint &&
          other.colorSeed == this.colorSeed &&
          other.actions == this.actions &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ScenesCompanion extends UpdateCompanion<Scene> {
  final Value<String> id;
  final Value<String> connectionId;
  final Value<String> name;
  final Value<int> iconCodepoint;
  final Value<int> colorSeed;
  final Value<String> actions;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ScenesCompanion({
    this.id = const Value.absent(),
    this.connectionId = const Value.absent(),
    this.name = const Value.absent(),
    this.iconCodepoint = const Value.absent(),
    this.colorSeed = const Value.absent(),
    this.actions = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScenesCompanion.insert({
    required String id,
    required String connectionId,
    required String name,
    required int iconCodepoint,
    required int colorSeed,
    required String actions,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       connectionId = Value(connectionId),
       name = Value(name),
       iconCodepoint = Value(iconCodepoint),
       colorSeed = Value(colorSeed),
       actions = Value(actions),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Scene> custom({
    Expression<String>? id,
    Expression<String>? connectionId,
    Expression<String>? name,
    Expression<int>? iconCodepoint,
    Expression<int>? colorSeed,
    Expression<String>? actions,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (connectionId != null) 'connection_id': connectionId,
      if (name != null) 'name': name,
      if (iconCodepoint != null) 'icon_codepoint': iconCodepoint,
      if (colorSeed != null) 'color_seed': colorSeed,
      if (actions != null) 'actions': actions,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScenesCompanion copyWith({
    Value<String>? id,
    Value<String>? connectionId,
    Value<String>? name,
    Value<int>? iconCodepoint,
    Value<int>? colorSeed,
    Value<String>? actions,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ScenesCompanion(
      id: id ?? this.id,
      connectionId: connectionId ?? this.connectionId,
      name: name ?? this.name,
      iconCodepoint: iconCodepoint ?? this.iconCodepoint,
      colorSeed: colorSeed ?? this.colorSeed,
      actions: actions ?? this.actions,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (connectionId.present) {
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconCodepoint.present) {
      map['icon_codepoint'] = Variable<int>(iconCodepoint.value);
    }
    if (colorSeed.present) {
      map['color_seed'] = Variable<int>(colorSeed.value);
    }
    if (actions.present) {
      map['actions'] = Variable<String>(actions.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenesCompanion(')
          ..write('id: $id, ')
          ..write('connectionId: $connectionId, ')
          ..write('name: $name, ')
          ..write('iconCodepoint: $iconCodepoint, ')
          ..write('colorSeed: $colorSeed, ')
          ..write('actions: $actions, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceDismissalsTable extends DeviceDismissals
    with TableInfo<$DeviceDismissalsTable, DeviceDismissal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceDismissalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  @override
  late final GeneratedColumn<String> connectionId = GeneratedColumn<String>(
    'connection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES connections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ieeeMeta = const VerificationMeta('ieee');
  @override
  late final GeneratedColumn<String> ieee = GeneratedColumn<String>(
    'ieee',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dismissedAtMeta = const VerificationMeta(
    'dismissedAt',
  );
  @override
  late final GeneratedColumn<DateTime> dismissedAt = GeneratedColumn<DateTime>(
    'dismissed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [connectionId, ieee, dismissedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_dismissals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceDismissal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('connection_id')) {
      context.handle(
        _connectionIdMeta,
        connectionId.isAcceptableOrUnknown(
          data['connection_id']!,
          _connectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionIdMeta);
    }
    if (data.containsKey('ieee')) {
      context.handle(
        _ieeeMeta,
        ieee.isAcceptableOrUnknown(data['ieee']!, _ieeeMeta),
      );
    } else if (isInserting) {
      context.missing(_ieeeMeta);
    }
    if (data.containsKey('dismissed_at')) {
      context.handle(
        _dismissedAtMeta,
        dismissedAt.isAcceptableOrUnknown(
          data['dismissed_at']!,
          _dismissedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dismissedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {connectionId, ieee};
  @override
  DeviceDismissal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceDismissal(
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      ieee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ieee'],
      )!,
      dismissedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dismissed_at'],
      )!,
    );
  }

  @override
  $DeviceDismissalsTable createAlias(String alias) {
    return $DeviceDismissalsTable(attachedDatabase, alias);
  }
}

class DeviceDismissal extends DataClass implements Insertable<DeviceDismissal> {
  final String connectionId;
  final String ieee;
  final DateTime dismissedAt;
  const DeviceDismissal({
    required this.connectionId,
    required this.ieee,
    required this.dismissedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['connection_id'] = Variable<String>(connectionId);
    map['ieee'] = Variable<String>(ieee);
    map['dismissed_at'] = Variable<DateTime>(dismissedAt);
    return map;
  }

  DeviceDismissalsCompanion toCompanion(bool nullToAbsent) {
    return DeviceDismissalsCompanion(
      connectionId: Value(connectionId),
      ieee: Value(ieee),
      dismissedAt: Value(dismissedAt),
    );
  }

  factory DeviceDismissal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceDismissal(
      connectionId: serializer.fromJson<String>(json['connectionId']),
      ieee: serializer.fromJson<String>(json['ieee']),
      dismissedAt: serializer.fromJson<DateTime>(json['dismissedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'connectionId': serializer.toJson<String>(connectionId),
      'ieee': serializer.toJson<String>(ieee),
      'dismissedAt': serializer.toJson<DateTime>(dismissedAt),
    };
  }

  DeviceDismissal copyWith({
    String? connectionId,
    String? ieee,
    DateTime? dismissedAt,
  }) => DeviceDismissal(
    connectionId: connectionId ?? this.connectionId,
    ieee: ieee ?? this.ieee,
    dismissedAt: dismissedAt ?? this.dismissedAt,
  );
  DeviceDismissal copyWithCompanion(DeviceDismissalsCompanion data) {
    return DeviceDismissal(
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      ieee: data.ieee.present ? data.ieee.value : this.ieee,
      dismissedAt: data.dismissedAt.present
          ? data.dismissedAt.value
          : this.dismissedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceDismissal(')
          ..write('connectionId: $connectionId, ')
          ..write('ieee: $ieee, ')
          ..write('dismissedAt: $dismissedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(connectionId, ieee, dismissedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceDismissal &&
          other.connectionId == this.connectionId &&
          other.ieee == this.ieee &&
          other.dismissedAt == this.dismissedAt);
}

class DeviceDismissalsCompanion extends UpdateCompanion<DeviceDismissal> {
  final Value<String> connectionId;
  final Value<String> ieee;
  final Value<DateTime> dismissedAt;
  final Value<int> rowid;
  const DeviceDismissalsCompanion({
    this.connectionId = const Value.absent(),
    this.ieee = const Value.absent(),
    this.dismissedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceDismissalsCompanion.insert({
    required String connectionId,
    required String ieee,
    required DateTime dismissedAt,
    this.rowid = const Value.absent(),
  }) : connectionId = Value(connectionId),
       ieee = Value(ieee),
       dismissedAt = Value(dismissedAt);
  static Insertable<DeviceDismissal> custom({
    Expression<String>? connectionId,
    Expression<String>? ieee,
    Expression<DateTime>? dismissedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (connectionId != null) 'connection_id': connectionId,
      if (ieee != null) 'ieee': ieee,
      if (dismissedAt != null) 'dismissed_at': dismissedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceDismissalsCompanion copyWith({
    Value<String>? connectionId,
    Value<String>? ieee,
    Value<DateTime>? dismissedAt,
    Value<int>? rowid,
  }) {
    return DeviceDismissalsCompanion(
      connectionId: connectionId ?? this.connectionId,
      ieee: ieee ?? this.ieee,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (connectionId.present) {
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (ieee.present) {
      map['ieee'] = Variable<String>(ieee.value);
    }
    if (dismissedAt.present) {
      map['dismissed_at'] = Variable<DateTime>(dismissedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceDismissalsCompanion(')
          ..write('connectionId: $connectionId, ')
          ..write('ieee: $ieee, ')
          ..write('dismissedAt: $dismissedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceHealthFlagsTable extends DeviceHealthFlags
    with TableInfo<$DeviceHealthFlagsTable, DeviceHealthFlag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceHealthFlagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  @override
  late final GeneratedColumn<String> connectionId = GeneratedColumn<String>(
    'connection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES connections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ieeeMeta = const VerificationMeta('ieee');
  @override
  late final GeneratedColumn<String> ieee = GeneratedColumn<String>(
    'ieee',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batteryLowMeta = const VerificationMeta(
    'batteryLow',
  );
  @override
  late final GeneratedColumn<bool> batteryLow = GeneratedColumn<bool>(
    'battery_low',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("battery_low" IN (0, 1))',
    ),
  );
  static const VerificationMeta _acknowledgedMeta = const VerificationMeta(
    'acknowledged',
  );
  @override
  late final GeneratedColumn<bool> acknowledged = GeneratedColumn<bool>(
    'acknowledged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("acknowledged" IN (0, 1))',
    ),
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    connectionId,
    ieee,
    batteryLow,
    acknowledged,
    changedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_health_flags';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceHealthFlag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('connection_id')) {
      context.handle(
        _connectionIdMeta,
        connectionId.isAcceptableOrUnknown(
          data['connection_id']!,
          _connectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionIdMeta);
    }
    if (data.containsKey('ieee')) {
      context.handle(
        _ieeeMeta,
        ieee.isAcceptableOrUnknown(data['ieee']!, _ieeeMeta),
      );
    } else if (isInserting) {
      context.missing(_ieeeMeta);
    }
    if (data.containsKey('battery_low')) {
      context.handle(
        _batteryLowMeta,
        batteryLow.isAcceptableOrUnknown(data['battery_low']!, _batteryLowMeta),
      );
    } else if (isInserting) {
      context.missing(_batteryLowMeta);
    }
    if (data.containsKey('acknowledged')) {
      context.handle(
        _acknowledgedMeta,
        acknowledged.isAcceptableOrUnknown(
          data['acknowledged']!,
          _acknowledgedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_acknowledgedMeta);
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {connectionId, ieee};
  @override
  DeviceHealthFlag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceHealthFlag(
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      ieee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ieee'],
      )!,
      batteryLow: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}battery_low'],
      )!,
      acknowledged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}acknowledged'],
      )!,
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      )!,
    );
  }

  @override
  $DeviceHealthFlagsTable createAlias(String alias) {
    return $DeviceHealthFlagsTable(attachedDatabase, alias);
  }
}

class DeviceHealthFlag extends DataClass
    implements Insertable<DeviceHealthFlag> {
  final String connectionId;
  final String ieee;
  final bool batteryLow;
  final bool acknowledged;
  final DateTime changedAt;
  const DeviceHealthFlag({
    required this.connectionId,
    required this.ieee,
    required this.batteryLow,
    required this.acknowledged,
    required this.changedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['connection_id'] = Variable<String>(connectionId);
    map['ieee'] = Variable<String>(ieee);
    map['battery_low'] = Variable<bool>(batteryLow);
    map['acknowledged'] = Variable<bool>(acknowledged);
    map['changed_at'] = Variable<DateTime>(changedAt);
    return map;
  }

  DeviceHealthFlagsCompanion toCompanion(bool nullToAbsent) {
    return DeviceHealthFlagsCompanion(
      connectionId: Value(connectionId),
      ieee: Value(ieee),
      batteryLow: Value(batteryLow),
      acknowledged: Value(acknowledged),
      changedAt: Value(changedAt),
    );
  }

  factory DeviceHealthFlag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceHealthFlag(
      connectionId: serializer.fromJson<String>(json['connectionId']),
      ieee: serializer.fromJson<String>(json['ieee']),
      batteryLow: serializer.fromJson<bool>(json['batteryLow']),
      acknowledged: serializer.fromJson<bool>(json['acknowledged']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'connectionId': serializer.toJson<String>(connectionId),
      'ieee': serializer.toJson<String>(ieee),
      'batteryLow': serializer.toJson<bool>(batteryLow),
      'acknowledged': serializer.toJson<bool>(acknowledged),
      'changedAt': serializer.toJson<DateTime>(changedAt),
    };
  }

  DeviceHealthFlag copyWith({
    String? connectionId,
    String? ieee,
    bool? batteryLow,
    bool? acknowledged,
    DateTime? changedAt,
  }) => DeviceHealthFlag(
    connectionId: connectionId ?? this.connectionId,
    ieee: ieee ?? this.ieee,
    batteryLow: batteryLow ?? this.batteryLow,
    acknowledged: acknowledged ?? this.acknowledged,
    changedAt: changedAt ?? this.changedAt,
  );
  DeviceHealthFlag copyWithCompanion(DeviceHealthFlagsCompanion data) {
    return DeviceHealthFlag(
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      ieee: data.ieee.present ? data.ieee.value : this.ieee,
      batteryLow: data.batteryLow.present
          ? data.batteryLow.value
          : this.batteryLow,
      acknowledged: data.acknowledged.present
          ? data.acknowledged.value
          : this.acknowledged,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceHealthFlag(')
          ..write('connectionId: $connectionId, ')
          ..write('ieee: $ieee, ')
          ..write('batteryLow: $batteryLow, ')
          ..write('acknowledged: $acknowledged, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(connectionId, ieee, batteryLow, acknowledged, changedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceHealthFlag &&
          other.connectionId == this.connectionId &&
          other.ieee == this.ieee &&
          other.batteryLow == this.batteryLow &&
          other.acknowledged == this.acknowledged &&
          other.changedAt == this.changedAt);
}

class DeviceHealthFlagsCompanion extends UpdateCompanion<DeviceHealthFlag> {
  final Value<String> connectionId;
  final Value<String> ieee;
  final Value<bool> batteryLow;
  final Value<bool> acknowledged;
  final Value<DateTime> changedAt;
  final Value<int> rowid;
  const DeviceHealthFlagsCompanion({
    this.connectionId = const Value.absent(),
    this.ieee = const Value.absent(),
    this.batteryLow = const Value.absent(),
    this.acknowledged = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceHealthFlagsCompanion.insert({
    required String connectionId,
    required String ieee,
    required bool batteryLow,
    required bool acknowledged,
    required DateTime changedAt,
    this.rowid = const Value.absent(),
  }) : connectionId = Value(connectionId),
       ieee = Value(ieee),
       batteryLow = Value(batteryLow),
       acknowledged = Value(acknowledged),
       changedAt = Value(changedAt);
  static Insertable<DeviceHealthFlag> custom({
    Expression<String>? connectionId,
    Expression<String>? ieee,
    Expression<bool>? batteryLow,
    Expression<bool>? acknowledged,
    Expression<DateTime>? changedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (connectionId != null) 'connection_id': connectionId,
      if (ieee != null) 'ieee': ieee,
      if (batteryLow != null) 'battery_low': batteryLow,
      if (acknowledged != null) 'acknowledged': acknowledged,
      if (changedAt != null) 'changed_at': changedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceHealthFlagsCompanion copyWith({
    Value<String>? connectionId,
    Value<String>? ieee,
    Value<bool>? batteryLow,
    Value<bool>? acknowledged,
    Value<DateTime>? changedAt,
    Value<int>? rowid,
  }) {
    return DeviceHealthFlagsCompanion(
      connectionId: connectionId ?? this.connectionId,
      ieee: ieee ?? this.ieee,
      batteryLow: batteryLow ?? this.batteryLow,
      acknowledged: acknowledged ?? this.acknowledged,
      changedAt: changedAt ?? this.changedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (connectionId.present) {
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (ieee.present) {
      map['ieee'] = Variable<String>(ieee.value);
    }
    if (batteryLow.present) {
      map['battery_low'] = Variable<bool>(batteryLow.value);
    }
    if (acknowledged.present) {
      map['acknowledged'] = Variable<bool>(acknowledged.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceHealthFlagsCompanion(')
          ..write('connectionId: $connectionId, ')
          ..write('ieee: $ieee, ')
          ..write('batteryLow: $batteryLow, ')
          ..write('acknowledged: $acknowledged, ')
          ..write('changedAt: $changedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConnectionsTable connections = $ConnectionsTable(this);
  late final $DashboardsTable dashboards = $DashboardsTable(this);
  late final $SectionsTable sections = $SectionsTable(this);
  late final $PanelsTable panels = $PanelsTable(this);
  late final $ScenesTable scenes = $ScenesTable(this);
  late final $DeviceDismissalsTable deviceDismissals = $DeviceDismissalsTable(
    this,
  );
  late final $DeviceHealthFlagsTable deviceHealthFlags =
      $DeviceHealthFlagsTable(this);
  late final Index panelsDeviceIeee = Index(
    'panels_device_ieee',
    'CREATE INDEX panels_device_ieee ON panels (device_ieee)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    connections,
    dashboards,
    sections,
    panels,
    scenes,
    deviceDismissals,
    deviceHealthFlags,
    panelsDeviceIeee,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'connections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('dashboards', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'dashboards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'dashboards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('panels', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('panels', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'connections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scenes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'connections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('device_dismissals', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'connections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('device_health_flags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ConnectionsTableCreateCompanionBuilder =
    ConnectionsCompanion Function({
      required String id,
      required String name,
      required String host,
      required int port,
      required MqttProtocol protocol,
      Value<String?> username,
      Value<int> keepAliveSeconds,
      Value<bool> autoConnect,
      Value<String?> homeDashboardId,
      Value<String?> remoteHost,
      Value<DateTime?> devicesSeenAt,
      Value<String?> z2mBaseTopic,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ConnectionsTableUpdateCompanionBuilder =
    ConnectionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> host,
      Value<int> port,
      Value<MqttProtocol> protocol,
      Value<String?> username,
      Value<int> keepAliveSeconds,
      Value<bool> autoConnect,
      Value<String?> homeDashboardId,
      Value<String?> remoteHost,
      Value<DateTime?> devicesSeenAt,
      Value<String?> z2mBaseTopic,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ConnectionsTableReferences
    extends BaseReferences<_$AppDatabase, $ConnectionsTable, Connection> {
  $$ConnectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DashboardsTable, List<Dashboard>>
  _dashboardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dashboards,
    aliasName: $_aliasNameGenerator(
      db.connections.id,
      db.dashboards.connectionId,
    ),
  );

  $$DashboardsTableProcessedTableManager get dashboardsRefs {
    final manager = $$DashboardsTableTableManager(
      $_db,
      $_db.dashboards,
    ).filter((f) => f.connectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dashboardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScenesTable, List<Scene>> _scenesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.scenes,
    aliasName: $_aliasNameGenerator(db.connections.id, db.scenes.connectionId),
  );

  $$ScenesTableProcessedTableManager get scenesRefs {
    final manager = $$ScenesTableTableManager(
      $_db,
      $_db.scenes,
    ).filter((f) => f.connectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scenesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DeviceDismissalsTable, List<DeviceDismissal>>
  _deviceDismissalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deviceDismissals,
    aliasName: $_aliasNameGenerator(
      db.connections.id,
      db.deviceDismissals.connectionId,
    ),
  );

  $$DeviceDismissalsTableProcessedTableManager get deviceDismissalsRefs {
    final manager = $$DeviceDismissalsTableTableManager(
      $_db,
      $_db.deviceDismissals,
    ).filter((f) => f.connectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deviceDismissalsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DeviceHealthFlagsTable, List<DeviceHealthFlag>>
  _deviceHealthFlagsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.deviceHealthFlags,
        aliasName: $_aliasNameGenerator(
          db.connections.id,
          db.deviceHealthFlags.connectionId,
        ),
      );

  $$DeviceHealthFlagsTableProcessedTableManager get deviceHealthFlagsRefs {
    final manager = $$DeviceHealthFlagsTableTableManager(
      $_db,
      $_db.deviceHealthFlags,
    ).filter((f) => f.connectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deviceHealthFlagsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConnectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ConnectionsTable> {
  $$ConnectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MqttProtocol, MqttProtocol, String>
  get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keepAliveSeconds => $composableBuilder(
    column: $table.keepAliveSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoConnect => $composableBuilder(
    column: $table.autoConnect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeDashboardId => $composableBuilder(
    column: $table.homeDashboardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteHost => $composableBuilder(
    column: $table.remoteHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get devicesSeenAt => $composableBuilder(
    column: $table.devicesSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get z2mBaseTopic => $composableBuilder(
    column: $table.z2mBaseTopic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dashboardsRefs(
    Expression<bool> Function($$DashboardsTableFilterComposer f) f,
  ) {
    final $$DashboardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dashboards,
      getReferencedColumn: (t) => t.connectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DashboardsTableFilterComposer(
            $db: $db,
            $table: $db.dashboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scenesRefs(
    Expression<bool> Function($$ScenesTableFilterComposer f) f,
  ) {
    final $$ScenesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.connectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableFilterComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> deviceDismissalsRefs(
    Expression<bool> Function($$DeviceDismissalsTableFilterComposer f) f,
  ) {
    final $$DeviceDismissalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceDismissals,
      getReferencedColumn: (t) => t.connectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceDismissalsTableFilterComposer(
            $db: $db,
            $table: $db.deviceDismissals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> deviceHealthFlagsRefs(
    Expression<bool> Function($$DeviceHealthFlagsTableFilterComposer f) f,
  ) {
    final $$DeviceHealthFlagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceHealthFlags,
      getReferencedColumn: (t) => t.connectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceHealthFlagsTableFilterComposer(
            $db: $db,
            $table: $db.deviceHealthFlags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConnectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConnectionsTable> {
  $$ConnectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keepAliveSeconds => $composableBuilder(
    column: $table.keepAliveSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoConnect => $composableBuilder(
    column: $table.autoConnect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeDashboardId => $composableBuilder(
    column: $table.homeDashboardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteHost => $composableBuilder(
    column: $table.remoteHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get devicesSeenAt => $composableBuilder(
    column: $table.devicesSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get z2mBaseTopic => $composableBuilder(
    column: $table.z2mBaseTopic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConnectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConnectionsTable> {
  $$ConnectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MqttProtocol, String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<int> get keepAliveSeconds => $composableBuilder(
    column: $table.keepAliveSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoConnect => $composableBuilder(
    column: $table.autoConnect,
    builder: (column) => column,
  );

  GeneratedColumn<String> get homeDashboardId => $composableBuilder(
    column: $table.homeDashboardId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteHost => $composableBuilder(
    column: $table.remoteHost,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get devicesSeenAt => $composableBuilder(
    column: $table.devicesSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get z2mBaseTopic => $composableBuilder(
    column: $table.z2mBaseTopic,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> dashboardsRefs<T extends Object>(
    Expression<T> Function($$DashboardsTableAnnotationComposer a) f,
  ) {
    final $$DashboardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dashboards,
      getReferencedColumn: (t) => t.connectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DashboardsTableAnnotationComposer(
            $db: $db,
            $table: $db.dashboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scenesRefs<T extends Object>(
    Expression<T> Function($$ScenesTableAnnotationComposer a) f,
  ) {
    final $$ScenesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scenes,
      getReferencedColumn: (t) => t.connectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenesTableAnnotationComposer(
            $db: $db,
            $table: $db.scenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> deviceDismissalsRefs<T extends Object>(
    Expression<T> Function($$DeviceDismissalsTableAnnotationComposer a) f,
  ) {
    final $$DeviceDismissalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceDismissals,
      getReferencedColumn: (t) => t.connectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceDismissalsTableAnnotationComposer(
            $db: $db,
            $table: $db.deviceDismissals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> deviceHealthFlagsRefs<T extends Object>(
    Expression<T> Function($$DeviceHealthFlagsTableAnnotationComposer a) f,
  ) {
    final $$DeviceHealthFlagsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.deviceHealthFlags,
          getReferencedColumn: (t) => t.connectionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DeviceHealthFlagsTableAnnotationComposer(
                $db: $db,
                $table: $db.deviceHealthFlags,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ConnectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConnectionsTable,
          Connection,
          $$ConnectionsTableFilterComposer,
          $$ConnectionsTableOrderingComposer,
          $$ConnectionsTableAnnotationComposer,
          $$ConnectionsTableCreateCompanionBuilder,
          $$ConnectionsTableUpdateCompanionBuilder,
          (Connection, $$ConnectionsTableReferences),
          Connection,
          PrefetchHooks Function({
            bool dashboardsRefs,
            bool scenesRefs,
            bool deviceDismissalsRefs,
            bool deviceHealthFlagsRefs,
          })
        > {
  $$ConnectionsTableTableManager(_$AppDatabase db, $ConnectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConnectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConnectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConnectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<MqttProtocol> protocol = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<int> keepAliveSeconds = const Value.absent(),
                Value<bool> autoConnect = const Value.absent(),
                Value<String?> homeDashboardId = const Value.absent(),
                Value<String?> remoteHost = const Value.absent(),
                Value<DateTime?> devicesSeenAt = const Value.absent(),
                Value<String?> z2mBaseTopic = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionsCompanion(
                id: id,
                name: name,
                host: host,
                port: port,
                protocol: protocol,
                username: username,
                keepAliveSeconds: keepAliveSeconds,
                autoConnect: autoConnect,
                homeDashboardId: homeDashboardId,
                remoteHost: remoteHost,
                devicesSeenAt: devicesSeenAt,
                z2mBaseTopic: z2mBaseTopic,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String host,
                required int port,
                required MqttProtocol protocol,
                Value<String?> username = const Value.absent(),
                Value<int> keepAliveSeconds = const Value.absent(),
                Value<bool> autoConnect = const Value.absent(),
                Value<String?> homeDashboardId = const Value.absent(),
                Value<String?> remoteHost = const Value.absent(),
                Value<DateTime?> devicesSeenAt = const Value.absent(),
                Value<String?> z2mBaseTopic = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ConnectionsCompanion.insert(
                id: id,
                name: name,
                host: host,
                port: port,
                protocol: protocol,
                username: username,
                keepAliveSeconds: keepAliveSeconds,
                autoConnect: autoConnect,
                homeDashboardId: homeDashboardId,
                remoteHost: remoteHost,
                devicesSeenAt: devicesSeenAt,
                z2mBaseTopic: z2mBaseTopic,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConnectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                dashboardsRefs = false,
                scenesRefs = false,
                deviceDismissalsRefs = false,
                deviceHealthFlagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (dashboardsRefs) db.dashboards,
                    if (scenesRefs) db.scenes,
                    if (deviceDismissalsRefs) db.deviceDismissals,
                    if (deviceHealthFlagsRefs) db.deviceHealthFlags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (dashboardsRefs)
                        await $_getPrefetchedData<
                          Connection,
                          $ConnectionsTable,
                          Dashboard
                        >(
                          currentTable: table,
                          referencedTable: $$ConnectionsTableReferences
                              ._dashboardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConnectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).dashboardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.connectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scenesRefs)
                        await $_getPrefetchedData<
                          Connection,
                          $ConnectionsTable,
                          Scene
                        >(
                          currentTable: table,
                          referencedTable: $$ConnectionsTableReferences
                              ._scenesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConnectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).scenesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.connectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (deviceDismissalsRefs)
                        await $_getPrefetchedData<
                          Connection,
                          $ConnectionsTable,
                          DeviceDismissal
                        >(
                          currentTable: table,
                          referencedTable: $$ConnectionsTableReferences
                              ._deviceDismissalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConnectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).deviceDismissalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.connectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (deviceHealthFlagsRefs)
                        await $_getPrefetchedData<
                          Connection,
                          $ConnectionsTable,
                          DeviceHealthFlag
                        >(
                          currentTable: table,
                          referencedTable: $$ConnectionsTableReferences
                              ._deviceHealthFlagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConnectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).deviceHealthFlagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.connectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConnectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConnectionsTable,
      Connection,
      $$ConnectionsTableFilterComposer,
      $$ConnectionsTableOrderingComposer,
      $$ConnectionsTableAnnotationComposer,
      $$ConnectionsTableCreateCompanionBuilder,
      $$ConnectionsTableUpdateCompanionBuilder,
      (Connection, $$ConnectionsTableReferences),
      Connection,
      PrefetchHooks Function({
        bool dashboardsRefs,
        bool scenesRefs,
        bool deviceDismissalsRefs,
        bool deviceHealthFlagsRefs,
      })
    >;
typedef $$DashboardsTableCreateCompanionBuilder =
    DashboardsCompanion Function({
      required String id,
      required String connectionId,
      required String name,
      Value<String?> topicPrefix,
      required int colorSeed,
      required int iconCodepoint,
      Value<bool> locked,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DashboardsTableUpdateCompanionBuilder =
    DashboardsCompanion Function({
      Value<String> id,
      Value<String> connectionId,
      Value<String> name,
      Value<String?> topicPrefix,
      Value<int> colorSeed,
      Value<int> iconCodepoint,
      Value<bool> locked,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DashboardsTableReferences
    extends BaseReferences<_$AppDatabase, $DashboardsTable, Dashboard> {
  $$DashboardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConnectionsTable _connectionIdTable(_$AppDatabase db) =>
      db.connections.createAlias(
        $_aliasNameGenerator(db.dashboards.connectionId, db.connections.id),
      );

  $$ConnectionsTableProcessedTableManager get connectionId {
    final $_column = $_itemColumn<String>('connection_id')!;

    final manager = $$ConnectionsTableTableManager(
      $_db,
      $_db.connections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_connectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SectionsTable, List<Section>> _sectionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sections,
    aliasName: $_aliasNameGenerator(db.dashboards.id, db.sections.dashboardId),
  );

  $$SectionsTableProcessedTableManager get sectionsRefs {
    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.dashboardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PanelsTable, List<Panel>> _panelsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.panels,
    aliasName: $_aliasNameGenerator(db.dashboards.id, db.panels.dashboardId),
  );

  $$PanelsTableProcessedTableManager get panelsRefs {
    final manager = $$PanelsTableTableManager(
      $_db,
      $_db.panels,
    ).filter((f) => f.dashboardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_panelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DashboardsTableFilterComposer
    extends Composer<_$AppDatabase, $DashboardsTable> {
  $$DashboardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicPrefix => $composableBuilder(
    column: $table.topicPrefix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorSeed => $composableBuilder(
    column: $table.colorSeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodepoint => $composableBuilder(
    column: $table.iconCodepoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConnectionsTableFilterComposer get connectionId {
    final $$ConnectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableFilterComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sectionsRefs(
    Expression<bool> Function($$SectionsTableFilterComposer f) f,
  ) {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.dashboardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> panelsRefs(
    Expression<bool> Function($$PanelsTableFilterComposer f) f,
  ) {
    final $$PanelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.panels,
      getReferencedColumn: (t) => t.dashboardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PanelsTableFilterComposer(
            $db: $db,
            $table: $db.panels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DashboardsTableOrderingComposer
    extends Composer<_$AppDatabase, $DashboardsTable> {
  $$DashboardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicPrefix => $composableBuilder(
    column: $table.topicPrefix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorSeed => $composableBuilder(
    column: $table.colorSeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodepoint => $composableBuilder(
    column: $table.iconCodepoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConnectionsTableOrderingComposer get connectionId {
    final $$ConnectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableOrderingComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DashboardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DashboardsTable> {
  $$DashboardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get topicPrefix => $composableBuilder(
    column: $table.topicPrefix,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorSeed =>
      $composableBuilder(column: $table.colorSeed, builder: (column) => column);

  GeneratedColumn<int> get iconCodepoint => $composableBuilder(
    column: $table.iconCodepoint,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ConnectionsTableAnnotationComposer get connectionId {
    final $$ConnectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sectionsRefs<T extends Object>(
    Expression<T> Function($$SectionsTableAnnotationComposer a) f,
  ) {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.dashboardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> panelsRefs<T extends Object>(
    Expression<T> Function($$PanelsTableAnnotationComposer a) f,
  ) {
    final $$PanelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.panels,
      getReferencedColumn: (t) => t.dashboardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PanelsTableAnnotationComposer(
            $db: $db,
            $table: $db.panels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DashboardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DashboardsTable,
          Dashboard,
          $$DashboardsTableFilterComposer,
          $$DashboardsTableOrderingComposer,
          $$DashboardsTableAnnotationComposer,
          $$DashboardsTableCreateCompanionBuilder,
          $$DashboardsTableUpdateCompanionBuilder,
          (Dashboard, $$DashboardsTableReferences),
          Dashboard,
          PrefetchHooks Function({
            bool connectionId,
            bool sectionsRefs,
            bool panelsRefs,
          })
        > {
  $$DashboardsTableTableManager(_$AppDatabase db, $DashboardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DashboardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DashboardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DashboardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> connectionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> topicPrefix = const Value.absent(),
                Value<int> colorSeed = const Value.absent(),
                Value<int> iconCodepoint = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DashboardsCompanion(
                id: id,
                connectionId: connectionId,
                name: name,
                topicPrefix: topicPrefix,
                colorSeed: colorSeed,
                iconCodepoint: iconCodepoint,
                locked: locked,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String connectionId,
                required String name,
                Value<String?> topicPrefix = const Value.absent(),
                required int colorSeed,
                required int iconCodepoint,
                Value<bool> locked = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DashboardsCompanion.insert(
                id: id,
                connectionId: connectionId,
                name: name,
                topicPrefix: topicPrefix,
                colorSeed: colorSeed,
                iconCodepoint: iconCodepoint,
                locked: locked,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DashboardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                connectionId = false,
                sectionsRefs = false,
                panelsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sectionsRefs) db.sections,
                    if (panelsRefs) db.panels,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (connectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.connectionId,
                                    referencedTable: $$DashboardsTableReferences
                                        ._connectionIdTable(db),
                                    referencedColumn:
                                        $$DashboardsTableReferences
                                            ._connectionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sectionsRefs)
                        await $_getPrefetchedData<
                          Dashboard,
                          $DashboardsTable,
                          Section
                        >(
                          currentTable: table,
                          referencedTable: $$DashboardsTableReferences
                              ._sectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DashboardsTableReferences(
                                db,
                                table,
                                p0,
                              ).sectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dashboardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (panelsRefs)
                        await $_getPrefetchedData<
                          Dashboard,
                          $DashboardsTable,
                          Panel
                        >(
                          currentTable: table,
                          referencedTable: $$DashboardsTableReferences
                              ._panelsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DashboardsTableReferences(
                                db,
                                table,
                                p0,
                              ).panelsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dashboardId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DashboardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DashboardsTable,
      Dashboard,
      $$DashboardsTableFilterComposer,
      $$DashboardsTableOrderingComposer,
      $$DashboardsTableAnnotationComposer,
      $$DashboardsTableCreateCompanionBuilder,
      $$DashboardsTableUpdateCompanionBuilder,
      (Dashboard, $$DashboardsTableReferences),
      Dashboard,
      PrefetchHooks Function({
        bool connectionId,
        bool sectionsRefs,
        bool panelsRefs,
      })
    >;
typedef $$SectionsTableCreateCompanionBuilder =
    SectionsCompanion Function({
      required String id,
      required String dashboardId,
      required String name,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SectionsTableUpdateCompanionBuilder =
    SectionsCompanion Function({
      Value<String> id,
      Value<String> dashboardId,
      Value<String> name,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SectionsTableReferences
    extends BaseReferences<_$AppDatabase, $SectionsTable, Section> {
  $$SectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DashboardsTable _dashboardIdTable(_$AppDatabase db) =>
      db.dashboards.createAlias(
        $_aliasNameGenerator(db.sections.dashboardId, db.dashboards.id),
      );

  $$DashboardsTableProcessedTableManager get dashboardId {
    final $_column = $_itemColumn<String>('dashboard_id')!;

    final manager = $$DashboardsTableTableManager(
      $_db,
      $_db.dashboards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dashboardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PanelsTable, List<Panel>> _panelsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.panels,
    aliasName: $_aliasNameGenerator(db.sections.id, db.panels.sectionId),
  );

  $$PanelsTableProcessedTableManager get panelsRefs {
    final manager = $$PanelsTableTableManager(
      $_db,
      $_db.panels,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_panelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DashboardsTableFilterComposer get dashboardId {
    final $$DashboardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dashboardId,
      referencedTable: $db.dashboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DashboardsTableFilterComposer(
            $db: $db,
            $table: $db.dashboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> panelsRefs(
    Expression<bool> Function($$PanelsTableFilterComposer f) f,
  ) {
    final $$PanelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.panels,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PanelsTableFilterComposer(
            $db: $db,
            $table: $db.panels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DashboardsTableOrderingComposer get dashboardId {
    final $$DashboardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dashboardId,
      referencedTable: $db.dashboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DashboardsTableOrderingComposer(
            $db: $db,
            $table: $db.dashboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DashboardsTableAnnotationComposer get dashboardId {
    final $$DashboardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dashboardId,
      referencedTable: $db.dashboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DashboardsTableAnnotationComposer(
            $db: $db,
            $table: $db.dashboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> panelsRefs<T extends Object>(
    Expression<T> Function($$PanelsTableAnnotationComposer a) f,
  ) {
    final $$PanelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.panels,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PanelsTableAnnotationComposer(
            $db: $db,
            $table: $db.panels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SectionsTable,
          Section,
          $$SectionsTableFilterComposer,
          $$SectionsTableOrderingComposer,
          $$SectionsTableAnnotationComposer,
          $$SectionsTableCreateCompanionBuilder,
          $$SectionsTableUpdateCompanionBuilder,
          (Section, $$SectionsTableReferences),
          Section,
          PrefetchHooks Function({bool dashboardId, bool panelsRefs})
        > {
  $$SectionsTableTableManager(_$AppDatabase db, $SectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dashboardId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SectionsCompanion(
                id: id,
                dashboardId: dashboardId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dashboardId,
                required String name,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SectionsCompanion.insert(
                id: id,
                dashboardId: dashboardId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dashboardId = false, panelsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (panelsRefs) db.panels],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dashboardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dashboardId,
                                referencedTable: $$SectionsTableReferences
                                    ._dashboardIdTable(db),
                                referencedColumn: $$SectionsTableReferences
                                    ._dashboardIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (panelsRefs)
                    await $_getPrefetchedData<Section, $SectionsTable, Panel>(
                      currentTable: table,
                      referencedTable: $$SectionsTableReferences
                          ._panelsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SectionsTableReferences(db, table, p0).panelsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sectionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SectionsTable,
      Section,
      $$SectionsTableFilterComposer,
      $$SectionsTableOrderingComposer,
      $$SectionsTableAnnotationComposer,
      $$SectionsTableCreateCompanionBuilder,
      $$SectionsTableUpdateCompanionBuilder,
      (Section, $$SectionsTableReferences),
      Section,
      PrefetchHooks Function({bool dashboardId, bool panelsRefs})
    >;
typedef $$PanelsTableCreateCompanionBuilder =
    PanelsCompanion Function({
      required String id,
      required String dashboardId,
      required String name,
      required PanelType type,
      required String topic,
      Value<String?> subscribeTopic,
      Value<String?> topicPrefixOverride,
      Value<int> qos,
      Value<bool> retain,
      required PanelWidth width,
      Value<int> sortOrder,
      required String config,
      Value<int> mergeFlags,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> sectionId,
      Value<String?> deviceIeee,
      Value<int> rowid,
    });
typedef $$PanelsTableUpdateCompanionBuilder =
    PanelsCompanion Function({
      Value<String> id,
      Value<String> dashboardId,
      Value<String> name,
      Value<PanelType> type,
      Value<String> topic,
      Value<String?> subscribeTopic,
      Value<String?> topicPrefixOverride,
      Value<int> qos,
      Value<bool> retain,
      Value<PanelWidth> width,
      Value<int> sortOrder,
      Value<String> config,
      Value<int> mergeFlags,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> sectionId,
      Value<String?> deviceIeee,
      Value<int> rowid,
    });

final class $$PanelsTableReferences
    extends BaseReferences<_$AppDatabase, $PanelsTable, Panel> {
  $$PanelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DashboardsTable _dashboardIdTable(_$AppDatabase db) =>
      db.dashboards.createAlias(
        $_aliasNameGenerator(db.panels.dashboardId, db.dashboards.id),
      );

  $$DashboardsTableProcessedTableManager get dashboardId {
    final $_column = $_itemColumn<String>('dashboard_id')!;

    final manager = $$DashboardsTableTableManager(
      $_db,
      $_db.dashboards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dashboardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SectionsTable _sectionIdTable(_$AppDatabase db) => db.sections
      .createAlias($_aliasNameGenerator(db.panels.sectionId, db.sections.id));

  $$SectionsTableProcessedTableManager? get sectionId {
    final $_column = $_itemColumn<String>('section_id');
    if ($_column == null) return null;
    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PanelsTableFilterComposer
    extends Composer<_$AppDatabase, $PanelsTable> {
  $$PanelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PanelType, PanelType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subscribeTopic => $composableBuilder(
    column: $table.subscribeTopic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicPrefixOverride => $composableBuilder(
    column: $table.topicPrefixOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qos => $composableBuilder(
    column: $table.qos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get retain => $composableBuilder(
    column: $table.retain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PanelWidth, PanelWidth, String> get width =>
      $composableBuilder(
        column: $table.width,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mergeFlags => $composableBuilder(
    column: $table.mergeFlags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceIeee => $composableBuilder(
    column: $table.deviceIeee,
    builder: (column) => ColumnFilters(column),
  );

  $$DashboardsTableFilterComposer get dashboardId {
    final $$DashboardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dashboardId,
      referencedTable: $db.dashboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DashboardsTableFilterComposer(
            $db: $db,
            $table: $db.dashboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableFilterComposer get sectionId {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PanelsTableOrderingComposer
    extends Composer<_$AppDatabase, $PanelsTable> {
  $$PanelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscribeTopic => $composableBuilder(
    column: $table.subscribeTopic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicPrefixOverride => $composableBuilder(
    column: $table.topicPrefixOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qos => $composableBuilder(
    column: $table.qos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get retain => $composableBuilder(
    column: $table.retain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mergeFlags => $composableBuilder(
    column: $table.mergeFlags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceIeee => $composableBuilder(
    column: $table.deviceIeee,
    builder: (column) => ColumnOrderings(column),
  );

  $$DashboardsTableOrderingComposer get dashboardId {
    final $$DashboardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dashboardId,
      referencedTable: $db.dashboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DashboardsTableOrderingComposer(
            $db: $db,
            $table: $db.dashboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableOrderingComposer get sectionId {
    final $$SectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableOrderingComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PanelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PanelsTable> {
  $$PanelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PanelType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get subscribeTopic => $composableBuilder(
    column: $table.subscribeTopic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topicPrefixOverride => $composableBuilder(
    column: $table.topicPrefixOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qos =>
      $composableBuilder(column: $table.qos, builder: (column) => column);

  GeneratedColumn<bool> get retain =>
      $composableBuilder(column: $table.retain, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PanelWidth, String> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => column);

  GeneratedColumn<int> get mergeFlags => $composableBuilder(
    column: $table.mergeFlags,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceIeee => $composableBuilder(
    column: $table.deviceIeee,
    builder: (column) => column,
  );

  $$DashboardsTableAnnotationComposer get dashboardId {
    final $$DashboardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dashboardId,
      referencedTable: $db.dashboards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DashboardsTableAnnotationComposer(
            $db: $db,
            $table: $db.dashboards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableAnnotationComposer get sectionId {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PanelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PanelsTable,
          Panel,
          $$PanelsTableFilterComposer,
          $$PanelsTableOrderingComposer,
          $$PanelsTableAnnotationComposer,
          $$PanelsTableCreateCompanionBuilder,
          $$PanelsTableUpdateCompanionBuilder,
          (Panel, $$PanelsTableReferences),
          Panel,
          PrefetchHooks Function({bool dashboardId, bool sectionId})
        > {
  $$PanelsTableTableManager(_$AppDatabase db, $PanelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PanelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PanelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PanelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dashboardId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<PanelType> type = const Value.absent(),
                Value<String> topic = const Value.absent(),
                Value<String?> subscribeTopic = const Value.absent(),
                Value<String?> topicPrefixOverride = const Value.absent(),
                Value<int> qos = const Value.absent(),
                Value<bool> retain = const Value.absent(),
                Value<PanelWidth> width = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> config = const Value.absent(),
                Value<int> mergeFlags = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> sectionId = const Value.absent(),
                Value<String?> deviceIeee = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PanelsCompanion(
                id: id,
                dashboardId: dashboardId,
                name: name,
                type: type,
                topic: topic,
                subscribeTopic: subscribeTopic,
                topicPrefixOverride: topicPrefixOverride,
                qos: qos,
                retain: retain,
                width: width,
                sortOrder: sortOrder,
                config: config,
                mergeFlags: mergeFlags,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sectionId: sectionId,
                deviceIeee: deviceIeee,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dashboardId,
                required String name,
                required PanelType type,
                required String topic,
                Value<String?> subscribeTopic = const Value.absent(),
                Value<String?> topicPrefixOverride = const Value.absent(),
                Value<int> qos = const Value.absent(),
                Value<bool> retain = const Value.absent(),
                required PanelWidth width,
                Value<int> sortOrder = const Value.absent(),
                required String config,
                Value<int> mergeFlags = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> sectionId = const Value.absent(),
                Value<String?> deviceIeee = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PanelsCompanion.insert(
                id: id,
                dashboardId: dashboardId,
                name: name,
                type: type,
                topic: topic,
                subscribeTopic: subscribeTopic,
                topicPrefixOverride: topicPrefixOverride,
                qos: qos,
                retain: retain,
                width: width,
                sortOrder: sortOrder,
                config: config,
                mergeFlags: mergeFlags,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sectionId: sectionId,
                deviceIeee: deviceIeee,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PanelsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({dashboardId = false, sectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dashboardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dashboardId,
                                referencedTable: $$PanelsTableReferences
                                    ._dashboardIdTable(db),
                                referencedColumn: $$PanelsTableReferences
                                    ._dashboardIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (sectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sectionId,
                                referencedTable: $$PanelsTableReferences
                                    ._sectionIdTable(db),
                                referencedColumn: $$PanelsTableReferences
                                    ._sectionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PanelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PanelsTable,
      Panel,
      $$PanelsTableFilterComposer,
      $$PanelsTableOrderingComposer,
      $$PanelsTableAnnotationComposer,
      $$PanelsTableCreateCompanionBuilder,
      $$PanelsTableUpdateCompanionBuilder,
      (Panel, $$PanelsTableReferences),
      Panel,
      PrefetchHooks Function({bool dashboardId, bool sectionId})
    >;
typedef $$ScenesTableCreateCompanionBuilder =
    ScenesCompanion Function({
      required String id,
      required String connectionId,
      required String name,
      required int iconCodepoint,
      required int colorSeed,
      required String actions,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ScenesTableUpdateCompanionBuilder =
    ScenesCompanion Function({
      Value<String> id,
      Value<String> connectionId,
      Value<String> name,
      Value<int> iconCodepoint,
      Value<int> colorSeed,
      Value<String> actions,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ScenesTableReferences
    extends BaseReferences<_$AppDatabase, $ScenesTable, Scene> {
  $$ScenesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConnectionsTable _connectionIdTable(_$AppDatabase db) =>
      db.connections.createAlias(
        $_aliasNameGenerator(db.scenes.connectionId, db.connections.id),
      );

  $$ConnectionsTableProcessedTableManager get connectionId {
    final $_column = $_itemColumn<String>('connection_id')!;

    final manager = $$ConnectionsTableTableManager(
      $_db,
      $_db.connections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_connectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScenesTableFilterComposer
    extends Composer<_$AppDatabase, $ScenesTable> {
  $$ScenesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodepoint => $composableBuilder(
    column: $table.iconCodepoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorSeed => $composableBuilder(
    column: $table.colorSeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actions => $composableBuilder(
    column: $table.actions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConnectionsTableFilterComposer get connectionId {
    final $$ConnectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableFilterComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScenesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScenesTable> {
  $$ScenesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodepoint => $composableBuilder(
    column: $table.iconCodepoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorSeed => $composableBuilder(
    column: $table.colorSeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actions => $composableBuilder(
    column: $table.actions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConnectionsTableOrderingComposer get connectionId {
    final $$ConnectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableOrderingComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScenesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScenesTable> {
  $$ScenesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get iconCodepoint => $composableBuilder(
    column: $table.iconCodepoint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorSeed =>
      $composableBuilder(column: $table.colorSeed, builder: (column) => column);

  GeneratedColumn<String> get actions =>
      $composableBuilder(column: $table.actions, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ConnectionsTableAnnotationComposer get connectionId {
    final $$ConnectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScenesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScenesTable,
          Scene,
          $$ScenesTableFilterComposer,
          $$ScenesTableOrderingComposer,
          $$ScenesTableAnnotationComposer,
          $$ScenesTableCreateCompanionBuilder,
          $$ScenesTableUpdateCompanionBuilder,
          (Scene, $$ScenesTableReferences),
          Scene,
          PrefetchHooks Function({bool connectionId})
        > {
  $$ScenesTableTableManager(_$AppDatabase db, $ScenesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScenesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScenesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScenesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> connectionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> iconCodepoint = const Value.absent(),
                Value<int> colorSeed = const Value.absent(),
                Value<String> actions = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScenesCompanion(
                id: id,
                connectionId: connectionId,
                name: name,
                iconCodepoint: iconCodepoint,
                colorSeed: colorSeed,
                actions: actions,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String connectionId,
                required String name,
                required int iconCodepoint,
                required int colorSeed,
                required String actions,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ScenesCompanion.insert(
                id: id,
                connectionId: connectionId,
                name: name,
                iconCodepoint: iconCodepoint,
                colorSeed: colorSeed,
                actions: actions,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ScenesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({connectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (connectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.connectionId,
                                referencedTable: $$ScenesTableReferences
                                    ._connectionIdTable(db),
                                referencedColumn: $$ScenesTableReferences
                                    ._connectionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScenesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScenesTable,
      Scene,
      $$ScenesTableFilterComposer,
      $$ScenesTableOrderingComposer,
      $$ScenesTableAnnotationComposer,
      $$ScenesTableCreateCompanionBuilder,
      $$ScenesTableUpdateCompanionBuilder,
      (Scene, $$ScenesTableReferences),
      Scene,
      PrefetchHooks Function({bool connectionId})
    >;
typedef $$DeviceDismissalsTableCreateCompanionBuilder =
    DeviceDismissalsCompanion Function({
      required String connectionId,
      required String ieee,
      required DateTime dismissedAt,
      Value<int> rowid,
    });
typedef $$DeviceDismissalsTableUpdateCompanionBuilder =
    DeviceDismissalsCompanion Function({
      Value<String> connectionId,
      Value<String> ieee,
      Value<DateTime> dismissedAt,
      Value<int> rowid,
    });

final class $$DeviceDismissalsTableReferences
    extends
        BaseReferences<_$AppDatabase, $DeviceDismissalsTable, DeviceDismissal> {
  $$DeviceDismissalsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ConnectionsTable _connectionIdTable(_$AppDatabase db) =>
      db.connections.createAlias(
        $_aliasNameGenerator(
          db.deviceDismissals.connectionId,
          db.connections.id,
        ),
      );

  $$ConnectionsTableProcessedTableManager get connectionId {
    final $_column = $_itemColumn<String>('connection_id')!;

    final manager = $$ConnectionsTableTableManager(
      $_db,
      $_db.connections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_connectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DeviceDismissalsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceDismissalsTable> {
  $$DeviceDismissalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ieee => $composableBuilder(
    column: $table.ieee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dismissedAt => $composableBuilder(
    column: $table.dismissedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConnectionsTableFilterComposer get connectionId {
    final $$ConnectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableFilterComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceDismissalsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceDismissalsTable> {
  $$DeviceDismissalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ieee => $composableBuilder(
    column: $table.ieee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dismissedAt => $composableBuilder(
    column: $table.dismissedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConnectionsTableOrderingComposer get connectionId {
    final $$ConnectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableOrderingComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceDismissalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceDismissalsTable> {
  $$DeviceDismissalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ieee =>
      $composableBuilder(column: $table.ieee, builder: (column) => column);

  GeneratedColumn<DateTime> get dismissedAt => $composableBuilder(
    column: $table.dismissedAt,
    builder: (column) => column,
  );

  $$ConnectionsTableAnnotationComposer get connectionId {
    final $$ConnectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceDismissalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceDismissalsTable,
          DeviceDismissal,
          $$DeviceDismissalsTableFilterComposer,
          $$DeviceDismissalsTableOrderingComposer,
          $$DeviceDismissalsTableAnnotationComposer,
          $$DeviceDismissalsTableCreateCompanionBuilder,
          $$DeviceDismissalsTableUpdateCompanionBuilder,
          (DeviceDismissal, $$DeviceDismissalsTableReferences),
          DeviceDismissal,
          PrefetchHooks Function({bool connectionId})
        > {
  $$DeviceDismissalsTableTableManager(
    _$AppDatabase db,
    $DeviceDismissalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceDismissalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceDismissalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceDismissalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> connectionId = const Value.absent(),
                Value<String> ieee = const Value.absent(),
                Value<DateTime> dismissedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceDismissalsCompanion(
                connectionId: connectionId,
                ieee: ieee,
                dismissedAt: dismissedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String connectionId,
                required String ieee,
                required DateTime dismissedAt,
                Value<int> rowid = const Value.absent(),
              }) => DeviceDismissalsCompanion.insert(
                connectionId: connectionId,
                ieee: ieee,
                dismissedAt: dismissedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeviceDismissalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({connectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (connectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.connectionId,
                                referencedTable:
                                    $$DeviceDismissalsTableReferences
                                        ._connectionIdTable(db),
                                referencedColumn:
                                    $$DeviceDismissalsTableReferences
                                        ._connectionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DeviceDismissalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceDismissalsTable,
      DeviceDismissal,
      $$DeviceDismissalsTableFilterComposer,
      $$DeviceDismissalsTableOrderingComposer,
      $$DeviceDismissalsTableAnnotationComposer,
      $$DeviceDismissalsTableCreateCompanionBuilder,
      $$DeviceDismissalsTableUpdateCompanionBuilder,
      (DeviceDismissal, $$DeviceDismissalsTableReferences),
      DeviceDismissal,
      PrefetchHooks Function({bool connectionId})
    >;
typedef $$DeviceHealthFlagsTableCreateCompanionBuilder =
    DeviceHealthFlagsCompanion Function({
      required String connectionId,
      required String ieee,
      required bool batteryLow,
      required bool acknowledged,
      required DateTime changedAt,
      Value<int> rowid,
    });
typedef $$DeviceHealthFlagsTableUpdateCompanionBuilder =
    DeviceHealthFlagsCompanion Function({
      Value<String> connectionId,
      Value<String> ieee,
      Value<bool> batteryLow,
      Value<bool> acknowledged,
      Value<DateTime> changedAt,
      Value<int> rowid,
    });

final class $$DeviceHealthFlagsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DeviceHealthFlagsTable,
          DeviceHealthFlag
        > {
  $$DeviceHealthFlagsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ConnectionsTable _connectionIdTable(_$AppDatabase db) =>
      db.connections.createAlias(
        $_aliasNameGenerator(
          db.deviceHealthFlags.connectionId,
          db.connections.id,
        ),
      );

  $$ConnectionsTableProcessedTableManager get connectionId {
    final $_column = $_itemColumn<String>('connection_id')!;

    final manager = $$ConnectionsTableTableManager(
      $_db,
      $_db.connections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_connectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DeviceHealthFlagsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceHealthFlagsTable> {
  $$DeviceHealthFlagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ieee => $composableBuilder(
    column: $table.ieee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get batteryLow => $composableBuilder(
    column: $table.batteryLow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConnectionsTableFilterComposer get connectionId {
    final $$ConnectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableFilterComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceHealthFlagsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceHealthFlagsTable> {
  $$DeviceHealthFlagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ieee => $composableBuilder(
    column: $table.ieee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get batteryLow => $composableBuilder(
    column: $table.batteryLow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConnectionsTableOrderingComposer get connectionId {
    final $$ConnectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableOrderingComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceHealthFlagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceHealthFlagsTable> {
  $$DeviceHealthFlagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ieee =>
      $composableBuilder(column: $table.ieee, builder: (column) => column);

  GeneratedColumn<bool> get batteryLow => $composableBuilder(
    column: $table.batteryLow,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  $$ConnectionsTableAnnotationComposer get connectionId {
    final $$ConnectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceHealthFlagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceHealthFlagsTable,
          DeviceHealthFlag,
          $$DeviceHealthFlagsTableFilterComposer,
          $$DeviceHealthFlagsTableOrderingComposer,
          $$DeviceHealthFlagsTableAnnotationComposer,
          $$DeviceHealthFlagsTableCreateCompanionBuilder,
          $$DeviceHealthFlagsTableUpdateCompanionBuilder,
          (DeviceHealthFlag, $$DeviceHealthFlagsTableReferences),
          DeviceHealthFlag,
          PrefetchHooks Function({bool connectionId})
        > {
  $$DeviceHealthFlagsTableTableManager(
    _$AppDatabase db,
    $DeviceHealthFlagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceHealthFlagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceHealthFlagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceHealthFlagsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> connectionId = const Value.absent(),
                Value<String> ieee = const Value.absent(),
                Value<bool> batteryLow = const Value.absent(),
                Value<bool> acknowledged = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceHealthFlagsCompanion(
                connectionId: connectionId,
                ieee: ieee,
                batteryLow: batteryLow,
                acknowledged: acknowledged,
                changedAt: changedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String connectionId,
                required String ieee,
                required bool batteryLow,
                required bool acknowledged,
                required DateTime changedAt,
                Value<int> rowid = const Value.absent(),
              }) => DeviceHealthFlagsCompanion.insert(
                connectionId: connectionId,
                ieee: ieee,
                batteryLow: batteryLow,
                acknowledged: acknowledged,
                changedAt: changedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeviceHealthFlagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({connectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (connectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.connectionId,
                                referencedTable:
                                    $$DeviceHealthFlagsTableReferences
                                        ._connectionIdTable(db),
                                referencedColumn:
                                    $$DeviceHealthFlagsTableReferences
                                        ._connectionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DeviceHealthFlagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceHealthFlagsTable,
      DeviceHealthFlag,
      $$DeviceHealthFlagsTableFilterComposer,
      $$DeviceHealthFlagsTableOrderingComposer,
      $$DeviceHealthFlagsTableAnnotationComposer,
      $$DeviceHealthFlagsTableCreateCompanionBuilder,
      $$DeviceHealthFlagsTableUpdateCompanionBuilder,
      (DeviceHealthFlag, $$DeviceHealthFlagsTableReferences),
      DeviceHealthFlag,
      PrefetchHooks Function({bool connectionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConnectionsTableTableManager get connections =>
      $$ConnectionsTableTableManager(_db, _db.connections);
  $$DashboardsTableTableManager get dashboards =>
      $$DashboardsTableTableManager(_db, _db.dashboards);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db, _db.sections);
  $$PanelsTableTableManager get panels =>
      $$PanelsTableTableManager(_db, _db.panels);
  $$ScenesTableTableManager get scenes =>
      $$ScenesTableTableManager(_db, _db.scenes);
  $$DeviceDismissalsTableTableManager get deviceDismissals =>
      $$DeviceDismissalsTableTableManager(_db, _db.deviceDismissals);
  $$DeviceHealthFlagsTableTableManager get deviceHealthFlags =>
      $$DeviceHealthFlagsTableTableManager(_db, _db.deviceHealthFlags);
}
