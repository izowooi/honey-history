import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proj/model/model.dart';
import 'package:flutter_proj/providers/settings_provider.dart';
import 'package:flutter_proj/widgets/movie/movie_section_widget.dart';

class HistoryContentWidget extends ConsumerWidget {
  final HistoricalEvent event;
  final bool showMovies;

  const HistoryContentWidget({
    super.key,
    required this.event,
    required this.showMovies,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizeScale = ref.watch(fontSizeScaleProvider);
    final useDetailedContent = ref.watch(useDetailedContentProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${event.year}년 ${event.title}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20 * fontSizeScale,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: double.infinity,
                    ),
                    child: Image.asset(
                      event.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 40),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  useDetailedContent ? event.contentDetailed : event.contentSimple,
                  style: TextStyle(
                    fontSize: 16 * fontSizeScale,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showMovies && event.relatedMovie != null && event.relatedMovie!.videoId.isNotEmpty) ...[
          const SizedBox(height: 24),
          MovieSectionWidget(movie: event.relatedMovie),
        ],
      ],
    );
  }
} 