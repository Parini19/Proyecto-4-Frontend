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
  final bool? isNew;

  MovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.duration,
    required this.genre,
    required this.classification,
    this.colors = const [],
    this.director,
    this.cast,
    this.year,
    this.showtimes,
    this.trailer,
    this.posterUrl,
    this.isNew,
  });

  /// Convert from backend JSON format
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0.0).toString(),
      duration: '${json['durationMinutes'] ?? 0} min',
      genre: json['genre'] ?? '',
      classification: json['classification'] ?? '',
      colors: [], // Colors are not stored in backend
      director: json['director'],
      cast: null, // Cast is not stored in backend
      year: (json['year'] ?? 0).toString(),
      showtimes: json['showtimes'] != null
          ? List<String>.from(json['showtimes'])
          : null,
      trailer: json['trailerUrl'],
      posterUrl: json['posterUrl'],
      isNew: json['isNew'] ?? false,
    );
  }

  /// Convert to backend JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rating': double.tryParse(rating) ?? 0.0,
      'durationMinutes': int.tryParse(duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      'genre': genre,
      'classification': classification,
      'director': director ?? '',
      'year': int.tryParse(year ?? '0') ?? 0,
      'showtimes': showtimes ?? [],
      'trailerUrl': trailer,
      'posterUrl': posterUrl ?? '',
      'isNew': isNew ?? false,
    };
  }

  /// Create a copy with modified fields
  MovieModel copyWith({
    String? id,
    String? title,
    String? description,
    String? rating,
    String? duration,
    String? genre,
    String? classification,
    List<String>? colors,
    String? director,
    List<String>? cast,
    String? year,
    List<String>? showtimes,
    String? trailer,
    String? posterUrl,
    bool? isNew,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
      genre: genre ?? this.genre,
      classification: classification ?? this.classification,
      colors: colors ?? this.colors,
      director: director ?? this.director,
      cast: cast ?? this.cast,
      year: year ?? this.year,
      showtimes: showtimes ?? this.showtimes,
      trailer: trailer ?? this.trailer,
      posterUrl: posterUrl ?? this.posterUrl,
      isNew: isNew ?? this.isNew,
    );
  }
}
