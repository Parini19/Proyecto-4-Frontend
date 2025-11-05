class MovieModel {
  final String id;
  final String title;
  final String description;
  final String rating;
  final String duration;
  final String genre;
  final String classification;
  final List<String> colors;
  final String? director;
  final List<String>? cast;
  final String? year;
  final List<String>? showtimes;
  final String? trailer;
  final String? posterUrl;

  MovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.duration,
    required this.genre,
    required this.classification,
    required this.colors,
    this.director,
    this.cast,
    this.year,
    this.showtimes,
    this.trailer,
    this.posterUrl,
  });
}
