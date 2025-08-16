import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sq3;

/// JSON을 읽어 사전 생성 SQLite DB를 만듭니다.
/// - 입력: lib/historical_events.json (또는 첫 번째 인자)
/// - 출력: assets/data/history_events.sqlite (또는 두 번째 인자)
void main(List<String> args) async {
  final String inputJson = args.isNotEmpty ? args[0] : 'lib/historical_events.json';
  final String outputDb = args.length > 1 ? args[1] : 'assets/data/history_events.sqlite';

  final File jsonFile = File(inputJson);
  if (!jsonFile.existsSync()) {
    stderr.writeln('❌ JSON 파일을 찾을 수 없습니다: ${jsonFile.path}');
    exit(2);
  }

  final String jsonString = await jsonFile.readAsString();
  final Map<String, dynamic> data = json.decode(jsonString) as Map<String, dynamic>;

  // 출력 디렉토리 보장
  final String outDir = p.dirname(outputDb);
  await Directory(outDir).create(recursive: true);

  // 기존 파일 삭제 후 생성
  final File dbFile = File(outputDb);
  if (dbFile.existsSync()) {
    dbFile.deleteSync();
  }

  final sq3.Database db = sq3.sqlite3.open(outputDb);
  try {
    db.execute('PRAGMA journal_mode=WAL;');
    db.execute('PRAGMA foreign_keys=ON;');
    db.execute('''
      CREATE TABLE IF NOT EXISTS history_events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        year TEXT NOT NULL,
        simple TEXT NOT NULL,
        detail TEXT NOT NULL,
        youtube_url TEXT NOT NULL
      );
    ''');
    db.execute('DELETE FROM history_events;');

    final sq3.PreparedStatement insert = db.prepare(
      'INSERT INTO history_events (id, title, year, simple, detail, youtube_url) VALUES (?, ?, ?, ?, ?, ?);',
    );
    int inserted = 0;
    db.execute('BEGIN;');
    try {
      data.forEach((String key, dynamic value) {
        final Map<String, dynamic> row = value as Map<String, dynamic>;
        final String id = (row['id'] ?? key).toString();
        final String title = (row['title'] ?? '').toString();
        final String year = (row['year'] ?? '').toString();
        final String simple = (row['simple'] ?? '').toString();
        final String detail = (row['detail'] ?? '').toString();
        final String youtube = (row['youtube_url'] ?? '').toString();
        insert.execute(<Object?>[id, title, year, simple, detail, youtube]);
        inserted++;
      });
      db.execute('COMMIT;');
    } catch (e) {
      db.execute('ROLLBACK;');
      rethrow;
    } finally {
      insert.dispose();
    }

    stdout.writeln('✅ 생성 완료: $outputDb (rows: $inserted)');
  } finally {
    db.dispose();
  }
}


