import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie_model.dart';
import '../models/screening.dart';
import '../services/movies_service.dart';
import '../services/screening_service.dart';

/// Cached Movies Provider
/// Loads movies ONCE and keeps them in memory.
/// Only reloads when explicitly invalidated with ref.invalidate()
final cachedMoviesProvider = FutureProvider<List<MovieModel>>((ref) async {
  print('🎬 [CACHE] Loading movies from backend... (this should happen ONCE)');
  final moviesService = MoviesService();
  final movies = await moviesService.getAllMovies();
  print('🎬 [CACHE] Loaded ${movies.length} movies - now cached in memory');
  return movies;
});

/// Cached Screenings Provider
/// Loads screenings ONCE and keeps them in memory.
/// Only reloads when explicitly invalidated
final cachedScreeningsProvider = FutureProvider<List<Screening>>((ref) async {
  print('🎞️  [CACHE] Loading screenings from backend... (this should happen ONCE)');
  final screeningsService = ScreeningService();
  final screenings = await screeningsService.getAllScreenings();
  print('🎞️  [CACHE] Loaded ${screenings.length} screenings - now cached in memory');
  return screenings;
});

/// Helper provider to manually refresh cached data
/// Usage: ref.read(cacheRefreshProvider.notifier).refreshMovies()
final cacheRefreshProvider = NotifierProvider<CacheRefreshNotifier, int>(() {
  return CacheRefreshNotifier();
});

class CacheRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Manually refresh movies cache
  void refreshMovies() {
    print('🔄 [CACHE] Manually refreshing movies...');
    ref.invalidate(cachedMoviesProvider);
    state = state + 1;
  }

  /// Manually refresh screenings cache
  void refreshScreenings() {
    print('🔄 [CACHE] Manually refreshing screenings...');
    ref.invalidate(cachedScreeningsProvider);
    state = state + 1;
  }

  /// Refresh all cached data
  void refreshAll() {
    print('🔄 [CACHE] Manually refreshing ALL cached data...');
    ref.invalidate(cachedMoviesProvider);
    ref.invalidate(cachedScreeningsProvider);
    state = state + 1;
  }
}
