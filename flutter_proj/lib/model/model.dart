class HistoricalEvent {
  final String title;
  final String year;
  final String content;
  final String imageUrl;
  final Movie relatedMovie;

  HistoricalEvent({
    required this.title,
    required this.year,
    required this.content,
    required this.imageUrl,
    required this.relatedMovie,
  });
}

class Movie {
  final String title;
  final String year;
  final String director;
  final String posterUrl;
  final String description;

  Movie({
    required this.title,
    required this.year,
    required this.director,
    required this.posterUrl,
    required this.description,
  });
}