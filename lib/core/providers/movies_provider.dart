import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/movie_model.dart';
import '../models/screening.dart';
import '../models/cinema_location.dart';
import '../services/movie_service.dart';
import '../services/screening_service.dart';
import 'service_providers.dart';
import 'cinema_provider.dart';

/// Provider for screenings
final screeningsProvider = FutureProvider<List<Screening>>((ref) async {
  final dio = ref.watch(dioProvider);
  final screeningService = ScreeningService();
  return await screeningService.getAllScreenings();
});

/// Provider for all movies
final moviesProvider = FutureProvider<List<MovieModel>>((ref) async {
  final movieService = ref.watch(movieServiceProvider);
  return await movieService.getAllMovies();
});

/// Provider for movies filtered by category
final nowPlayingMoviesProvider = FutureProvider<List<MovieModel>>((ref) async {
  final movies = await ref.watch(moviesProvider.future);
  // En Cartelera = Already released movies (isNew = false)
  return movies.where((m) => m.isNew == false).toList();
});

final upcomingMoviesProvider = FutureProvider<List<MovieModel>>((ref) async {
  final movies = await ref.watch(moviesProvider.future);
  // Próximos Estrenos = New/upcoming movies (isNew = true)
  return movies.where((m) => m.isNew == true).toList();
});

final popularMoviesProvider = FutureProvider<List<MovieModel>>((ref) async {
  final movies = await ref.watch(moviesProvider.future);
  // Only include movies currently playing (isNew=false) to avoid duplicates with upcoming
  final nowPlayingMovies = movies.where((m) => m.isNew == false).toList();
  // Sort by rating and take top movies
  nowPlayingMovies.sort((a, b) {
    final ratingA = double.tryParse(a.rating) ?? 0;
    final ratingB = double.tryParse(b.rating) ?? 0;
    return ratingB.compareTo(ratingA);
  });
  return nowPlayingMovies.take(8).toList();
});

/// Provider for movies filtered by selected cinema
final moviesFilteredByCinemaProvider = FutureProvider<List<MovieModel>>((ref) async {
  final selectedCinema = ref.watch(selectedCinemaProvider);
  final allMovies = await ref.watch(moviesProvider.future);

  // If no cinema is selected, return all movies
  if (selectedCinema == null) {
    return allMovies;
  }

  // Get screenings for the selected cinema
  final allScreenings = await ref.watch(screeningsProvider.future);
  final cinemaScreenings = allScreenings.where((s) => s.cinemaId == selectedCinema.id).toList();

  // Get unique movie IDs that have screenings at this cinema
  final availableMovieIds = cinemaScreenings.map((s) => s.movieId).toSet();

  // Filter movies to only those available at this cinema
  return allMovies.where((m) => availableMovieIds.contains(m.id)).toList();
});

/// Provider for now playing movies filtered by selected cinema
final nowPlayingFilteredByCinemaProvider = FutureProvider<List<MovieModel>>((ref) async {
  final filteredMovies = await ref.watch(moviesFilteredByCinemaProvider.future);
  // En Cartelera = Already released movies (isNew = false)
  return filteredMovies.where((m) => m.isNew == false).toList();
});

/// Provider for upcoming movies filtered by selected cinema
/// NOTE: Upcoming movies don't have screenings yet, so they are NOT filtered by cinema
final upcomingFilteredByCinemaProvider = FutureProvider<List<MovieModel>>((ref) async {
  // Próximos Estrenos = New/upcoming movies (isNew = true)
  // These movies don't have screenings, so we show all of them regardless of cinema selection
  return await ref.watch(upcomingMoviesProvider.future);
});

/// Provider for popular movies filtered by selected cinema
final popularFilteredByCinemaProvider = FutureProvider<List<MovieModel>>((ref) async {
  final filteredMovies = await ref.watch(moviesFilteredByCinemaProvider.future);
  // Más Populares = Only now playing movies (isNew = false)
  final nowPlayingMovies = filteredMovies.where((m) => m.isNew == false).toList();

  nowPlayingMovies.sort((a, b) {
    final ratingA = double.tryParse(a.rating) ?? 0;
    final ratingB = double.tryParse(b.rating) ?? 0;
    return ratingB.compareTo(ratingA);
  });

  return nowPlayingMovies.take(8).toList();
});

/// Provider for a single movie by ID
final movieByIdProvider = FutureProvider.family<MovieModel?, String>((ref, id) async {
  final movieService = ref.watch(movieServiceProvider);
  return await movieService.getMovie(id);
});
