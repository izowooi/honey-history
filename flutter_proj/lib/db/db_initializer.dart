import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 사전 생성된 SQLite DB를 첫 실행에만 문서 디렉토리로 복사합니다.
/// - [assetDbPath]: 앱 번들 내 사전 생성 DB 경로 (예: assets/data/history_events.sqlite)
/// - [targetFileName]: 문서 디렉토리에 저장할 파일명 (예: history_events.sqlite)
/// - [forceOverwrite]: true면 항상 덮어쓰기
Future<File> copyPrebuiltDbIfNeeded({
  String assetDbPath = 'assets/data/history_events.sqlite',
  String targetFileName = 'history_events.sqlite',
  bool forceOverwrite = false,
}) async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String dbPath = p.join(appDocDir.path, targetFileName);
  final File outFile = File(dbPath);

  if (!forceOverwrite && await outFile.exists()) {
    print('Drift DB already exists: $dbPath');
    return outFile;
  }

  final byteData = await rootBundle.load(assetDbPath);
  await outFile.writeAsBytes(
    byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    flush: true,
  );
  print('Drift DB copied: $dbPath');
  return outFile;
}


