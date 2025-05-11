import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_proj/model/model.dart';
import 'package:flutter_proj/widget/error_display.dart';
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final historicalEventProvider = FutureProvider.family<HistoricalEvent, DateTime>((ref, date) async {
  // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옵니다
  // 여기서는 예시 데이터를 비동기적으로 반환합니다
  await Future.delayed(const Duration(milliseconds: 300)); // 네트워크 요청 시뮬레이션
  
  // 실제로는 날짜에 따라 다른 데이터를 반환해야 합니다
  final formattedDate = DateFormat('MM-dd').format(date);
  
  if (formattedDate == '05-16') {
    return HistoricalEvent(
      title: '문화대혁명 시작',
      year: '1966년',
      content: '1966년 5월 16일, 중국에서 마오쩌둥이 주도한 문화대혁명이 시작되었습니다. 이 정치 운동은 10년간 지속되었으며, 중국 사회와 경제에 큰 영향을 미쳤습니다.',
      imageUrl: 'assets/images/cultural_revolution.jpg',
      relatedMovies: [
        Movie(
          title: '활착',
          year: '1994',
          director: '장이머우',
          posterUrl: 'assets/images/to_live_poster.jpg',
          description: '한 가족이 문화대혁명을 비롯한 중국 현대사의 격동기를 겪어나가는 이야기',
        ),
        Movie(
          title: '마지막 황제',
          year: '1987',
          director: '베르나르도 베르톨루치',
          posterUrl: 'assets/images/last_emperor_poster.jpg',
          description: '청나라 마지막 황제 푸이의 인생과 문화혁명 시기의 경험을 다룬 작품',
        ),
      ],
    );
  } else {
    // 다른 날짜에 대한 기본 데이터
    return HistoricalEvent(
      title: '${date.month}월 ${date.day}일의 역사적 사건',
      year: '${1900 + date.day}년',
      content: '이 날에 일어난 역사적 사건에 대한 설명입니다. 실제 앱에서는 날짜별로 다른 실제 역사적 사건을 보여줍니다.',
      imageUrl: 'assets/images/default_history.jpg',
      relatedMovies: [
        Movie(
          title: '관련 영화 제목',
          year: '${2000 + date.day}',
          director: '감독 이름',
          posterUrl: 'assets/images/default_movie_poster.jpg',
          description: '이 영화는 해당 역사적 사건을 배경으로 한 작품입니다.',
        ),
      ],
    );
  }
});


class DailyCalendarWidget extends ConsumerWidget {
  const DailyCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final historicalEvent = ref.watch(historicalEventProvider(selectedDate));

    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Calendar'),
      ),
      body: isLandscape
      ? _buildPortrait(context, ref, selectedDate, historicalEvent)
      : _buildPortrait(context, ref, selectedDate, historicalEvent),
    );
  }

  Widget _buildPortrait(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    AsyncValue<HistoricalEvent> historicalEvent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader(context, ref, selectedDate),
        const SizedBox(height: 16),
        _buildHistoryContent(historicalEvent),
      ],
    );
  }

  Widget _buildDateHeader(BuildContext context, WidgetRef ref, DateTime selectedDate) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('yyyy년 MM월 dd일').format(selectedDate),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE', 'ko_KR').format(selectedDate),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  ref.read(selectedDateProvider.notifier).state = 
                      selectedDate.subtract(const Duration(days: 1));
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  final tomorrow = selectedDate.add(const Duration(days: 1));
                  if (!tomorrow.isAfter(DateTime.now())) {
                    ref.read(selectedDateProvider.notifier).state = tomorrow;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(AsyncValue<HistoricalEvent> historicalEventAsync) {
    return historicalEventAsync.when(
      data: (event) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHistoryCard(event),
          const SizedBox(height: 24),
          _buildRelatedMoviesSection(event),
        ],
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => ErrorDisplay(message: err.toString()),
    );
  }

  Widget _buildHistoryCard(HistoricalEvent event, {bool isCompact = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 역사적 사건 이미지
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
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
          
          // 역사적 사건 내용
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.year,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '오늘의 역사',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  event.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedMoviesSection(HistoricalEvent event) {
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
        ...event.relatedMovies.map<Widget>((movie) {
          return _buildMovieCard(movie);
        }).toList(),
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
