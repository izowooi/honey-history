import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_proj/model/model.dart';
import 'package:flutter_proj/widget/error_display.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final showMoviesProvider = StateProvider<bool>((ref) => false);

final historicalEventProvider = FutureProvider.family<HistoricalEvent, DateTime>((ref, date) async {
  // JSON 파일 로드
  final String jsonString = await rootBundle.loadString('assets/data/historical_events.json');
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  
  // 날짜 형식 변환 (MM-dd)
  final formattedDate = DateFormat('MM-dd').format(date);
  
  // 해당 날짜의 데이터가 있는지 확인
  if (jsonData.containsKey(formattedDate)) {
    final eventData = jsonData[formattedDate];
    return HistoricalEvent(
      title: eventData['title'],
      year: eventData['year'],
      content: eventData['content'],
      imageUrl: eventData['imageUrl'],
      relatedMovie: Movie(
        title: eventData['relatedMovie']['title'],
        year: eventData['relatedMovie']['year'],
        director: eventData['relatedMovie']['director'],
        posterUrl: eventData['relatedMovie']['posterUrl'],
        description: eventData['relatedMovie']['description'],
      ),
    );
  } else {
    // 기본 데이터 반환
    return HistoricalEvent(
      title: '${date.month}월 ${date.day}일의 역사적 사건',
      year: '${1900 + date.day}년',
      content: '이 날에 일어난 역사적 사건에 대한 설명입니다. 실제 앱에서는 날짜별로 다른 실제 역사적 사건을 보여줍니다.',
      imageUrl: 'assets/illustration/default_history.png',
      relatedMovie: Movie(
        title: '관련 영화 제목',
        year: '${2000 + date.day}',
        director: '감독 이름',
        posterUrl: 'assets/illustration/default_movie_poster.jpg',
        description: '이 영화는 해당 역사적 사건을 배경으로 한 작품입니다.',
      ),
    );
  }
});

class DailyCalendarWidget extends ConsumerWidget {
  const DailyCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final historicalEvent = ref.watch(historicalEventProvider(selectedDate));
    final showMovies = ref.watch(showMoviesProvider);

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: historicalEvent.when(
            data: (event) => Text(
              event.title,
              key: ValueKey(event.title),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            loading: () => const Text('로딩 중...'),
            error: (_, __) => const Text('오류 발생'),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                '설정',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            CheckboxListTile(
              title: const Text('관련 영화 표시'),
              value: showMovies,
              onChanged: (bool? value) {
                if (value != null) {
                  ref.read(showMoviesProvider.notifier).state = value;
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: historicalEvent.when(
          data: (event) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(context, ref, selectedDate, event),
              const SizedBox(height: 16),
              _buildHistoryContent(event, showMovies),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ErrorDisplay(message: err.toString()),
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, WidgetRef ref, DateTime selectedDate, HistoricalEvent event) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // 날짜 (우측 상단)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                DateFormat('MM월 dd일 EEEE', 'ko_KR').format(selectedDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          // 제목과 년도 (가운데)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${event.year} ${event.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(HistoricalEvent event, bool showMovies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 40),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showMovies) ...[
          const SizedBox(height: 24),
          _buildRelatedMovieSection(event),
        ],
      ],
    );
  }

  Widget _buildRelatedMovieSection(HistoricalEvent event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '관련 영화',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildMovieCard(event.relatedMovie),
      ],
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // 영화 상세 정보 페이지로 이동
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영화 포스터
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: SizedBox(
                width: 100,
                height: 150,
                child: Image.asset(
                  movie.posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.movie, size: 40),
                      ),
                    );
                  },
                ),
              ),
            ),
            // 영화 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.year} • ${movie.director}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
