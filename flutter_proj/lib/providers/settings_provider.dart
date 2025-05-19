import 'package:flutter_riverpod/flutter_riverpod.dart';

final showMoviesProvider = StateProvider<bool>((ref) => false);
final fontSizeScaleProvider = StateProvider<double>((ref) => 1.0); 