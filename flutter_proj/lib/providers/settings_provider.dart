import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final fontSizeScaleProvider = StateProvider<double>((ref) => 1.0);
final showMoviesProvider = StateProvider<bool>((ref) => false);
final useDetailedContentProvider = StateProvider<bool>((ref) => false);
final isDebugProvider = StateProvider<bool>((ref) => false);

final showSwipeHintProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final hasSeenHint = prefs.getBool('has_seen_swipe_hint');
  return hasSeenHint == null ? true : !hasSeenHint;
});

void hideSwipeHint() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('has_seen_swipe_hint', true);
} 