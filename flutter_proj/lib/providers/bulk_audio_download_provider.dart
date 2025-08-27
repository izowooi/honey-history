import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// 날짜 → 오디오 URL
Uri _buildAudioUri(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final url = 'https://honeyhistory.zowoo.uk/audio/$month$day.mp3';
  return Uri.parse(url);
}

// 날짜 → 캐시 파일 경로(기존 오디오 캐시 규칙과 동일)
Future<File> _resolveCacheFile(DateTime date) async {
  final cacheDir = await getTemporaryDirectory();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final fileName = 'audio_${month}${day}.mp3';
  return File(path.join(cacheDir.path, fileName));
}

class BulkAudioDownloadState {
  final bool isDownloading;
  final int total; // 365 (비윤년 기준)
  final int completed; // 완료(기존+신규)
  final int failed; // 실패 수
  final int concurrency; // 동시 다운로드 개수

  const BulkAudioDownloadState({
    required this.isDownloading,
    required this.total,
    required this.completed,
    required this.failed,
    required this.concurrency,
  });

  BulkAudioDownloadState copyWith({
    bool? isDownloading,
    int? total,
    int? completed,
    int? failed,
    int? concurrency,
  }) {
    return BulkAudioDownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      total: total ?? this.total,
      completed: completed ?? this.completed,
      failed: failed ?? this.failed,
      concurrency: concurrency ?? this.concurrency,
    );
  }
}

final bulkAudioDownloadProvider =
    StateNotifierProvider<BulkAudioDownloadNotifier, BulkAudioDownloadState>((ref) {
  return BulkAudioDownloadNotifier();
});

class BulkAudioDownloadNotifier extends StateNotifier<BulkAudioDownloadState> {
  BulkAudioDownloadNotifier()
      : super(const BulkAudioDownloadState(
          isDownloading: false,
          total: 365,
          completed: 0,
          failed: 0,
          concurrency: 5,
        )) {
    _scanExisting();
  }

  // 비윤년 기준 365일 생성 (2025년)
  List<DateTime> _allDates() {
    final year = 2025; // 비윤년
    final List<DateTime> dates = [];
    DateTime day = DateTime(year, 1, 1);
    while (day.year == year) {
      dates.add(day);
      day = day.add(const Duration(days: 1));
    }
    return dates;
  }

  Future<void> _scanExisting() async {
    final all = _allDates();
    int existing = 0;
    for (final d in all) {
      final file = await _resolveCacheFile(d);
      if (await file.exists()) existing++;
    }
    state = state.copyWith(completed: existing);
  }

  Future<void> refreshExistingCount() async {
    if (state.isDownloading) return;
    await _scanExisting();
  }

  Future<void> startDownload() async {
    if (state.isDownloading) return;
    state = state.copyWith(isDownloading: true, failed: 0);
    try {
      final all = _allDates();
      // 대기열 구성 (이미 존재하는 파일은 제외)
      final List<DateTime> pending = [];
      for (final d in all) {
        final file = await _resolveCacheFile(d);
        if (!await file.exists()) {
          pending.add(d);
        }
      }

      if (pending.isEmpty) {
        state = state.copyWith(isDownloading: false);
        return;
      }

      final client = http.Client();
      try {
        int idx = 0;
        while (idx < pending.length) {
          final end = (idx + state.concurrency) > pending.length ? pending.length : idx + state.concurrency;
          final batch = pending.sublist(idx, end);
          await Future.wait(batch.map((d) async {
            final ok = await _downloadOne(client, d);
            if (ok) {
              state = state.copyWith(completed: state.completed + 1);
            } else {
              state = state.copyWith(failed: state.failed + 1);
            }
          }));
          idx = end;
        }
      } finally {
        client.close();
      }
    } finally {
      state = state.copyWith(isDownloading: false);
    }
  }

  Future<bool> _downloadOne(http.Client client, DateTime date) async {
    try {
      final file = await _resolveCacheFile(date);
      if (await file.exists()) {
        return true; // 이미 있음
      }
      final uri = _buildAudioUri(date);
      final req = http.Request('GET', uri);
      final res = await client.send(req);
      if (res.statusCode != 200) {
        final month = date.month.toString().padLeft(2, '0');
        final day = date.day.toString().padLeft(2, '0');
        debugPrint('BulkAudio: FAILED HTTP ${res.statusCode} for ${month}-${day} → ${uri.toString()}');
        return false;
      }
      final tempFile = File('${file.path}.part');
      if (!await tempFile.parent.exists()) {
        await tempFile.parent.create(recursive: true);
      }
      final sink = tempFile.openWrite();
      await res.stream.pipe(sink);
      await sink.close();
      await tempFile.rename(file.path);
      return true;
    } catch (e) {
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final uri = _buildAudioUri(date);
      debugPrint('BulkAudio: ERROR for ${month}-${day} → ${uri.toString()} :: $e');
      return false;
    }
  }
}


