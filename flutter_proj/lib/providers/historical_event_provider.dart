import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proj/model/model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_proj/providers/settings_provider.dart';
import 'package:realm/realm.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_proj/history_event.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
}); 

// Realm DB 복사 함수
Future<void> copyRealmFromAssets() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final realmPath = '${appDocDir.path}/history_events.realm';
  final realmFile = File(realmPath);
  
  if (!realmFile.existsSync()) {
    final data = await rootBundle.load('assets/history_events.realm');
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    
    if (realmFile.existsSync()) {
      await realmFile.delete();
    }
    
    await realmFile.writeAsBytes(bytes);
    print('Realm DB copied from assets to: $realmPath');
  }
}

// Realm 싱글턴 Provider
final realmProvider = FutureProvider<Realm>((ref) async {
  // DB 초기화
  await copyRealmFromAssets();
  
  // 앱 문서 디렉토리 경로 가져오기
  final appDocDir = await getApplicationDocumentsDirectory();
  final realmPath = '${appDocDir.path}/history_events.realm';
  
  // Realm 설정 및 열기
  var config = Configuration.local(
    [HistoryEvent.schema],
    path: realmPath,
    isReadOnly: true,
  );
  
  return Realm(config);
});

final historicalEventProvider = FutureProvider.family<HistoricalEvent, DateTime>((ref, date) async {
  try {
    // 싱글턴 Realm 가져오기
    final realm = await ref.watch(realmProvider.future);
    
    // 날짜 형식 변환 (MM-dd)
    final formattedDate = DateFormat('MM-dd').format(date);
    
    // 해당 날짜의 데이터 쿼리
    var events = realm.all<HistoryEvent>().query("id == '$formattedDate'");
    
    if (events.isNotEmpty) {
      final event = events.first;
      
      // Realm HistoryEvent를 UI HistoricalEvent로 변환
      return HistoricalEvent(
        title: event.title.isEmpty ? '${date.month}월 ${date.day}일의 역사적 사건' : event.title,
        year: event.year.isEmpty ? '${1900 + date.day}년' : event.year,
        contentSimple: event.simple.isEmpty 
            ? '[simple]이 날에 일어난 역사적 사건에 대한 설명입니다. 실제 앱에서는 날짜별로 다른 실제 역사적 사건을 보여줍니다.' 
            : event.simple,
        contentDetailed: event.detail.isEmpty 
            ? '[detailed]이 날에 일어난 역사적 사건에 대한 설명입니다. 실제 앱에서는 날짜별로 다른 실제 역사적 사건을 보여줍니다.' 
            : event.detail,
        imageUrl: 'assets/illustration/default_history.png', // 기본 이미지 사용
        relatedMovie: _createDefaultMovie(date),
      );
    } else {
      return _createDefaultEvent(date);
    }
    
  } catch (e) {
    print('Error loading historical event from Realm DB: $e');
    return _createDefaultEvent(date);
  }
}); 

HistoricalEvent _createDefaultEvent(DateTime date) {
  return HistoricalEvent(
    title: '${date.month}월 ${date.day}일의 역사적 사건',
    year: '${1900 + date.day}년',
    contentSimple: '[simple]이 날에 일어난 역사적 사건에 대한 설명입니다. 실제 앱에서는 날짜별로 다른 실제 역사적 사건을 보여줍니다.',
    contentDetailed: '[detailed]이 날에 일어난 역사적 사건에 대한 설명입니다. 실제 앱에서는 날짜별로 다른 실제 역사적 사건을 보여줍니다.',
    imageUrl: 'assets/illustration/default_history.png',
    relatedMovie: _createDefaultMovie(date),
  );
}

Movie _createDefaultMovie(DateTime date) {
  return Movie(
    title: '관련 영화 제목',
    year: '${2000 + date.day}',
    director: '감독 이름',
    posterUrl: 'assets/illustration/default_movie_poster.jpg',
    description: '이 영화는 해당 역사적 사건을 배경으로 한 작품입니다.',
    videoId: 'iLnmTe5Q2Qw',
  );
} 