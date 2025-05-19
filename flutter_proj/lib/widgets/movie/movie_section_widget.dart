import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proj/model/model.dart';
import 'package:flutter_proj/providers/settings_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieSectionWidget extends ConsumerStatefulWidget {
  final Movie? movie;

  const MovieSectionWidget({
    super.key,
    required this.movie,
  });

  @override
  ConsumerState<MovieSectionWidget> createState() => _MovieSectionWidgetState();
}

class _MovieSectionWidgetState extends ConsumerState<MovieSectionWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.movie!.videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (widget.movie != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movie == null) {
      return const SizedBox.shrink();
    }

    final fontSizeScale = ref.watch(fontSizeScaleProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관련 영화',
          style: TextStyle(
            fontSize: 20 * fontSizeScale,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubePlayer(
                      controller: _controller,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.red,
                      progressColors: const ProgressBarColors(
                        playedColor: Colors.red,
                        handleColor: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.movie!.title,
                  style: TextStyle(
                    fontSize: 18 * fontSizeScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.movie!.year} | ${widget.movie!.director}',
                  style: TextStyle(
                    fontSize: 14 * fontSizeScale,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.movie!.description,
                  style: TextStyle(
                    fontSize: 16 * fontSizeScale,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 