import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/booking.dart';

class BookingService {
  final Dio _dio;
  final Logger _logger = Logger();
  final String baseUrl = 'https://localhost:7238/api';

  BookingService(this._dio);

  /// Creates a new booking
  Future<Booking> createBooking(CreateBookingRequest request) async {
    try {
      _logger.i('Creating booking for screening ${request.screeningId}');

      final response = await _dio.post(
        '$baseUrl/bookings/create',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          _logger.i('Booking created successfully: ${data['booking']['id']}');
          return Booking.fromJson(data['booking']);
        } else {
          throw Exception(data['message'] ?? 'Failed to create booking');
        }
      } else {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Error creating booking', error: e);
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Failed to create booking');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error creating booking', error: e);
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Gets a booking by ID
  Future<Booking?> getBooking(String bookingId) async {
    try {
      _logger.i('Fetching booking $bookingId');

      final response = await _dio.get('$baseUrl/bookings/$bookingId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return Booking.fromJson(data['booking']);
        }
      }
      return null;
    } on DioException catch (e) {
      _logger.e('Error fetching booking', error: e);
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to fetch booking: ${e.message}');
    }
  }

  /// Gets all bookings for a user
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      _logger.i('Fetching bookings for user $userId');

      final response = await _dio.get('$baseUrl/bookings/user/$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> bookingsJson = data['bookings'];
          return bookingsJson
              .map((json) => Booking.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching user bookings', error: e);
      throw Exception('Failed to fetch bookings: ${e.message}');
    }
  }

  /// Confirms a booking
  Future<bool> confirmBooking(String bookingId, String paymentId) async {
    try {
      _logger.i('Confirming booking $bookingId');

      final response = await _dio.put(
        '$baseUrl/bookings/$bookingId/confirm',
        data: {'paymentId': paymentId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      _logger.e('Error confirming booking', error: e);
      throw Exception('Failed to confirm booking: ${e.message}');
    }
  }

  /// Cancels a booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      _logger.i('Cancelling booking $bookingId');

      final response = await _dio.delete('$baseUrl/bookings/$bookingId/cancel');

      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      _logger.e('Error cancelling booking', error: e);
      throw Exception('Failed to cancel booking: ${e.message}');
    }
  }

  /// Gets occupied seats for a screening
  Future<List<String>> getOccupiedSeats(String screeningId) async {
    try {
      _logger.i('Fetching occupied seats for screening $screeningId');

      final response = await _dio.get('$baseUrl/bookings/occupied-seats/$screeningId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> seatsJson = data['occupiedSeats'];
          return seatsJson.map((seat) => seat.toString()).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching occupied seats', error: e);
      // Return empty list on error to allow graceful degradation
      return [];
    }
  }
}
