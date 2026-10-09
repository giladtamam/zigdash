// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_known_db.dart';

// ignore_for_file: type=lint
class $LastKnownValuesTable extends LastKnownValues
    with TableInfo<$LastKnownValuesTable, LastKnownValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LastKnownValuesTable(this.attachedDatabase, [this._alias]);
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
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    connectionId,
    topic,
    payload,
    receivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'last_known_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<LastKnownValue> instance, {
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
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {connectionId, topic};
  @override
  LastKnownValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LastKnownValue(
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
    );
  }

  @override
  $LastKnownValuesTable createAlias(String alias) {
    return $LastKnownValuesTable(attachedDatabase, alias);
  }
}

class LastKnownValue extends DataClass implements Insertable<LastKnownValue> {
  final String connectionId;
  final String topic;
  final String payload;
  final DateTime receivedAt;
  const LastKnownValue({
    required this.connectionId,
    required this.topic,
    required this.payload,
    required this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['connection_id'] = Variable<String>(connectionId);
    map['topic'] = Variable<String>(topic);
    map['payload'] = Variable<String>(payload);
    map['received_at'] = Variable<DateTime>(receivedAt);
    return map;
  }

  LastKnownValuesCompanion toCompanion(bool nullToAbsent) {
    return LastKnownValuesCompanion(
      connectionId: Value(connectionId),
      topic: Value(topic),
      payload: Value(payload),
      receivedAt: Value(receivedAt),
    );
  }

  factory LastKnownValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LastKnownValue(
      connectionId: serializer.fromJson<String>(json['connectionId']),
      topic: serializer.fromJson<String>(json['topic']),
      payload: serializer.fromJson<String>(json['payload']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'connectionId': serializer.toJson<String>(connectionId),
      'topic': serializer.toJson<String>(topic),
      'payload': serializer.toJson<String>(payload),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
    };
  }

  LastKnownValue copyWith({
    String? connectionId,
    String? topic,
    String? payload,
    DateTime? receivedAt,
  }) => LastKnownValue(
    connectionId: connectionId ?? this.connectionId,
    topic: topic ?? this.topic,
    payload: payload ?? this.payload,
    receivedAt: receivedAt ?? this.receivedAt,
  );
  LastKnownValue copyWithCompanion(LastKnownValuesCompanion data) {
    return LastKnownValue(
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      topic: data.topic.present ? data.topic.value : this.topic,
      payload: data.payload.present ? data.payload.value : this.payload,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LastKnownValue(')
          ..write('connectionId: $connectionId, ')
          ..write('topic: $topic, ')
          ..write('payload: $payload, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(connectionId, topic, payload, receivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LastKnownValue &&
          other.connectionId == this.connectionId &&
          other.topic == this.topic &&
          other.payload == this.payload &&
          other.receivedAt == this.receivedAt);
}

class LastKnownValuesCompanion extends UpdateCompanion<LastKnownValue> {
  final Value<String> connectionId;
  final Value<String> topic;
  final Value<String> payload;
  final Value<DateTime> receivedAt;
  final Value<int> rowid;
  const LastKnownValuesCompanion({
    this.connectionId = const Value.absent(),
    this.topic = const Value.absent(),
    this.payload = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LastKnownValuesCompanion.insert({
    required String connectionId,
    required String topic,
    required String payload,
    required DateTime receivedAt,
    this.rowid = const Value.absent(),
  }) : connectionId = Value(connectionId),
       topic = Value(topic),
       payload = Value(payload),
       receivedAt = Value(receivedAt);
  static Insertable<LastKnownValue> custom({
    Expression<String>? connectionId,
    Expression<String>? topic,
    Expression<String>? payload,
    Expression<DateTime>? receivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (connectionId != null) 'connection_id': connectionId,
      if (topic != null) 'topic': topic,
      if (payload != null) 'payload': payload,
      if (receivedAt != null) 'received_at': receivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LastKnownValuesCompanion copyWith({
    Value<String>? connectionId,
    Value<String>? topic,
    Value<String>? payload,
    Value<DateTime>? receivedAt,
    Value<int>? rowid,
  }) {
    return LastKnownValuesCompanion(
      connectionId: connectionId ?? this.connectionId,
      topic: topic ?? this.topic,
      payload: payload ?? this.payload,
      receivedAt: receivedAt ?? this.receivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (connectionId.present) {
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LastKnownValuesCompanion(')
          ..write('connectionId: $connectionId, ')
          ..write('topic: $topic, ')
          ..write('payload: $payload, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LastKnownDb extends GeneratedDatabase {
  _$LastKnownDb(QueryExecutor e) : super(e);
  $LastKnownDbManager get managers => $LastKnownDbManager(this);
  late final $LastKnownValuesTable lastKnownValues = $LastKnownValuesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [lastKnownValues];
}

typedef $$LastKnownValuesTableCreateCompanionBuilder =
    LastKnownValuesCompanion Function({
      required String connectionId,
      required String topic,
      required String payload,
      required DateTime receivedAt,
      Value<int> rowid,
    });
typedef $$LastKnownValuesTableUpdateCompanionBuilder =
    LastKnownValuesCompanion Function({
      Value<String> connectionId,
      Value<String> topic,
      Value<String> payload,
      Value<DateTime> receivedAt,
      Value<int> rowid,
    });

class $$LastKnownValuesTableFilterComposer
    extends Composer<_$LastKnownDb, $LastKnownValuesTable> {
  $$LastKnownValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LastKnownValuesTableOrderingComposer
    extends Composer<_$LastKnownDb, $LastKnownValuesTable> {
  $$LastKnownValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LastKnownValuesTableAnnotationComposer
    extends Composer<_$LastKnownDb, $LastKnownValuesTable> {
  $$LastKnownValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );
}

class $$LastKnownValuesTableTableManager
    extends
        RootTableManager<
          _$LastKnownDb,
          $LastKnownValuesTable,
          LastKnownValue,
          $$LastKnownValuesTableFilterComposer,
          $$LastKnownValuesTableOrderingComposer,
          $$LastKnownValuesTableAnnotationComposer,
          $$LastKnownValuesTableCreateCompanionBuilder,
          $$LastKnownValuesTableUpdateCompanionBuilder,
          (
            LastKnownValue,
            BaseReferences<
              _$LastKnownDb,
              $LastKnownValuesTable,
              LastKnownValue
            >,
          ),
          LastKnownValue,
          PrefetchHooks Function()
        > {
  $$LastKnownValuesTableTableManager(
    _$LastKnownDb db,
    $LastKnownValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LastKnownValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LastKnownValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LastKnownValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> connectionId = const Value.absent(),
                Value<String> topic = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LastKnownValuesCompanion(
                connectionId: connectionId,
                topic: topic,
                payload: payload,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String connectionId,
                required String topic,
                required String payload,
                required DateTime receivedAt,
                Value<int> rowid = const Value.absent(),
              }) => LastKnownValuesCompanion.insert(
                connectionId: connectionId,
                topic: topic,
                payload: payload,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LastKnownValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$LastKnownDb,
      $LastKnownValuesTable,
      LastKnownValue,
      $$LastKnownValuesTableFilterComposer,
      $$LastKnownValuesTableOrderingComposer,
      $$LastKnownValuesTableAnnotationComposer,
      $$LastKnownValuesTableCreateCompanionBuilder,
      $$LastKnownValuesTableUpdateCompanionBuilder,
      (
        LastKnownValue,
        BaseReferences<_$LastKnownDb, $LastKnownValuesTable, LastKnownValue>,
      ),
      LastKnownValue,
      PrefetchHooks Function()
    >;

class $LastKnownDbManager {
  final _$LastKnownDb _db;
  $LastKnownDbManager(this._db);
  $$LastKnownValuesTableTableManager get lastKnownValues =>
      $$LastKnownValuesTableTableManager(_db, _db.lastKnownValues);
}
