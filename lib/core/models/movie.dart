import 'movie_model.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final String genre;
  final String director;
  final String posterUrl;
  final String? trailerUrl;
  final double rating; // 0-5
  final String classification; // PG-13, R, etc.
  final bool isNew;
  final List<String> showtimes;

  const Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.genre,
    required this.director,
    required this.posterUrl,
    this.trailerUrl,
    required this.rating,
    required this.classification,
    this.isNew = false,
    required this.showtimes,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      durationMinutes: json['durationMinutes'] as int,
      genre: json['genre'] as String,
      director: json['director'] as String,
      posterUrl: json['posterUrl'] as String,
      trailerUrl: json['trailerUrl'] as String?,
      rating: (json['rating'] as num).toDouble(),
      classification: json['classification'] as String,
      isNew: json['isNew'] as bool? ?? false,
      showtimes: (json['showtimes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'genre': genre,
      'director': director,
      'posterUrl': posterUrl,
      'trailerUrl': trailerUrl,
      'rating': rating,
      'classification': classification,
      'isNew': isNew,
      'showtimes': showtimes,
    };
  }

  String get durationFormatted {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  // Convert to MovieModel
  MovieModel toMovieModel() {
    return MovieModel(
      id: id,
      title: title,
      description: description,
      rating: rating.toString(),
      duration: durationFormatted,
      genre: genre,
      classification: classification,
      colors: ['#000000', '#FFFFFF'], // Default colors
      director: director,
      cast: null,
      year: null,
      showtimes: showtimes,
      trailer: trailerUrl,
      posterUrl: posterUrl,
    );
  }
}

// Mock data para desarrollo
final List<Movie> mockMovies = [
  Movie(
    id: '1',
    title: 'Demon Slayer: Castillo Infinito',
    description:
        'Tanjiro y sus compañeros se enfrentan a nuevos demonios en el misterioso Castillo Infinito.',
    durationMinutes: 120,
    genre: 'Acción, Anime',
    director: 'Haruo Sotozaki',
    posterUrl:
        'https://image.tmdb.org/t/p/w500/xUfRZu2mi8jH6SzQEJGP6tjBuYj.jpg',
    trailerUrl: 'https://youtube.com/watch?v=example',
    rating: 4.8,
    classification: 'PG-13',
    isNew: true,
    showtimes: ['14:30', '17:00', '19:30', '22:00'],
  ),
  Movie(
    id: '3',
    title: 'The Dark Knight',
    description:
        'Batman se enfrenta al Joker en una batalla épica por el alma de Gotham City.',
    durationMinutes: 152,
    genre: 'Acción, Drama',
    director: 'Christopher Nolan',
    posterUrl:
        'https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_.jpg',
    rating: 4.9,
    classification: 'PG-13',
    isNew: false,
    showtimes: ['16:00', '19:30', '22:30'],
  ),
  Movie(
    id: '4',
    title: 'Avengers: Endgame',
    description:
        'Los Vengadores se reúnen una última vez para deshacer las acciones de Thanos.',
    durationMinutes: 181,
    genre: 'Acción, Aventura',
    director: 'Anthony y Joe Russo',
    posterUrl:
        'https://m.media-amazon.com/images/M/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_.jpg',
    rating: 4.7,
    classification: 'PG-13',
    isNew: true,
    showtimes: ['14:00', '17:30', '21:00'],
  ),
  Movie(
    id: '5',
    title: 'Parasite',
    description:
        'Una familia pobre se infiltra en la vida de una familia rica con consecuencias inesperadas.',
    durationMinutes: 132,
    genre: 'Drama, Suspenso',
    director: 'Bong Joon-ho',
    posterUrl:
        'https://m.media-amazon.com/images/M/MV5BYWZjMjk3ZTItODQ2ZC00NTY5LWE0ZDYtZTI3MjcwN2Q5NTVkXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_.jpg',
    rating: 4.6,
    classification: 'R',
    isNew: false,
    showtimes: ['15:30', '18:30', '21:30'],
  ),
];
