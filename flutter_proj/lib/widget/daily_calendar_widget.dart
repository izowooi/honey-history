import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_proj/widget/error_display.dart';
import 'package:flutter_proj/providers/historical_event_provider.dart';
import 'package:flutter_proj/providers/settings_provider.dart';
import 'package:flutter_proj/providers/audio_provider.dart';
import 'package:flutter_proj/widgets/history/history_content_widget.dart';
import 'package:flutter_proj/widgets/settings/settings_drawer.dart';

class DailyCalendarWidget extends ConsumerWidget {
  const DailyCalendarWidget({super.key});

  void _toggleAudio(WidgetRef ref) {
    ref.read(isPlayingProvider.notifier).state = !ref.read(isPlayingProvider);
  }

  Widget _buildAudioControl(WidgetRef ref) {
    final duration = ref.watch(audioDurationProvider);
    final isPlaying = ref.watch(isPlayingProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            onPressed: () => _toggleAudio(ref),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final historicalEvent = ref.watch(historicalEventProvider(selectedDate));
    final showMovies = ref.watch(showMoviesProvider);
    final fontSizeScale = ref.watch(fontSizeScaleProvider);

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
      ),
      drawer: const SettingsDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: historicalEvent.when(
          data: (event) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(context, selectedDate, fontSizeScale, ref),
              const SizedBox(height: 24),
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
