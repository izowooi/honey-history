import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

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

Uri _buildAudioUri(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final url = 'https://honeyhistory.zowoo.uk/audio/$month$day.mp3';
  return Uri.parse(url);
}

Future<File> _resolveCacheFile(DateTime date) async {
  final cacheDir = await getTemporaryDirectory();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final fileName = 'audio_${month}${day}.mp3';
  return File(path.join(cacheDir.path, fileName));
}

Future<void> loadAudio(WidgetRef ref, DateTime date) async {
  print('Loading audio for date: ${date.toString()}');
  final player = ref.read(audioPlayerProvider);
  final uri = _buildAudioUri(date);
  final cacheFile = await _resolveCacheFile(date);

  try {
    if (await cacheFile.exists()) {
      print('Using cached audio: ${cacheFile.path}');
      await player.setFilePath(cacheFile.path);
      ref.read(hasAudioFileProvider.notifier).state = true;
    } else {
      print('Downloading audio from: $uri');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        await cacheFile.writeAsBytes(response.bodyBytes, flush: true);
        print('Saved to cache: ${cacheFile.path}');
        await player.setFilePath(cacheFile.path);
        ref.read(hasAudioFileProvider.notifier).state = true;
      } else {
        print('Audio not found: HTTP ${response.statusCode}');
        ref.read(hasAudioFileProvider.notifier).state = false;
        return;
      }
    }

    final duration = await player.duration;
    print('Audio duration: $duration');
    if (duration != null) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      ref.read(audioDurationProvider.notifier).state =
          "$minutes:${seconds.toString().padLeft(2, '0')}";
    }
  } catch (e) {
    print('Error loading audio: $e');
    ref.read(hasAudioFileProvider.notifier).state = false;
  }
}

Future<bool> toggleAudio(WidgetRef ref, DateTime date) async {
  print('Toggle audio called');
  final player = ref.read(audioPlayerProvider);
  var isPlaying = ref.read(isPlayingProvider);

  if (isPlaying) {
    await player.pause();
    ref.read(isPlayingProvider.notifier).state = false;
    return true;
  }

  // Not playing → ensure source prepared
  if (!ref.read(hasAudioFileProvider)) {
    await loadAudio(ref, date);
  }

  if (!ref.read(hasAudioFileProvider)) {
    // prepare failed
    return false;
  }

  await player.play();
  ref.read(isPlayingProvider.notifier).state = true;
  return true;
}