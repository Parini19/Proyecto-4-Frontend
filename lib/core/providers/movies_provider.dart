import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie_model.dart';
import '../services/movie_service.dart';
import 'service_providers.dart';

/// Provider for all movies
final moviesProvider = FutureProvider<List<MovieModel>>((ref) async {
  final movieService = ref.watch(movieServiceProvider);
  return await movieService.getAllMovies();
});

/// Provider for movies filtered by category
final nowPlayingMoviesProvider = FutureProvider<List<MovieModel>>((ref) async {
  final movies = await ref.watch(moviesProvider.future);
  return movies.where((m) => m.isNew == true).toList();
});

final upcomingMoviesProvider = FutureProvider<List<MovieModel>>((ref) async {
  final movies = await ref.watch(moviesProvider.future);
  return movies.where((m) => m.isNew == false).toList();
});

final popularMoviesProvider = FutureProvider<List<MovieModel>>((ref) async {
  final movies = await ref.watch(moviesProvider.future);
  // Sort by rating and take top movies
  final sorted = List<MovieModel>.from(movies);
  sorted.sort((a, b) {
    final ratingA = double.tryParse(a.rating) ?? 0;
    final ratingB = double.tryParse(b.rating) ?? 0;
    return ratingB.compareTo(ratingA);
  });
  return sorted.take(8).toList();
});

/// Provider for a single movie by ID
final movieByIdProvider = FutureProvider.family<MovieModel?, String>((ref, id) async {
  final movieService = ref.watch(movieServiceProvider);
  return await movieService.getMovie(id);
});
