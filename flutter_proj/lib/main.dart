import 'package:flutter/material.dart';
import 'package:flutter_proj/widget/daily_calendar_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/rendering.dart';

void main() async {
  debugPaintSizeEnabled = true;  // 레이아웃 디버깅 활성화
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
  await initializeDateFormatting('ko_KR', null); // 혹은 'en_US' 등 원하는 로케일
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DailyCalendarWidget(),
    );
  }
}

