import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_proj/widget/error_display.dart';
import 'package:flutter_proj/providers/historical_event_provider.dart';
import 'package:flutter_proj/providers/settings_provider.dart';
import 'package:flutter_proj/providers/audio_provider.dart';
import 'package:flutter_proj/widgets/history/history_content_widget.dart';
import 'package:flutter_proj/widgets/settings/settings_drawer.dart';
import 'package:flutter_proj/widgets/remote_config_test_widget.dart';
import 'package:flutter_proj/providers/build_info_provider.dart';

class DailyCalendarWidget extends ConsumerStatefulWidget {
  const DailyCalendarWidget({super.key});

  @override
  ConsumerState<DailyCalendarWidget> createState() => _DailyCalendarWidgetState();
}

class _DailyCalendarWidgetState extends ConsumerState<DailyCalendarWidget> {
  @override
  void initState() {
    super.initState();
    final selectedDate = ref.read(selectedDateProvider);
    loadAudio(ref, selectedDate);
    print('Initial selectedDate: $selectedDate');
  }

  void _toggleAudio(WidgetRef ref) {
    final date = ref.read(selectedDateProvider);
    toggleAudio(ref, date).then((ok) {
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('오디오를 재생할 수 없습니다. 잠시 후 다시 시도해주세요.')),
        );
      }
    });
  }

  Widget _buildAudioControl(WidgetRef ref) {
    final duration = ref.watch(audioDurationProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final hasAudioFile = ref.watch(hasAudioFileProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasAudioFile)
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
            onPressed: () => _toggleAudio(ref),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDebug = ref.watch(isDebugProvider);
    var selectedDate = ref.watch(selectedDateProvider);
    if (isDebug) {
      final now = DateTime.now();
      final day = (now.day % 10) == 0 ? 1 : (now.day % 10);
      selectedDate = DateTime(now.year, 6, day);
    }

    // 날짜가 변경될 때만 오디오 로드
    ref.listen(selectedDateProvider, (previous, next) {
      if (previous != next) {
        loadAudio(ref, next);
      }
    });

    final historicalEvent = ref.watch(historicalEventProvider(selectedDate));
    final showMovies = ref.watch(showMoviesProvider);
    final fontSizeScale = ref.watch(fontSizeScaleProvider);
    final showSwipeHint = ref.watch(showSwipeHintProvider);

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: historicalEvent.when(
            data: (event) => Text(
              event.title,
              key: ValueKey(event.title),
              style: TextStyle(
                fontSize: 24 * fontSizeScale,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            loading: () => const Text('로딩 중...'),
            error: (_, __) => const Text('오류 발생'),
          ),
        ),
        // actions: [
        //   Consumer(
        //     builder: (context, ref, _) {
        //       final isReviewBuild = ref.watch(isReviewBuildProvider);
        //       return isReviewBuild.when(
        //         data: (flag) {
        //           if (flag) return const SizedBox.shrink();
        //           return IconButton(
        //             icon: const Icon(Icons.cloud_download),
        //             onPressed: () {
        //               Navigator.push(
        //                 context,
        //                 MaterialPageRoute(
        //                   builder: (context) => const RemoteConfigTestWidget(),
        //                 ),
        //               );
        //             },
        //             tooltip: 'Remote Config 테스트',
        //           );
        //         },
        //         loading: () => const SizedBox.shrink(),
        //         error: (_, __) => const SizedBox.shrink(),
        //       );
        //     },
        //   ),
        // ],
      ),
      drawer: const SettingsDrawer(),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // 오른쪽으로 스와이프 - 이전 날짜
            ref.read(selectedDateProvider.notifier).state = 
                selectedDate.subtract(const Duration(days: 1));
            // 스와이프 후 힌트 숨기기
            hideSwipeHint();
          } else if (details.primaryVelocity! < 0) {
            // 왼쪽으로 스와이프 - 다음 날짜
            ref.read(selectedDateProvider.notifier).state = 
                selectedDate.add(const Duration(days: 1));
            // 스와이프 후 힌트 숨기기
            hideSwipeHint();
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: historicalEvent.when(
                data: (event) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateHeader(context, selectedDate, fontSizeScale, ref),
                    //const SizedBox(height: 24),
                    HistoryContentWidget(
                      event: event,
                      showMovies: showMovies,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => ErrorDisplay(message: err.toString()),
              ),
            ),
            // 스와이프 힌트 오버레이
            if (showSwipeHint.when(
              data: (show) => show,
              loading: () => false,
              error: (_, __) => false,
            ))
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '스와이프하여 날짜 변경',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14 * fontSizeScale,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime selectedDate, double fontSizeScale, WidgetRef ref) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 0),
      color: Colors.blue.withOpacity(0.0),
      child: Stack(
        children: [
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
          Positioned(
            top: 0,
            right: 0,
            child: _buildAudioControl(ref),
          ),
        ],
      ),
    );
  }
}
