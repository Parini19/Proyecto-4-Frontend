import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/payment.dart';

class PaymentService {
  final Dio _dio;
  final Logger _logger = Logger();
  final String baseUrl = 'https://localhost:7238/api';

  PaymentService(this._dio);

  /// Processes a payment for a booking
  /// IMPORTANT: This is a simulated payment for educational purposes only
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    try {
      _logger.i('Processing payment for booking ${request.bookingId}');

      final response = await _dio.post(
        '$baseUrl/payments/process',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _logger.i('Payment processed: ${data['success']}');
        return PaymentResult.fromJson(data);
      } else {
        throw Exception('Failed to process payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Error processing payment', error: e);
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Failed to process payment');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error processing payment', error: e);
      throw Exception('Failed to process payment: $e');
    }
  }

  /// Gets a payment by ID
  Future<Payment?> getPayment(String paymentId) async {
    try {
      _logger.i('Fetching payment $paymentId');

      final response = await _dio.get('$baseUrl/payments/$paymentId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return Payment.fromJson(data['payment']);
        }
      }
      return null;
    } on DioException catch (e) {
      _logger.e('Error fetching payment', error: e);
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to fetch payment: ${e.message}');
    }
  }

  /// Gets payment by booking ID
  Future<Payment?> getPaymentByBooking(String bookingId) async {
    try {
      _logger.i('Fetching payment for booking $bookingId');

      final response = await _dio.get('$baseUrl/payments/booking/$bookingId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return Payment.fromJson(data['payment']);
        }
      }
      return null;
    } on DioException catch (e) {
      _logger.e('Error fetching payment by booking', error: e);
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to fetch payment: ${e.message}');
    }
  }

  /// Gets all payments for a user
  Future<List<Payment>> getUserPayments(String userId) async {
    try {
      _logger.i('Fetching payments for user $userId');

      final response = await _dio.get('$baseUrl/payments/user/$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> paymentsJson = data['payments'];
          return paymentsJson
              .map((json) => Payment.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching user payments', error: e);
      throw Exception('Failed to fetch payments: ${e.message}');
    }
  }
}
