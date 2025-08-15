import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_proj/widget/daily_calendar_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_proj/widget/empty_widget.dart';
import 'package:flutter_proj/providers/settings_provider.dart';
import 'package:realm/realm.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'car.dart';
import 'history_event.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> copyRealmFromAssets({bool forceOverwrite = false}) async {
  // 앱 문서 디렉토리 가져오기
  final appDocDir = await getApplicationDocumentsDirectory();
  final realmPath = '${appDocDir.path}/history_events.realm';
  
  // 이미 복사된 파일이 있는지 확인
  final realmFile = File(realmPath);
  
  // 버전 관리를 위한 옵션 (필요시 사용)
  // final prefs = await SharedPreferences.getInstance();
  // final currentVersion = prefs.getInt('db_version') ?? 0;
  // const newVersion = 1; // 앱 업데이트마다 증가
  
  if (forceOverwrite || !realmFile.existsSync()) { // || currentVersion < newVersion) {
    // assets에서 파일 읽기
    final data = await rootBundle.load('assets/history_events.realm');
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    
    // 기존 파일이 있고 강제 덮어쓰기면 삭제
    if (realmFile.existsSync()) {
      await realmFile.delete();
    }
    
    // 파일로 저장
    await realmFile.writeAsBytes(bytes);
    print('Realm DB copied from assets to: $realmPath');
    
    // 버전 저장
    // await prefs.setInt('db_version', newVersion);
  } else {
    print('Realm DB already exists at: $realmPath');
  }
}


// Realm DB 전체 검증 로직
Future<void> validateRealmDb({int previewLength = 20}) async {
  try {
    final appDocDir = await getApplicationDocumentsDirectory();
    final realmPath = '${appDocDir.path}/history_events.realm';
    final realm = Realm(
      Configuration.local(
        [HistoryEvent.schema],
        path: realmPath,
        isReadOnly: true,
      ),
    );

    final events = realm.all<HistoryEvent>();
    print('📊 Realm validation: total events = ${events.length}');

    String _truncate(String value) {
      if (value.isEmpty) return '';
      return value.length <= previewLength ? value : value.substring(0, previewLength);
    }

    for (final e in events) {
      final simple = _truncate(e.simple);
      final detail = _truncate(e.detail);
      final youtube = _truncate(e.youtube_url);
      print('- ${e.id} | ${e.title} | ${e.year} | simple:"$simple" | detail:"$detail" | youtube:"$youtube"');
    }

    realm.close();
    print('✅ Realm validation completed.');
  } catch (e, stack) {
    print('❌ Realm validation error: $e');
    print(stack);
  }
}

// 시작 시 검증 실행 여부 토글
const bool kRunRealmValidationOnStartup = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await copyRealmFromAssets();

  // 시작 시 검증을 원할 때만 토글
  if (kRunRealmValidationOnStartup) {
    await validateRealmDb(previewLength: 20);
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
  await initializeDateFormatting('ko_KR', null); // 혹은 'en_US' 등 원하는 로케일
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebug = ref.watch(isDebugProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: isDebug,  // 디버그 배너를 isDebug 상태에 따라 표시
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DailyCalendarWidget(),
    );
  }
}

