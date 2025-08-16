import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('DbHistoryEvent')
class HistoryEvents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get year => text()();
  TextColumn get simple => text()();
  TextColumn get detail => text()();
  TextColumn get youtubeUrl => text().named('youtube_url')();

  @override
  Set<Column> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dbPath = p.join(dir.path, 'history_events.sqlite');
    final File file = File(dbPath);
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [HistoryEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forFile(File dbFile) : super(NativeDatabase(dbFile));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );

  Future<DbHistoryEvent?> getEventById(String id) async {
    return (select(historyEvents)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> get totalEventCount async {
    final countExp = historyEvents.id.count();
    final TypedResult row = await (selectOnly(historyEvents)..addColumns([countExp])).getSingle();
    return row.read<int>(countExp) ?? 0;
  }
}


