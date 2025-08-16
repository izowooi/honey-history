// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HistoryEventsTable extends HistoryEvents
    with TableInfo<$HistoryEventsTable, DbHistoryEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<String> year = GeneratedColumn<String>(
      'year', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _simpleMeta = const VerificationMeta('simple');
  @override
  late final GeneratedColumn<String> simple = GeneratedColumn<String>(
      'simple', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _youtubeUrlMeta =
      const VerificationMeta('youtubeUrl');
  @override
  late final GeneratedColumn<String> youtubeUrl = GeneratedColumn<String>(
      'youtube_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, year, simple, detail, youtubeUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_events';
  @override
  VerificationContext validateIntegrity(Insertable<DbHistoryEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('simple')) {
      context.handle(_simpleMeta,
          simple.isAcceptableOrUnknown(data['simple']!, _simpleMeta));
    } else if (isInserting) {
      context.missing(_simpleMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    } else if (isInserting) {
      context.missing(_detailMeta);
    }
    if (data.containsKey('youtube_url')) {
      context.handle(
          _youtubeUrlMeta,
          youtubeUrl.isAcceptableOrUnknown(
              data['youtube_url']!, _youtubeUrlMeta));
    } else if (isInserting) {
      context.missing(_youtubeUrlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbHistoryEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbHistoryEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}year'])!,
      simple: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}simple'])!,
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail'])!,
      youtubeUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}youtube_url'])!,
    );
  }

  @override
  $HistoryEventsTable createAlias(String alias) {
    return $HistoryEventsTable(attachedDatabase, alias);
  }
}

class DbHistoryEvent extends DataClass implements Insertable<DbHistoryEvent> {
  final String id;
  final String title;
  final String year;
  final String simple;
  final String detail;
  final String youtubeUrl;
  const DbHistoryEvent(
      {required this.id,
      required this.title,
      required this.year,
      required this.simple,
      required this.detail,
      required this.youtubeUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['year'] = Variable<String>(year);
    map['simple'] = Variable<String>(simple);
    map['detail'] = Variable<String>(detail);
    map['youtube_url'] = Variable<String>(youtubeUrl);
    return map;
  }

  HistoryEventsCompanion toCompanion(bool nullToAbsent) {
    return HistoryEventsCompanion(
      id: Value(id),
      title: Value(title),
      year: Value(year),
      simple: Value(simple),
      detail: Value(detail),
      youtubeUrl: Value(youtubeUrl),
    );
  }

  factory DbHistoryEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbHistoryEvent(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      year: serializer.fromJson<String>(json['year']),
      simple: serializer.fromJson<String>(json['simple']),
      detail: serializer.fromJson<String>(json['detail']),
      youtubeUrl: serializer.fromJson<String>(json['youtubeUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'year': serializer.toJson<String>(year),
      'simple': serializer.toJson<String>(simple),
      'detail': serializer.toJson<String>(detail),
      'youtubeUrl': serializer.toJson<String>(youtubeUrl),
    };
  }

  DbHistoryEvent copyWith(
          {String? id,
          String? title,
          String? year,
          String? simple,
          String? detail,
          String? youtubeUrl}) =>
      DbHistoryEvent(
        id: id ?? this.id,
        title: title ?? this.title,
        year: year ?? this.year,
        simple: simple ?? this.simple,
        detail: detail ?? this.detail,
        youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      );
  DbHistoryEvent copyWithCompanion(HistoryEventsCompanion data) {
    return DbHistoryEvent(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      year: data.year.present ? data.year.value : this.year,
      simple: data.simple.present ? data.simple.value : this.simple,
      detail: data.detail.present ? data.detail.value : this.detail,
      youtubeUrl:
          data.youtubeUrl.present ? data.youtubeUrl.value : this.youtubeUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbHistoryEvent(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('year: $year, ')
          ..write('simple: $simple, ')
          ..write('detail: $detail, ')
          ..write('youtubeUrl: $youtubeUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, year, simple, detail, youtubeUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbHistoryEvent &&
          other.id == this.id &&
          other.title == this.title &&
          other.year == this.year &&
          other.simple == this.simple &&
          other.detail == this.detail &&
          other.youtubeUrl == this.youtubeUrl);
}

class HistoryEventsCompanion extends UpdateCompanion<DbHistoryEvent> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> year;
  final Value<String> simple;
  final Value<String> detail;
  final Value<String> youtubeUrl;
  final Value<int> rowid;
  const HistoryEventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.year = const Value.absent(),
    this.simple = const Value.absent(),
    this.detail = const Value.absent(),
    this.youtubeUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HistoryEventsCompanion.insert({
    required String id,
    required String title,
    required String year,
    required String simple,
    required String detail,
    required String youtubeUrl,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        year = Value(year),
        simple = Value(simple),
        detail = Value(detail),
        youtubeUrl = Value(youtubeUrl);
  static Insertable<DbHistoryEvent> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? year,
    Expression<String>? simple,
    Expression<String>? detail,
    Expression<String>? youtubeUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (year != null) 'year': year,
      if (simple != null) 'simple': simple,
      if (detail != null) 'detail': detail,
      if (youtubeUrl != null) 'youtube_url': youtubeUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HistoryEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? year,
      Value<String>? simple,
      Value<String>? detail,
      Value<String>? youtubeUrl,
      Value<int>? rowid}) {
    return HistoryEventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      year: year ?? this.year,
      simple: simple ?? this.simple,
      detail: detail ?? this.detail,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (year.present) {
      map['year'] = Variable<String>(year.value);
    }
    if (simple.present) {
      map['simple'] = Variable<String>(simple.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (youtubeUrl.present) {
      map['youtube_url'] = Variable<String>(youtubeUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('year: $year, ')
          ..write('simple: $simple, ')
          ..write('detail: $detail, ')
          ..write('youtubeUrl: $youtubeUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HistoryEventsTable historyEvents = $HistoryEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [historyEvents];
}

typedef $$HistoryEventsTableCreateCompanionBuilder = HistoryEventsCompanion
    Function({
  required String id,
  required String title,
  required String year,
  required String simple,
  required String detail,
  required String youtubeUrl,
  Value<int> rowid,
});
typedef $$HistoryEventsTableUpdateCompanionBuilder = HistoryEventsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> year,
  Value<String> simple,
  Value<String> detail,
  Value<String> youtubeUrl,
  Value<int> rowid,
});

class $$HistoryEventsTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryEventsTable> {
  $$HistoryEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get simple => $composableBuilder(
      column: $table.simple, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get youtubeUrl => $composableBuilder(
      column: $table.youtubeUrl, builder: (column) => ColumnFilters(column));
}

class $$HistoryEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryEventsTable> {
  $$HistoryEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get simple => $composableBuilder(
      column: $table.simple, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get youtubeUrl => $composableBuilder(
      column: $table.youtubeUrl, builder: (column) => ColumnOrderings(column));
}

class $$HistoryEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryEventsTable> {
  $$HistoryEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get simple =>
      $composableBuilder(column: $table.simple, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<String> get youtubeUrl => $composableBuilder(
      column: $table.youtubeUrl, builder: (column) => column);
}

class $$HistoryEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HistoryEventsTable,
    DbHistoryEvent,
    $$HistoryEventsTableFilterComposer,
    $$HistoryEventsTableOrderingComposer,
    $$HistoryEventsTableAnnotationComposer,
    $$HistoryEventsTableCreateCompanionBuilder,
    $$HistoryEventsTableUpdateCompanionBuilder,
    (
      DbHistoryEvent,
      BaseReferences<_$AppDatabase, $HistoryEventsTable, DbHistoryEvent>
    ),
    DbHistoryEvent,
    PrefetchHooks Function()> {
  $$HistoryEventsTableTableManager(_$AppDatabase db, $HistoryEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> year = const Value.absent(),
            Value<String> simple = const Value.absent(),
            Value<String> detail = const Value.absent(),
            Value<String> youtubeUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HistoryEventsCompanion(
            id: id,
            title: title,
            year: year,
            simple: simple,
            detail: detail,
            youtubeUrl: youtubeUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String year,
            required String simple,
            required String detail,
            required String youtubeUrl,
            Value<int> rowid = const Value.absent(),
          }) =>
              HistoryEventsCompanion.insert(
            id: id,
            title: title,
            year: year,
            simple: simple,
            detail: detail,
            youtubeUrl: youtubeUrl,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HistoryEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HistoryEventsTable,
    DbHistoryEvent,
    $$HistoryEventsTableFilterComposer,
    $$HistoryEventsTableOrderingComposer,
    $$HistoryEventsTableAnnotationComposer,
    $$HistoryEventsTableCreateCompanionBuilder,
    $$HistoryEventsTableUpdateCompanionBuilder,
    (
      DbHistoryEvent,
      BaseReferences<_$AppDatabase, $HistoryEventsTable, DbHistoryEvent>
    ),
    DbHistoryEvent,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HistoryEventsTableTableManager get historyEvents =>
      $$HistoryEventsTableTableManager(_db, _db.historyEvents);
}
