import 'dart:math';
import '../models/screening.dart';
import 'api_service.dart';

class ScreeningService {
  final ApiService _apiService = ApiService();

  /// Get all screenings from backend
  Future<List<Screening>> getAllScreenings() async {
    try {
      final response = await _apiService.get('/screenings/get-all-screenings');

      if (!response.success) {
        print('Error getting screenings: ${response.message}');
        return mockScreenings; // Fallback to mock data
      }

      if (response.data == null) {
        return mockScreenings; // Fallback to mock data
      }

      // Expected backend response: { success: true, screenings: [...] }
      final List<dynamic> screeningsJson = response.data['screenings'] as List<dynamic>;

      return screeningsJson.map((json) => Screening.fromJson(json)).toList();
    } catch (e) {
      print('Exception in getAllScreenings: $e');
      return mockScreenings; // Fallback to mock data
    }
  }

  /// Get screening by ID from backend
  Future<Screening?> getScreeningById(String id) async {
    try {
      final response = await _apiService.get('/screenings/get-screening/$id');

      if (!response.success || response.data == null) {
        return null;
      }

      // Expected backend response: { success: true, screening: {...} }
      return Screening.fromJson(response.data['screening']);
    } catch (e) {
      print('Exception in getScreeningById: $e');
      return null;
    }
  }

  /// Create new screening
  Future<bool> createScreening(Screening screening) async {
    try {
      // Generate a unique ID for the new screening
      final screeningId = _generateScreeningId();
      
      final screeningData = screening.toJson();
      screeningData['id'] = screeningId;
      
      final response = await _apiService.post('/screenings/add-screening', body: screeningData);
      return response.success;
    } catch (e) {
      print('Exception in createScreening: $e');
      return false;
    }
  }

  /// Update existing screening
  Future<bool> updateScreening(Screening screening) async {
    try {
      final response = await _apiService.put('/screenings/edit-screening/${screening.id}', body: screening.toJson());
      return response.success;
    } catch (e) {
      print('Exception in updateScreening: $e');
      return false;
    }
  }

  /// Delete screening
  Future<bool> deleteScreening(String id) async {
    try {
      final response = await _apiService.delete('/screenings/delete-screening/$id');
      return response.success;
    } catch (e) {
      print('Exception in deleteScreening: $e');
      return false;
    }
  }

  /// Get screenings by movie ID
  Future<List<Screening>> getScreeningsByMovieId(String movieId) async {
    try {
      final allScreenings = await getAllScreenings();
      return allScreenings.where((screening) => screening.movieId == movieId).toList();
    } catch (e) {
      print('Exception in getScreeningsByMovieId: $e');
      return [];
    }
  }

  /// Get screenings by theater room ID
  Future<List<Screening>> getScreeningsByTheaterRoomId(String theaterRoomId) async {
    try {
      final allScreenings = await getAllScreenings();
      return allScreenings.where((screening) => screening.theaterRoomId == theaterRoomId).toList();
    } catch (e) {
      print('Exception in getScreeningsByTheaterRoomId: $e');
      return [];
    }
  }

  /// Get future screenings (not started yet)
  Future<List<Screening>> getFutureScreenings() async {
    try {
      final allScreenings = await getAllScreenings();
      return allScreenings.where((screening) => screening.isFuture).toList();
    } catch (e) {
      print('Exception in getFutureScreenings: $e');
      return mockScreenings.where((screening) => screening.isFuture).toList();
    }
  }

  /// Get active screenings (currently running)
  Future<List<Screening>> getActiveScreenings() async {
    try {
      final allScreenings = await getAllScreenings();
      return allScreenings.where((screening) => screening.isActive).toList();
    } catch (e) {
      print('Exception in getActiveScreenings: $e');
      return [];
    }
  }

  /// Get screenings for a specific date
  Future<List<Screening>> getScreeningsByDate(DateTime date) async {
    try {
      final allScreenings = await getAllScreenings();
      return allScreenings.where((screening) {
        final screeningDate = screening.startTime;
        return screeningDate.year == date.year &&
               screeningDate.month == date.month &&
               screeningDate.day == date.day;
      }).toList();
    } catch (e) {
      print('Exception in getScreeningsByDate: $e');
      return [];
    }
  }

  /// Check for scheduling conflicts
  Future<bool> hasSchedulingConflict(Screening newScreening) async {
    try {
      final existingScreenings = await getScreeningsByTheaterRoomId(newScreening.theaterRoomId);
      
      for (final existing in existingScreenings) {
        if (existing.id == newScreening.id) continue; // Skip self when updating
        
        // Check if time ranges overlap
        if (newScreening.startTime.isBefore(existing.endTime) &&
            newScreening.endTime.isAfter(existing.startTime)) {
          return true; // Conflict found
        }
      }
      
      return false; // No conflicts
    } catch (e) {
      print('Exception in hasSchedulingConflict: $e');
      return true; // Assume conflict if error (safer)
    }
  }

  /// Get screenings with pagination
  Future<List<Screening>> getScreeningsPaginated({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final allScreenings = await getAllScreenings();
      final startIndex = (page - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      
      if (startIndex >= allScreenings.length) {
        return [];
      }
      
      return allScreenings.sublist(
        startIndex,
        endIndex > allScreenings.length ? allScreenings.length : endIndex,
      );
    } catch (e) {
      print('Exception in getScreeningsPaginated: $e');
      return [];
    }
  }

  /// Generate a unique screening ID
  String _generateScreeningId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return 'SCR_${timestamp}_$random';
  }
}