import 'package:flutter/material.dart';

import 'package:flutter_proj/widget/daily_calendar_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_proj/providers/settings_provider.dart';
import 'package:flutter_proj/db/app_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_proj/db/db_initializer.dart';
import 'package:flutter_proj/core/platform.dart';

// Drift DB 검증 로직
Future<void> validateDriftDb({int previewLength = 20}) async {
  try {
    final db = AppDatabase();
    final total = await db.totalEventCount;
    print('📊 Drift validation: total events = $total');
    // 전체 이벤트 출력 
    final rows = await (db.select(db.historyEvents)).get();
    String truncate(String v) => v.isEmpty
        ? ''
        : (v.length <= previewLength ? v : v.substring(0, previewLength));
    for (final r in rows) {
      print('- ${r.id} | ${r.title} | ${r.year} | simple:"${truncate(r.simple)}"');
    }
    await db.close();
    print('✅ Drift validation completed.');
  } catch (e, stack) {
    print('❌ Drift validation error: $e');
    print(stack);
  }
}

// 시작 시 검증 실행 여부 토글
const bool kRunDriftValidationOnStartup = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initAppPlatform();
  // 사전 생성된 DB를 첫 실행에만 복사
  await copyPrebuiltDbIfNeeded(
    assetDbPath: 'assets/data/history_events.sqlite',
    targetFileName: 'history_events.sqlite',
  );
  // 시작 시 검증을 원할 때만 토글
  if (kRunDriftValidationOnStartup) {
    await validateDriftDb(previewLength: 20);
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

