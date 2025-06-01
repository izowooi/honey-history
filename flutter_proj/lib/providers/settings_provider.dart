import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences 키 상수
const String _fontSizeScaleKey = 'font_size_scale';
const String _showMoviesKey = 'show_movies';
const String _useDetailedContentKey = 'use_detailed_content';
const String _isDebugKey = 'is_debug';
const String _notificationEnabledKey = 'notification_enabled';
const String _hasSeenSwipeHintKey = 'has_seen_swipe_hint';

// 초기값 로드 함수
Future<double> _loadFontSizeScale() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble(_fontSizeScaleKey) ?? 1.0;
}

Future<bool> _loadShowMovies() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_showMoviesKey) ?? false;
}

Future<bool> _loadUseDetailedContent() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_useDetailedContentKey) ?? false;
}

Future<bool> _loadIsDebug() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_isDebugKey) ?? false;
}

Future<bool> _loadNotificationEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_notificationEnabledKey) ?? false;
}

// Provider 정의
final fontSizeScaleProvider = StateNotifierProvider<FontSizeScaleNotifier, double>((ref) {
  return FontSizeScaleNotifier();
});

final showMoviesProvider = StateNotifierProvider<ShowMoviesNotifier, bool>((ref) {
  return ShowMoviesNotifier();
});

final useDetailedContentProvider = StateNotifierProvider<UseDetailedContentNotifier, bool>((ref) {
  return UseDetailedContentNotifier();
});

final isDebugProvider = StateNotifierProvider<IsDebugNotifier, bool>((ref) {
  return IsDebugNotifier();
});

final notificationEnabledProvider = StateNotifierProvider<NotificationEnabledNotifier, bool>((ref) {
  return NotificationEnabledNotifier();
});

final showSwipeHintProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final hasSeenHint = prefs.getBool(_hasSeenSwipeHintKey);
  return hasSeenHint == null ? true : !hasSeenHint;
});

// Notifier 클래스들
class FontSizeScaleNotifier extends StateNotifier<double> {
  FontSizeScaleNotifier() : super(1.0) {
    _loadValue();
  }

  Future<void> _loadValue() async {
    state = await _loadFontSizeScale();
  }

  Future<void> setValue(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeScaleKey, value);
    state = value;
  }
}

class ShowMoviesNotifier extends StateNotifier<bool> {
  ShowMoviesNotifier() : super(false) {
    _loadValue();
  }

  Future<void> _loadValue() async {
    state = await _loadShowMovies();
  }

  Future<void> setValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showMoviesKey, value);
    state = value;
  }
}

class UseDetailedContentNotifier extends StateNotifier<bool> {
  UseDetailedContentNotifier() : super(false) {
    _loadValue();
  }

  Future<void> _loadValue() async {
    state = await _loadUseDetailedContent();
  }

  Future<void> setValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useDetailedContentKey, value);
    state = value;
  }
}

class IsDebugNotifier extends StateNotifier<bool> {
  IsDebugNotifier() : super(false) {
    _loadValue();
  }

  Future<void> _loadValue() async {
    state = await _loadIsDebug();
  }

  Future<void> setValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDebugKey, value);
    state = value;
  }
}

class NotificationEnabledNotifier extends StateNotifier<bool> {
  NotificationEnabledNotifier() : super(false) {
    _loadValue();
  }

  Future<void> _loadValue() async {
    state = await _loadNotificationEnabled();
  }

  Future<void> setValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, value);
    state = value;
  }
}

void hideSwipeHint() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_hasSeenSwipeHintKey, true);
} 