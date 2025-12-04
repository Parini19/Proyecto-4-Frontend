import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cinema_location.dart';
import '../services/cinema_location_service.dart';

/// Provider for the cinema location service
final cinemaLocationServiceProvider = Provider<CinemaLocationService>((ref) {
  return CinemaLocationService();
});

/// Provider for all cinema locations
final cinemasProvider = FutureProvider<List<CinemaLocation>>((ref) async {
  final service = ref.watch(cinemaLocationServiceProvider);
  return await service.getAllCinemas();
});

/// Notifier for managing the selected cinema
class SelectedCinemaNotifier extends Notifier<CinemaLocation?> {
  @override
  CinemaLocation? build() => null;

  void selectCinema(CinemaLocation cinema) {
    state = cinema;
  }

  void clearSelection() {
    state = null;
  }
}

/// Provider for the currently selected cinema
/// This persists the user's cinema selection
final selectedCinemaProvider = NotifierProvider<SelectedCinemaNotifier, CinemaLocation?>(
  () => SelectedCinemaNotifier(),
);
