import 'dart:math';
import '../models/theater_room.dart';
import 'api_service.dart';

class TheaterRoomService {
  final ApiService _apiService = ApiService();

  /// Get all theater rooms from Firestore
  Future<List<TheaterRoom>> getAllTheaterRooms() async {
    try {
      print('🏢 Requesting theater rooms from backend...');
      final response = await _apiService.get('/theaterrooms/get-all-theater-rooms');

      print('🏢 Backend response success: ${response.success}');
      print('🏢 Backend response data: ${response.data}');

      if (!response.success) {
        print('⚠️ Backend request failed');
        return []; // Return empty list instead of mock data
      }

      if (response.data == null) {
        print('⚠️ Backend returned null data');
        return []; // Return empty list instead of mock data
      }

      // Expected backend response: { success: true, rooms: [...] }
      final List<dynamic> roomsJson = response.data['rooms'] as List<dynamic>;
      print('🏢 Found ${roomsJson.length} theater rooms from backend');

      return roomsJson.map((json) => TheaterRoom.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error loading theater rooms from backend: $e');
      return []; // Return empty list instead of mock data
    }
  }

  /// Get theater room by ID from Firestore
  Future<TheaterRoom?> getTheaterRoomById(String id) async {
    try {
      final response = await _apiService.get('/theaterrooms/get-theater-room/$id');

      if (!response.success || response.data == null) {
        return null;
      }

      // Expected backend response: { success: true, room: {...} }
      return TheaterRoom.fromJson(response.data['room']);
    } catch (e) {
      return null;
    }
  }

  /// Create new theater room in Firestore
  Future<bool> createTheaterRoom(TheaterRoom room) async {
    try {
      // Generate a unique ID for the new theater room
      final roomId = _generateRoomId();
      
      // Ensure timestamps are UTC
      final now = DateTime.now().toUtc();
      final roomWithTimestamps = room.copyWith(
        id: roomId,
        createdAt: room.createdAt ?? now,
        updatedAt: now,
      );
      
      final response = await _apiService.post('/theaterrooms/add-theater-room', body: roomWithTimestamps.toJson());
      return response.success;
    } catch (e) {
      print('Error creating theater room: $e');
      return false;
    }
  }

  /// Update existing theater room in Firestore
  Future<bool> updateTheaterRoom(TheaterRoom room) async {
    try {
      // Add updatedAt timestamp
      final updatedRoom = room.copyWith(updatedAt: DateTime.now().toUtc());
      final response = await _apiService.put('/theaterrooms/edit-theater-room/${room.id}', body: updatedRoom.toJson());
      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Delete theater room from Firestore
  Future<bool> deleteTheaterRoom(String id) async {
    try {
      final response = await _apiService.delete('/theaterrooms/delete-theater-room/$id');
      return response.success;
    } catch (e) {
      print('Error deleting theater room: $e');
      return false;
    }
  }

  /// Toggle theater room status (active/inactive)
  Future<bool> toggleTheaterRoomStatus(String id, bool isActive) async {
    try {
      final response = await _apiService.put('/theaterrooms/toggle-status/$id', body: {
        'isActive': isActive,
      });
      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Get available theater rooms (for screenings)
  Future<List<TheaterRoom>> getAvailableTheaterRooms() async {
    try {
      final rooms = await getAllTheaterRooms();
      return rooms.where((room) => room.isActive).toList();
    } catch (e) {
      print('❌ Error getting available theater rooms: $e');
      return []; // Return empty list instead of mock data
    }
  }

  /// Check if theater room name is available
  Future<bool> isTheaterRoomNameAvailable(String name, {String? excludeId}) async {
    try {
      final rooms = await getAllTheaterRooms();
      return !rooms.any((room) => 
          room.name.toLowerCase() == name.toLowerCase() && 
          room.id != excludeId);
    } catch (e) {
      return true; // Assume available if error
    }
  }

  /// Get total capacity of all theater rooms
  Future<int> getTotalCapacity() async {
    try {
      final rooms = await getAllTheaterRooms();
      return rooms.fold<int>(0, (total, room) => total + room.capacity);
    } catch (e) {
      return 0;
    }
  }

  /// Generate a unique room ID
  String _generateRoomId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return 'ROOM_${timestamp}_$random';
  }

  /// Initialize default theater rooms if backend is empty
  Future<bool> initializeDefaultRooms() async {
    try {
      print('🏢 Initializing default theater rooms...');
      
      // Check if there are already rooms in the backend
      final existingRooms = await getAllTheaterRooms();
      if (existingRooms.isNotEmpty) {
        print('🏢 Theater rooms already exist in backend, skipping initialization');
        return true;
      }

      // Create default rooms
      final defaultRooms = [
        TheaterRoom(
          id: _generateRoomId(),
          cinemaId: 'DEFAULT_CINEMA',
          name: 'Sala 1 - Premium',
          capacity: 120,
          description: 'Sala premium con asientos reclinables y sonido Dolby Atmos',
          type: 'premium',
          features: ['Asientos reclinables', 'Dolby Atmos', 'Proyección 4K'],
          seatConfiguration: {'rows': 10, 'seatsPerRow': 12},
          createdAt: DateTime.now().toUtc(),
        ),
        TheaterRoom(
          id: _generateRoomId(),
          cinemaId: 'DEFAULT_CINEMA',
          name: 'Sala 2 - Estándar',
          capacity: 180,
          description: 'Sala estándar con excelente calidad de audio y video',
          type: 'standard',
          features: ['Sonido digital', 'Proyección HD'],
          seatConfiguration: {'rows': 15, 'seatsPerRow': 12},
          createdAt: DateTime.now().toUtc(),
        ),
        TheaterRoom(
          id: _generateRoomId(),
          cinemaId: 'DEFAULT_CINEMA',
          name: 'Sala 3 - VIP',
          capacity: 80,
          description: 'Experiencia VIP con servicio de mesero y asientos de lujo',
          type: 'vip',
          features: ['Servicio de mesero', 'Asientos de cuero', 'Mesas individuales'],
          seatConfiguration: {'rows': 8, 'seatsPerRow': 10},
          createdAt: DateTime.now().toUtc(),
        ),
      ];

      // Create each room
      for (final room in defaultRooms) {
        final success = await createTheaterRoom(room);
        if (!success) {
          print('❌ Failed to create room: ${room.name}');
          return false;
        }
        print('✅ Created room: ${room.name}');
      }

      print('🏢 Successfully initialized ${defaultRooms.length} default theater rooms');
      return true;
    } catch (e) {
      print('❌ Error initializing default theater rooms: $e');
      return false;
    }
  }
}