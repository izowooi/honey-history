import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_proj/model/model.dart';
import 'package:flutter_proj/widget/error_display.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_proj/providers/audio_provider.dart';
import 'package:flutter_proj/providers/settings_provider.dart';
import 'package:flutter_proj/providers/historical_event_provider.dart';

class DailyCalendarWidget extends ConsumerStatefulWidget {
  const DailyCalendarWidget({super.key});

  @override
  ConsumerState<DailyCalendarWidget> createState() => _DailyCalendarWidgetState();
}

class _DailyCalendarWidgetState extends ConsumerState<DailyCalendarWidget> {
  YoutubePlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initYoutubePlayer(String videoId) {
    _controller?.dispose();
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: true,
      ),
    );
  }

  void _toggleAudio() {
    // 더미 로직: 재생 상태 토글
    ref.read(isPlayingProvider.notifier).state = !ref.read(isPlayingProvider);
  }

  Widget _buildAudioControl() {
    final duration = ref.watch(audioDurationProvider);
    final isPlaying = ref.watch(isPlayingProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(8),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.0),
      //       blurRadius: 4,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            duration,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
              color: Colors.black87,
              size: 24,
            ),
            onPressed: _toggleAudio,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '글자 크기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            RadioListTile<double>(
              title: const Text('보통'),
              value: 1.0,
              groupValue: ref.watch(fontSizeScaleProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(fontSizeScaleProvider.notifier).state = value;
                }
              },
            ),
            RadioListTile<double>(
              title: const Text('크게'),
              value: 1.2,
              groupValue: ref.watch(fontSizeScaleProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(fontSizeScaleProvider.notifier).state = value;
                }
              },
            ),
            RadioListTile<double>(
              title: const Text('더 크게'),
              value: 1.5,
              groupValue: ref.watch(fontSizeScaleProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(fontSizeScaleProvider.notifier).state = value;
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
    final fontSizeScale = ref.watch(fontSizeScaleProvider);
    
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 0),
      color: Colors.blue.withOpacity(0.0),
      child: Stack(
        children: [
          // 날짜 (좌측)
          Positioned(
            top: 10,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                DateFormat('MM월 dd일 EEEE', 'ko_KR').format(selectedDate),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16 * fontSizeScale,
                ),
              ),
            ),
          ),
          // 오디오 컨트롤 (우측)
          Positioned(
            top: 0,
            right: 0,
            child: _buildAudioControl(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(HistoricalEvent event, bool showMovies) {
    final fontSizeScale = ref.watch(fontSizeScaleProvider);
    
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
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${event.year} ${event.title}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20 * fontSizeScale,
                      ),
                    ),
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
                const SizedBox(height: 16),
                Text(
                  event.content,
                  style: TextStyle(
                    fontSize: 16 * fontSizeScale,
                    height: 1.5,
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
    // 영화 제목으로부터 YouTube 비디오 ID를 가져오는 로직
    // 실제 구현에서는 movie 객체에 videoId 필드를 추가하는 것이 좋습니다
    final videoId = movie.videoId;
    _initYoutubePlayer(videoId);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: _controller != null
                ? YoutubePlayer(
                    controller: _controller!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.amber,
                    progressColors: const ProgressBarColors(
                      playedColor: Colors.amber,
                      handleColor: Colors.amberAccent,
                    ),
                  )
                : const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
          ),
          Padding(
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
        ],
      ),
    );
  }
}
