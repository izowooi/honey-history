import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  
  // 플레이어의 실제 상태 변경을 감지하는 리스너 추가
  player.playerStateStream.listen((state) {
    print('Player State Changed: ${state.playing ? 'Playing' : 'Paused'}');
    print('Processing State: ${state.processingState}');
    ref.read(isPlayingProvider.notifier).state = state.playing;
  });

  // 오디오 재생 완료 리스너
  player.playerStateStream.listen((state) {
    if (state.processingState == ProcessingState.completed) {
      print('Audio Playback Completed');
    }
  });

  ref.onDispose(() {
    print('AudioPlayer disposed');
    player.dispose();
  });
  return player;
});

final audioDurationProvider = StateProvider<String>((ref) => "00:00");
final isPlayingProvider = StateProvider<bool>((ref) => false);
final hasAudioFileProvider = StateProvider<bool>((ref) => false);

Future<void> loadAudio(WidgetRef ref, DateTime date) async {
  print('Loading audio for date: ${date.toString()}');
  final player = ref.read(audioPlayerProvider);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final audioPath = 'assets/audio/$month$day.mp3';
  print('Audio path: $audioPath');

  try {
    // 오디오 파일 존재 여부 확인
    final hasFile = await rootBundle.load(audioPath).then((_) => true).catchError((_) => false);
    print('Audio file exists: $hasFile');
    ref.read(hasAudioFileProvider.notifier).state = hasFile;

    if (hasFile) {
      print('Setting audio asset...');
      await player.setAsset(audioPath);
      print('Audio asset set successfully');
      
      final duration = await player.duration;
      print('Audio duration: $duration');
      if (duration != null) {
        final minutes = duration.inMinutes;
        final seconds = duration.inSeconds % 60;
        ref.read(audioDurationProvider.notifier).state = 
            "$minutes:${seconds.toString().padLeft(2, '0')}";
      }
    }
  } catch (e) {
    print('Error loading audio: $e');
    ref.read(hasAudioFileProvider.notifier).state = false;
  }
}

Future<void> toggleAudio(WidgetRef ref) async {
  print('Toggle audio called');
  final player = ref.read(audioPlayerProvider);
  var isPlaying = ref.read(isPlayingProvider);

  print('Current isPlaying state: $isPlaying');
  if (isPlaying) {
    print('Pausing audio...');
    await player.pause();
    print('Audio paused');
  } else {
    print('Playing audio...');
    await player.play();
    print('Play command executed');
  }
  isPlaying = !isPlaying;
  print('Updating isPlaying state to: $isPlaying');
  ref.read(isPlayingProvider.notifier).state = isPlaying;
} 