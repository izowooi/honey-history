import 'package:realm/realm.dart';
import 'car.dart';
import 'history_event.dart';
import 'dart:io';
import 'dart:convert';

// 데이터베이스 설정을 위한 상수들
class RealmConfig {
  // 데이터베이스 파일명 설정
  static const String historyDbPath = 'history_events.realm';
  static const String carDbPath = 'cars.realm';
  static const String combinedDbPath = 'honey_history.realm';  // 통합 DB
  
  // 스키마 설정
  static Configuration get historyConfig => Configuration.local(
    [HistoryEvent.schema], 
    path: historyDbPath
  );
  
  static Configuration get carConfig => Configuration.local(
    [Car.schema], 
    path: carDbPath
  );
  
  // 모든 스키마를 포함한 통합 설정
  static Configuration get combinedConfig => Configuration.local(
    [HistoryEvent.schema, Car.schema], 
    path: combinedDbPath
  );
}

createDefaultRealm() {
  print("🚗 Car 데이터베이스 생성: ${RealmConfig.carDbPath}");
  var realm = Realm(RealmConfig.carConfig);

  var car = Car("Tesla", "Model Y", kilometers: 5);
  realm.write(() {
    realm.add(car);
  });
  
  realm.close();
  print("✅ Car 데이터베이스 생성 완료");
}

testDefaultRealm() {
  print("🔍 Car 데이터베이스 테스트: ${RealmConfig.carDbPath}");
  var realm = Realm(RealmConfig.carConfig);
  var cars = realm.all<Car>();

  if (cars.isNotEmpty) {
    Car myCar = cars[0];
    print("My car is ${myCar.make} model ${myCar.model}");

    cars = realm.all<Car>().query("make == 'Tesla'");
    print("Tesla cars found: ${cars.length}");
  } else {
    print("No cars in database");
  }
  
  realm.close();
}

// JSON 데이터를 읽어서 HistoryEvent 객체들을 생성하는 함수
Future<List<HistoryEvent>> loadHistoryEventsFromJson() async {
  try {
    print("📖 JSON 파일 읽기 시작...");
    print("🔍 현재 작업 디렉토리: ${Directory.current.path}");
    
    // JSON 파일 경로 확인
    final file = File('lib/historical_events_3q.json');
    print("📄 파일 경로: ${file.absolute.path}");
    print("✅ 파일 존재 여부: ${await file.exists()}");
    
    if (!await file.exists()) {
      print("❌ 파일을 찾을 수 없습니다!");
      return [];
    }
    
    // JSON 파일 읽기
    final jsonString = await file.readAsString();
    print("📏 파일 크기: ${jsonString.length} 문자");
    
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    print("✅ JSON 파싱 완료. 총 ${jsonData.keys.length}개의 키 발견");
    print("🗝️ 첫 5개 키: ${jsonData.keys.take(5).toList()}");
    
    List<HistoryEvent> events = [];
    int processedCount = 0;
    
    // JSON 데이터를 HistoryEvent 객체로 변환
    jsonData.forEach((dateKey, eventData) {
      processedCount++;
      
      if (eventData is! Map<String, dynamic>) {
        print("⚠️ 잘못된 데이터 형식: $dateKey");
        return;
      }
      
      final event = HistoryEvent(
        eventData['id'] ?? dateKey,
        eventData['title'] ?? '제목 없음',
        eventData['year']?.toString() ?? '연도 미상',
        eventData['simple'] ?? '간단 설명 없음',
        eventData['detail'] ?? '상세 설명 없음',
        eventData['youtube_url'] ?? '',
      );
      
      events.add(event);
      
      // 처음 3개 이벤트만 상세 로그 출력
      if (events.length <= 3) {
        print("📅 이벤트 ${events.length}: ${event.id} - ${event.title} (${event.year})");
        print("   📝 간단: ${event.simple.length > 50 ? event.simple.substring(0, 50) + '...' : event.simple}");
        print("   🎬 유튜브: ${event.youtube_url.isEmpty ? '없음' : '있음'}");
        print("");
      }
      
      // 10개씩 처리할 때마다 진행 상황 출력
      if (processedCount % 10 == 0) {
        print("⏳ 진행률: $processedCount/${jsonData.keys.length} (${events.length}개 성공)");
      }
    });
    
    print("🎉 총 ${events.length}개의 HistoryEvent 객체 생성 완료");
    print("📊 처리된 항목: $processedCount개");
    return events;
    
  } catch (e, stackTrace) {
    print("❌ JSON 로딩 중 에러 발생: $e");
    print("📍 스택 트레이스: $stackTrace");
    return [];
  }
}

// HistoryEvent용 Realm 데이터베이스 생성
Future<void> createHistoryEventRealm() async {
  try {
    print("🏗️ HistoryEvent 데이터베이스 생성: ${RealmConfig.historyDbPath}");
    
    var realm = Realm(RealmConfig.historyConfig);
    
    // JSON에서 데이터 로드
    final events = await loadHistoryEventsFromJson();
    
    if (events.isEmpty) {
      print("❌ 저장할 이벤트가 없습니다.");
      return;
    }
    
    // Realm에 데이터 저장
    realm.write(() {
      realm.deleteAll<HistoryEvent>(); // 기존 데이터 삭제
      for (var event in events) {
        realm.add(event);
      }
    });
    
    print("💾 ${events.length}개의 이벤트를 ${RealmConfig.historyDbPath}에 저장 완료");
    realm.close();
    
  } catch (e) {
    print("❌ HistoryEvent Realm 생성 중 에러: $e");
  }
}

// HistoryEvent Realm 데이터베이스 테스트
Future<void> testHistoryEventRealm() async {
  try {
    print("🔍 HistoryEvent 데이터베이스 테스트: ${RealmConfig.historyDbPath}");
    
    var realm = Realm(RealmConfig.historyConfig);
    
    // 전체 이벤트 수 확인
    var allEvents = realm.all<HistoryEvent>();
    print("📊 전체 이벤트 수: ${allEvents.length}개");
    
    if (allEvents.isEmpty) {
      print("❌ 데이터베이스가 비어있습니다. createHistoryEventRealm()을 먼저 실행하세요.");
      realm.close();
      return;
    }
    
    // 첫 번째 이벤트 상세 정보
    final firstEvent = allEvents.first;
    print("\n🥇 첫 번째 이벤트:");
    print("   ID: ${firstEvent.id}");
    print("   제목: ${firstEvent.title}");
    print("   연도: ${firstEvent.year}");
    print("   간단 설명: ${firstEvent.simple.length > 100 ? firstEvent.simple.substring(0, 100) + '...' : firstEvent.simple}");
    
    // 특정 연도 검색 테스트
    var year1863Events = realm.all<HistoryEvent>().query("year == '1863'");
    print("\n🔍 1863년 이벤트 검색 결과: ${year1863Events.length}개");
    for (var event in year1863Events) {
      print("   - ${event.title}");
    }
    
    // 제목에 '전투' 포함된 이벤트 검색
    var battleEvents = realm.all<HistoryEvent>().query("title CONTAINS '전투'");
    print("\n⚔️ '전투'가 포함된 이벤트: ${battleEvents.length}개");
    for (var event in battleEvents) {
      print("   - ${event.title} (${event.year})");
    }
    
    // 유튜브 URL이 있는 이벤트 수
    var eventsWithYoutube = realm.all<HistoryEvent>().query("youtube_url != ''");
    print("\n🎬 유튜브 URL이 있는 이벤트: ${eventsWithYoutube.length}개");
    
    realm.close();
    print("\n✅ HistoryEvent Realm 테스트 완료");
    
  } catch (e) {
    print("❌ HistoryEvent Realm 테스트 중 에러: $e");
  }
}

// 통합 데이터베이스 생성 (Car + HistoryEvent)
Future<void> createCombinedRealm() async {
  try {
    print("🏗️ 통합 데이터베이스 생성: ${RealmConfig.combinedDbPath}");
    
    var realm = Realm(RealmConfig.combinedConfig);
    
    // JSON에서 HistoryEvent 데이터 로드
    final events = await loadHistoryEventsFromJson();
    
    // 데이터 저장
    realm.write(() {
      // 기존 데이터 삭제
      realm.deleteAll<HistoryEvent>();
      realm.deleteAll<Car>();
      
      // HistoryEvent 저장
      for (var event in events) {
        realm.add(event);
      }
      
      // Car 데이터 저장
      realm.add(Car("Tesla", "Model Y", kilometers: 5));
      realm.add(Car("BMW", "X5", kilometers: 15000));
      realm.add(Car("Toyota", "Prius", kilometers: 8000));
    });
    
    print("💾 통합 데이터베이스 생성 완료: ${events.length}개 이벤트 + 3개 차량");
    realm.close();
    
  } catch (e) {
    print("❌ 통합 데이터베이스 생성 중 에러: $e");
  }
}

// 통합 데이터베이스 테스트
Future<void> testCombinedRealm() async {
  try {
    print("🔍 통합 데이터베이스 테스트: ${RealmConfig.combinedDbPath}");
    
    var realm = Realm(RealmConfig.combinedConfig);
    
    var events = realm.all<HistoryEvent>();
    var cars = realm.all<Car>();
    
    print("📊 통합 DB 내용:");
    print("   - 이벤트: ${events.length}개");
    print("   - 차량: ${cars.length}개");
    
    realm.close();
    
  } catch (e) {
    print("❌ 통합 데이터베이스 테스트 중 에러: $e");
  }
}

// 통합 테스트 함수
Future<void> runHistoryEventTests() async {
  print("🚀 HistoryEvent 통합 테스트 시작\n");
  print("=" * 50);
  
  // 1. JSON 로딩 테스트
  print("\n1️⃣ JSON 데이터 로딩 테스트");
  print("-" * 30);
  await loadHistoryEventsFromJson();
  
  // 2. Realm 생성 테스트
  print("\n2️⃣ Realm 데이터베이스 생성 테스트");
  print("-" * 30);
  await createHistoryEventRealm();
  
  // 3. Realm 읽기 테스트
  print("\n3️⃣ Realm 데이터베이스 읽기 테스트");
  print("-" * 30);
  await testHistoryEventRealm();
  
  print("\n" + "=" * 50);
  print("🎯 모든 테스트 완료!");
}

testLoadHistoryEventsFromJson() async {
  print('\n📚 Step 1: JSON 데이터 로딩 테스트');
  print('----------------------------------------');
  var events = await loadHistoryEventsFromJson();
  print('✅ Step 1 완료: ${events.length}개 이벤트 로드됨');
  
  if (events.isNotEmpty) {
    print('\n🔍 Step 2: 첫 번째 이벤트 상세 정보');
    print('----------------------------------------');
    final firstEvent = events.first;
    print('ID: ${firstEvent.id}');
    print('제목: ${firstEvent.title}');
    print('연도: ${firstEvent.year}');
    print('간단 설명 길이: ${firstEvent.simple.length} 문자');
    print('상세 설명 길이: ${firstEvent.detail.length} 문자');
    print('유튜브 URL: ${firstEvent.youtube_url.isEmpty ? "없음" : firstEvent.youtube_url}');
  }
}

main() async {
  print('🚀 gen_realm.dart 실행 시작');
  print('============================================');
  
  try {
    // Car 테스트 (기존)
    //createDefaultRealm();
    //testDefaultRealm();

    //await testLoadHistoryEventsFromJson();
    //await createHistoryEventRealm();
    await testHistoryEventRealm();

    print('\n============================================');
    print('🎯 실행 완료!');
    
  } catch (e, stackTrace) {
    print('❌ main() 실행 중 에러: $e');
    print('📍 스택 트레이스: $stackTrace');
  }
}

// 테스트 전용 main 함수
Future<void> testMain() async {
  await runHistoryEventTests();
}