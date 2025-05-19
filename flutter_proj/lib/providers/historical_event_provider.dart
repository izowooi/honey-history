import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proj/model/model.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final historicalEventProvider = FutureProvider.family<HistoricalEvent, DateTime>((ref, date) async {
  // 두 개의 JSON 파일 로드
  final String historicalEventsString = await rootBundle.loadString('assets/data/historical_events.json');
  final String moviesString = await rootBundle.loadString('assets/data/movies.json');
  
  final Map<String, dynamic> historicalEventsData = json.decode(historicalEventsString);
  final Map<String, dynamic> moviesData = json.decode(moviesString);
  
  // 날짜 형식 변환 (MM-dd)
  final formattedDate = DateFormat('MM-dd').format(date);
  
  // 해당 날짜의 데이터가 있는지 확인
  if (historicalEventsData.containsKey(formattedDate)) {
    final eventData = historicalEventsData[formattedDate];
    final movieId = eventData['relatedMovieId'];
    final movieData = moviesData[movieId];
    
    return HistoricalEvent(
      title: eventData['title'],
      year: eventData['year'],
      contentSimple: eventData['content_simple'],
      contentDetailed: eventData['content_detailed'],
      imageUrl: 'assets/illustration/${eventData['imageUrl']}',
      relatedMovie: Movie(
        title: movieData['title'],
        year: movieData['year'],
        director: movieData['director'],
        posterUrl: movieData['posterUrl'],
        description: movieData['description'],
        videoId: movieData['videoId'],
      ),
    );
  } else {
    // 기본 데이터 반환
    return HistoricalEvent(
      title: '${date.month}월 ${date.day}일의 역사적 사건',
      year: '${1900 + date.day}년',
      contentSimple: '[simple]이 날에 일어난 역사적 사건에 대한 설명입니다. 실제 앱에서는 날짜별로 다른 실제 역사적 사건을 보여줍니다.',
      contentDetailed: '[detailed]이 날에 일어난 역사적 사건에 대한 설명입니다. 실제 앱에서는 날짜별로 다른 실제 역사적 사건을 보여줍니다.',
      imageUrl: 'assets/illustration/default_history.png',
      relatedMovie: Movie(
        title: '관련 영화 제목',
        year: '${2000 + date.day}',
        director: '감독 이름',
        posterUrl: 'assets/illustration/default_movie_poster.jpg',
        description: '이 영화는 해당 역사적 사건을 배경으로 한 작품입니다.',
        videoId: 'iLnmTe5Q2Qw',
      ),
    );
  }
}); 