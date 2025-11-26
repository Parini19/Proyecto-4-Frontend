import 'dart:math';
import '../models/theater_room_model.dart';
import 'api_service.dart';

class TheaterRoomsService {
  final ApiService _apiService = ApiService();

  Future<List<TheaterRoomModel>> getAllTheaterRooms() async {
    try {
      final response = await _apiService.get('/theaterrooms/get-all-theater-rooms');

      if (!response.success) {
        return [];
      }

      if (response.data == null) {
        return [];
      }

      // El backend devuelve { success: true, rooms: [...] }
      final List<dynamic> roomsJson = response.data['rooms'] as List<dynamic>;

      return roomsJson.map((json) => TheaterRoomModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error en getAllTheaterRooms: $e');
      return [];
    }
  }

  Future<TheaterRoomModel?> getTheaterRoomById(String id) async {
    try {
      final response = await _apiService.get('/theaterrooms/get-theater-room/$id');

      if (!response.success || response.data == null) {
        return null;
      }

      // El backend devuelve { success: true, room: {...} }
      return TheaterRoomModel.fromJson(response.data['room']);
    } catch (e) {
      print('❌ Error en getTheaterRoomById: $e');
      return null;
    }
  }

  Future<bool> addTheaterRoom(TheaterRoomModel room) async {
    try {
      // Generate a unique ID for the new theater room
      final roomId = _generateRoomId();
      
      final roomData = room.toJson();
      roomData['id'] = roomId;
      
      final response = await _apiService.post('/theaterrooms/add-theater-room', body: roomData);
      return response.success;
    } catch (e) {
      print('Error adding theater room: $e');
      return false;
    }
  }

  Future<bool> updateTheaterRoom(TheaterRoomModel room) async {
    try {
      final response = await _apiService.put('/theaterrooms/edit-theater-room/${room.id}', body: room.toJson());
      return response.success;
    } catch (e) {
      print('Error updating theater room: $e');
      return false;
    }
  }

  Future<bool> deleteTheaterRoom(String id) async {
    try {
      final response = await _apiService.delete('/theaterrooms/delete-theater-room/$id');
      return response.success;
    } catch (e) {
      print('Error deleting theater room: $e');
      return false;
    }
  }

  /// Generate a unique room ID
  String _generateRoomId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return 'ROOM_${timestamp}_$random';
  }
}