import 'package:flutter_riverpod/flutter_riverpod.dart';

final fontSizeScaleProvider = StateProvider<double>((ref) => 1.0);
final showMoviesProvider = StateProvider<bool>((ref) => false);
final useDetailedContentProvider = StateProvider<bool>((ref) => false); 