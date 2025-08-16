import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proj/model/model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_proj/db/app_database.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
}); 

// Drift DB Provider (싱글턴)
final driftDbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final historicalEventProvider = FutureProvider.family<HistoricalEvent, DateTime>((ref, date) async {
  try {
    final db = ref.watch(driftDbProvider);
    
    // 날짜 형식 변환 (MM-dd)
    final formattedDate = DateFormat('MM-dd').format(date);
    
    final dbEvent = await db.getEventById(formattedDate);
    if (dbEvent != null) {
      return HistoricalEvent(
        title: dbEvent.title.isEmpty ? '${date.month}월 ${date.day}일의 역사적 사건' : dbEvent.title,
        year: dbEvent.year.isEmpty ? '${1900 + date.day}년' : dbEvent.year,
        contentSimple: dbEvent.simple.isEmpty 
            ? '[simple]이 날에 일어난 역사적 사건에 대한 설명입니다. 실제 앱에서는 날짜별로 다른 실제 역사적 사건을 보여줍니다.' 
            : dbEvent.simple,
        contentDetailed: dbEvent.detail.isEmpty 
            ? '[detailed]이 날에 일어난 역사적 사건에 대한 설명입니다. 실제 앱에서는 날짜별로 다른 실제 역사적 사건을 보여줍니다.' 
            : dbEvent.detail,
        imageUrl: 'assets/illustration/${formattedDate.replaceAll('-', '')}.webp',
        relatedMovie: dbEvent.youtubeUrl.isEmpty ? null : _createMovieFromYoutubeUrl(dbEvent.youtubeUrl),
      );
    }
    return _createDefaultEvent(date);
    
  } catch (e) {
    print('Error loading historical event from Drift DB: $e');
    return _createDefaultEvent(date);
  }
}); 

// YouTube URL에서 videoId 추출하는 함수
String _extractVideoIdFromUrl(String youtubeUrl) {
  if (youtubeUrl.isEmpty) {
    return '';
  }
  
  // https://www.youtube.com/watch?v=_erVOAbz420 형태
  if (youtubeUrl.contains('youtube.com/watch?v=')) {
    final uri = Uri.parse(youtubeUrl);
    final videoId = uri.queryParameters['v'];
    if (videoId != null && videoId.isNotEmpty) {
      return videoId;
    }
  }
  
  // https://youtu.be/_erVOAbz420 형태
  if (youtubeUrl.contains('youtu.be/')) {
    final uri = Uri.parse(youtubeUrl);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      final videoId = pathSegments.first;
      if (videoId.isNotEmpty) {
        return videoId;
      }
    }
  }
  
  // 지원하지 않는 URL 형태
  print('Warning: Unsupported YouTube URL format: $youtubeUrl');
  return '';
}

// YouTube URL로부터 Movie 객체 생성
Movie _createMovieFromYoutubeUrl(String youtubeUrl) {
  final videoId = _extractVideoIdFromUrl(youtubeUrl);
  
  return Movie(
    videoId: videoId.isEmpty ? '' : videoId,
  );
}

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
    videoId: 'iLnmTe5Q2Qw',
  );
} 