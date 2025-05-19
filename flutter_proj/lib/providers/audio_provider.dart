import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioDurationProvider = StateProvider<String>((ref) => "3:48");
final isPlayingProvider = StateProvider<bool>((ref) => false); 