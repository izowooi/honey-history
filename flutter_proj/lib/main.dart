import 'package:flutter/material.dart';
import 'package:flutter_proj/widget/daily_calendar_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_proj/widget/empty_widget.dart';
import 'package:flutter_proj/providers/settings_provider.dart';

void main() async {
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

