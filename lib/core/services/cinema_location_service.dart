import '../models/cinema_location.dart';
import 'api_service.dart';

/// Servicio para gestionar las operaciones CRUD de cines/sedes
/// Se comunica con el backend en /api/CinemaLocations
class CinemaLocationService {
  final ApiService _apiService = ApiService();

  /// Obtiene todos los cines
  /// GET /api/CinemaLocations/get-all-cinemas
  Future<List<CinemaLocation>> getAllCinemas() async {
    try {
      final response = await _apiService.get('/CinemaLocations/get-all-cinemas');

      if (!response.success || response.data == null) {
        return [];
      }

      final List<dynamic> cinemasList = response.data['cinemas'] ?? [];
      return cinemasList.map((json) => CinemaLocation.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching cinemas: $e');
    }
  }

  /// Obtiene solo los cines activos
  /// GET /api/CinemaLocations/get-active-cinemas
  Future<List<CinemaLocation>> getActiveCinemas() async {
    try {
      final response = await _apiService.get('/CinemaLocations/get-active-cinemas');

      if (!response.success || response.data == null) {
        return [];
      }

      final List<dynamic> cinemasList = response.data['cinemas'] ?? [];
      return cinemasList.map((json) => CinemaLocation.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching active cinemas: $e');
    }
  }

  /// Obtiene un cine por ID
  /// GET /api/CinemaLocations/get-cinema/{id}
  Future<CinemaLocation?> getCinemaById(String id) async {
    try {
      final response = await _apiService.get('/CinemaLocations/get-cinema/$id');

      if (!response.success || response.data == null) {
        return null;
      }

      return CinemaLocation.fromJson(response.data['cinema']);
    } catch (e) {
      throw Exception('Error fetching cinema: $e');
    }
  }

  /// Obtiene cines por ciudad
  /// GET /api/CinemaLocations/get-cinemas-by-city/{city}
  Future<List<CinemaLocation>> getCinemasByCity(String city) async {
    try {
      final response = await _apiService.get('/CinemaLocations/get-cinemas-by-city/$city');

      if (!response.success || response.data == null) {
        return [];
      }

      final List<dynamic> cinemasList = response.data['cinemas'] ?? [];
      return cinemasList.map((json) => CinemaLocation.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching cinemas by city: $e');
    }
  }

  /// Crea un nuevo cine
  /// POST /api/CinemaLocations/add-cinema
  Future<CinemaLocation> createCinema(CinemaLocation cinema) async {
    try {
      final response = await _apiService.post('/CinemaLocations/add-cinema', body: cinema.toJson());

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to create cinema');
      }

      return CinemaLocation.fromJson(response.data['cinema']);
    } catch (e) {
      throw Exception('Error creating cinema: $e');
    }
  }

  /// Actualiza un cine existente
  /// PUT /api/CinemaLocations/update-cinema/{id}
  Future<bool> updateCinema(CinemaLocation cinema) async {
    try {
      final response = await _apiService.put('/CinemaLocations/update-cinema/${cinema.id}', body: cinema.toJson());
      return response.success;
    } catch (e) {
      throw Exception('Error updating cinema: $e');
    }
  }

  /// Elimina un cine
  /// DELETE /api/CinemaLocations/delete-cinema/{id}
  Future<bool> deleteCinema(String id) async {
    try {
      final response = await _apiService.delete('/CinemaLocations/delete-cinema/$id');
      return response.success;
    } catch (e) {
      throw Exception('Error deleting cinema: $e');
    }
  }

  /// Activa o desactiva un cine
  /// PATCH /api/CinemaLocations/toggle-status/{id}
  Future<bool> toggleCinemaStatus(String id, bool isActive) async {
    try {
      final response = await _apiService.put('/CinemaLocations/toggle-status/$id', body: {'isActive': isActive});
      return response.success;
    } catch (e) {
      throw Exception('Error toggling cinema status: $e');
    }
  }

  /// Obtiene estadísticas de un cine
  /// GET /api/CinemaLocations/get-stats/{id}
  Future<CinemaStats> getCinemaStats(String id) async {
    try {
      final response = await _apiService.get('/CinemaLocations/get-stats/$id');

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get stats');
      }

      return CinemaStats.fromJson(response.data['stats']);
    } catch (e) {
      throw Exception('Error fetching cinema stats: $e');
    }
  }
}
