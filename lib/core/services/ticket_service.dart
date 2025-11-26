import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/ticket.dart';

class TicketService {
  final Dio _dio;
  final Logger _logger = Logger();
  final String baseUrl = 'https://localhost:7238/api';

  TicketService(this._dio);

  /// Gets a ticket by ID
  Future<Ticket?> getTicket(String ticketId) async {
    try {
      _logger.i('Fetching ticket $ticketId');

      final response = await _dio.get('$baseUrl/tickets/$ticketId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return Ticket.fromJson(data['ticket']);
        }
      }
      return null;
    } on DioException catch (e) {
      _logger.e('Error fetching ticket', error: e);
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to fetch ticket: ${e.message}');
    }
  }

  /// Gets all tickets for a user
  Future<List<Ticket>> getUserTickets(String userId) async {
    try {
      _logger.i('Fetching tickets for user $userId');

      final response = await _dio.get('$baseUrl/tickets/user/$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> ticketsJson = data['tickets'];
          return ticketsJson
              .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching user tickets', error: e);
      throw Exception('Failed to fetch tickets: ${e.message}');
    }
  }

  /// Gets active tickets for a user (not used and not expired)
  Future<List<Ticket>> getActiveUserTickets(String userId) async {
    try {
      _logger.i('Fetching active tickets for user $userId');

      final response = await _dio.get('$baseUrl/tickets/user/$userId/active');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> ticketsJson = data['tickets'];
          return ticketsJson
              .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching active tickets', error: e);
      throw Exception('Failed to fetch active tickets: ${e.message}');
    }
  }

  /// Gets all tickets for a booking
  Future<List<Ticket>> getBookingTickets(String bookingId) async {
    try {
      _logger.i('Fetching tickets for booking $bookingId');

      final response = await _dio.get('$baseUrl/tickets/booking/$bookingId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> ticketsJson = data['tickets'];
          return ticketsJson
              .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching booking tickets', error: e);
      throw Exception('Failed to fetch tickets: ${e.message}');
    }
  }

  /// Validates a ticket QR code and marks it as used
  Future<TicketValidationResult> validateTicket(String qrCodeData) async {
    try {
      _logger.i('Validating ticket');

      final response = await _dio.post(
        '$baseUrl/tickets/validate',
        data: ValidateTicketRequest(qrCodeData: qrCodeData).toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 400) {
        final data = response.data;
        return TicketValidationResult.fromJson(data);
      } else {
        throw Exception('Failed to validate ticket: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Error validating ticket', error: e);
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        return TicketValidationResult(
          success: false,
          message: errorData['message'] ?? 'Failed to validate ticket',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Downloads a ticket PDF
  /// Returns the download URL for url_launcher
  String getTicketDownloadUrl(String ticketId) {
    return '$baseUrl/tickets/$ticketId/download';
  }
}
