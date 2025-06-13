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


Future<void> copyRealmFromAssets() async {
  // 앱 문서 디렉토리 가져오기
  final appDocDir = await getApplicationDocumentsDirectory();
  final realmPath = '${appDocDir.path}/default.realm';
  
  // 이미 복사된 파일이 있는지 확인
  final realmFile = File(realmPath);
  
  // 버전 관리를 위한 옵션 (필요시 사용)
  // final prefs = await SharedPreferences.getInstance();
  // final currentVersion = prefs.getInt('db_version') ?? 0;
  // const newVersion = 1; // 앱 업데이트마다 증가
  
  if (!realmFile.existsSync()) { // || currentVersion < newVersion) {
    // assets에서 파일 읽기
    final data = await rootBundle.load('assets/default.realm');
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    
    // 기존 파일이 있다면 삭제
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

Future<void> showCar() async {
  try {
    // assets에서 Realm DB 복사
    await copyRealmFromAssets();
    
    // 앱 문서 디렉토리 경로 가져오기
    final appDocDir = await getApplicationDocumentsDirectory();
    final realmPath = '${appDocDir.path}/default.realm';
    
    // Realm 설정 및 열기
    var config = Configuration.local(
      [Car.schema],
      path: realmPath,
      isReadOnly: false,
    );
    var realm = Realm(config);
    
    // 데이터 읽기
    var cars = realm.all<Car>();
    
    if (cars.isNotEmpty) {
      Car myCar = cars[0];
      print("My car is ${myCar.make} model ${myCar.model}");
      
      // Tesla 차량 검색
      var teslaCars = realm.all<Car>().query("make == 'Tesla'");
      print("Found ${teslaCars.length} Tesla cars");
      
      for (var car in teslaCars) {
        print("- ${car.make} ${car.model}, ${car.kilometers} km");
      }
    } else {
      print("No cars found in database");
    }
    
    // Realm 닫기 (선택사항)
    realm.close();
  } catch (e) {
    print("Error reading Realm DB: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    // Realm DB 읽기 테스트
  await showCar();
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

