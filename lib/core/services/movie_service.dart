import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/movie_model.dart';

class MovieService {
  final Dio _dio;
  final String _baseUrl = 'https://localhost:7238/api/movies';

  MovieService(this._dio);

  /// Get all movies from Firestore
  Future<List<MovieModel>> getAllMovies() async {
    try {
      final response = await _dio.get('$_baseUrl/get-all-movies');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> moviesJson = data['movies'];
          return moviesJson.map((json) => MovieModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load movies');
    } catch (e) {
      print('Error getting movies: $e');
      rethrow;
    }
  }

  /// Get a single movie by ID
  Future<MovieModel?> getMovie(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/get-movie/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return MovieModel.fromJson(data['movie']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting movie: $e');
      return null;
    }
  }

  /// Add a new movie with optional poster image
  Future<Map<String, dynamic>> addMovie({
    required MovieModel movie,
    String? posterBase64,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/add-movie',
        data: {
          'movie': movie.toJson(),
          'posterBase64': posterBase64,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to add movie');
    } catch (e) {
      print('Error adding movie: $e');
      rethrow;
    }
  }

  /// Update an existing movie with optional new poster
  Future<Map<String, dynamic>> updateMovie({
    required String id,
    required MovieModel movie,
    String? posterBase64,
  }) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/edit-movie/$id',
        data: {
          'movie': movie.toJson(),
          'posterBase64': posterBase64,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update movie');
    } catch (e) {
      print('Error updating movie: $e');
      rethrow;
    }
  }

  /// Delete a movie
  Future<bool> deleteMovie(String id) async {
    try {
      final response = await _dio.delete('$_baseUrl/delete-movie/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting movie: $e');
      return false;
    }
  }

  /// Upload a poster image separately
  Future<String?> uploadPoster({
    required String base64Image,
    String? fileName,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/upload-poster',
        data: {
          'base64Image': base64Image,
          'fileName': fileName,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['imageUrl'];
        }
      }
      return null;
    } catch (e) {
      print('Error uploading poster: $e');
      return null;
    }
  }
}
