import 'dart:math';
import '../models/movie_model.dart';
import 'api_service.dart';

class MoviesService {
  final ApiService _apiService = ApiService();

  Future<List<MovieModel>> getAllMovies() async {
    try {
      final response = await _apiService.get('/movies/get-all-movies');

      if (!response.success) {
        return [];
      }

      if (response.data == null) {
        return [];
      }

      // El backend devuelve { success: true, movies: [...] }
      final List<dynamic> moviesJson = response.data['movies'] as List<dynamic>;

      return moviesJson.map((json) => _mapToMovieModel(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<MovieModel?> getMovieById(String id) async {
    try {
      final response = await _apiService.get('/movies/get-movie/$id');

      if (!response.success || response.data == null) {
        return null;
      }

      // El backend devuelve { success: true, movie: {...} }
      return _mapToMovieModel(response.data['movie']);
    } catch (e) {
      return null;
    }
  }

  MovieModel _mapToMovieModel(dynamic json) {
    // Mapeo del JSON del backend (Firestore) a nuestro modelo frontend
    return MovieModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '0.0',
      duration: '${json['durationMinutes'] ?? 0} min',
      genre: json['genre']?.toString() ?? '',
      classification: json['classification']?.toString() ?? 'NR',
      colors: ['#E6A23C', '#F56C6C', '#1A1A1A'], // Colores por defecto para UI
      director: json['director']?.toString(),
      cast: null, // El backend no tiene cast actualmente
      year: json['year']?.toString(),
      showtimes: json['showtimes'] != null 
          ? List<String>.from(json['showtimes']) 
          : null,
      trailer: json['trailerUrl']?.toString(),
      posterUrl: json['posterUrl']?.toString() ?? 'https://via.placeholder.com/300x450?text=No+Image',
    );
  }

  Future<bool> createMovie(MovieModel movie, {String? posterBase64}) async {
    try {
      // Generate a unique ID for the new movie
      final movieId = _generateMovieId();

      final response = await _apiService.post('/movies/add-movie', body: {
        'movie': {
          'id': movieId,
          'title': movie.title,
          'description': movie.description,
          'durationMinutes': int.tryParse(movie.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
          'genre': movie.genre,
          'director': movie.director ?? '',
          'year': int.tryParse(movie.year ?? '0') ?? 0,
          'posterUrl': movie.posterUrl ?? '',
          'trailerUrl': movie.trailer,
          'rating': double.tryParse(movie.rating) ?? 0.0,
          'classification': movie.classification,
          'isNew': false,
          'showtimes': movie.showtimes ?? [],
        },
        'posterBase64': posterBase64,
      });

      return response.success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMovie(MovieModel movie, {String? posterBase64}) async {
    try {
      final response = await _apiService.put('/movies/edit-movie/${movie.id}', body: {
        'movie': {
          'id': movie.id,
          'title': movie.title,
          'description': movie.description,
          'durationMinutes': int.tryParse(movie.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
          'genre': movie.genre,
          'director': movie.director ?? '',
          'year': int.tryParse(movie.year ?? '0') ?? 0,
          'posterUrl': movie.posterUrl ?? '',
          'trailerUrl': movie.trailer,
          'rating': double.tryParse(movie.rating) ?? 0.0,
          'classification': movie.classification,
          'isNew': false,
          'showtimes': movie.showtimes ?? [],
        },
        'posterBase64': posterBase64,
      });

      return response.success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMovie(String id) async {
    try {
      final response = await _apiService.delete('/movies/delete-movie/$id');
      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Generate a unique ID for new movies
  String _generateMovieId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return 'MOV_${timestamp}_$random';
  }
}
