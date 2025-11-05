import 'package:cinema_frontend/core/services/api_service.dart';
import 'package:cinema_frontend/core/models/movie_model.dart';

class MoviesService {
  final ApiService _apiService = ApiService();

  Future<List<MovieModel>> getAllMovies() async {
    try {
      final response = await _apiService.get('/movies');

      if (!response.success) {
        print('Error getting movies: ${response.message}');
        return [];
      }

      if (response.data == null) {
        return [];
      }

      // La respuesta es una lista de películas
      final List<dynamic> moviesJson = response.data as List<dynamic>;

      return moviesJson.map((json) => _mapToMovieModel(json)).toList();
    } catch (e) {
      print('Exception in getAllMovies: $e');
      return [];
    }
  }

  Future<MovieModel?> getMovieById(String id) async {
    try {
      final response = await _apiService.get('/movies/$id');

      if (!response.success || response.data == null) {
        return null;
      }

      return _mapToMovieModel(response.data);
    } catch (e) {
      print('Exception in getMovieById: $e');
      return null;
    }
  }

  MovieModel _mapToMovieModel(dynamic json) {
    // Mapeo del JSON del backend a nuestro modelo frontend
    return MovieModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      rating: '0.0', // El backend no tiene rating, usar valor por defecto
      duration: '${json['durationMinutes'] ?? 0} min',
      genre: json['genre']?.toString() ?? '',
      classification: 'NR', // El backend no tiene classification, usar valor por defecto
      colors: ['#E6A23C', '#F56C6C', '#1A1A1A'], // Colores por defecto
      director: json['director']?.toString(),
      cast: null, // El backend no tiene cast actualmente
      year: json['year']?.toString(),
      showtimes: null, // Los showtimes vendrán de Screenings
      trailer: null,
      posterUrl: json['posterUrl']?.toString() ?? 'https://via.placeholder.com/300x450?text=No+Image',
    );
  }

  Future<bool> createMovie(MovieModel movie) async {
    try {
      final response = await _apiService.post('/movies', body: {
        'title': movie.title,
        'description': movie.description,
        'durationMinutes': int.tryParse(movie.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        'genre': movie.genre,
        'director': movie.director ?? '',
        'year': int.tryParse(movie.year ?? '0') ?? 0,
      });

      return response.success;
    } catch (e) {
      print('Exception in createMovie: $e');
      return false;
    }
  }

  Future<bool> updateMovie(MovieModel movie) async {
    try {
      final response = await _apiService.put('/movies/${movie.id}', body: {
        'title': movie.title,
        'description': movie.description,
        'durationMinutes': int.tryParse(movie.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        'genre': movie.genre,
        'director': movie.director ?? '',
        'year': int.tryParse(movie.year ?? '0') ?? 0,
      });

      return response.success;
    } catch (e) {
      print('Exception in updateMovie: $e');
      return false;
    }
  }

  Future<bool> deleteMovie(String id) async {
    try {
      final response = await _apiService.delete('/movies/$id');
      return response.success;
    } catch (e) {
      print('Exception in deleteMovie: $e');
      return false;
    }
  }
}
