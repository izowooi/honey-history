class HistoricalEvent {
  final String year;
  final String title;
  final String imageUrl;
  final String contentSimple;
  final String contentDetailed;
  final Movie? relatedMovie;

  HistoricalEvent({
    required this.year,
    required this.title,
    required this.imageUrl,
    required this.contentSimple,
    required this.contentDetailed,
    this.relatedMovie,
  });

  factory HistoricalEvent.fromJson(Map<String, dynamic> json, Movie? movie) {
    return HistoricalEvent(
      year: json['year'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      contentSimple: json['content_simple'] as String,
      contentDetailed: json['content_detailed'] as String,
      relatedMovie: movie,
    );
  }
}

class Movie {
  final String title;
  final String year;
  final String director;
  final String posterUrl;
  final String description;
  final String videoId;

  Movie({
    required this.title,
    required this.year,
    required this.director,
    required this.posterUrl,
    required this.description,
    required this.videoId,
  });
}