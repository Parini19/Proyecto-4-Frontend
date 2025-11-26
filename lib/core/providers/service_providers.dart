import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/booking_service.dart';
import '../services/payment_service.dart';
import '../services/ticket_service.dart';
import '../services/movie_service.dart';

/// Dio provider - simple configuration for web and mobile
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Add timeout configurations
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  // Base configuration
  dio.options.validateStatus = (status) {
    return status != null && status < 500;
  };

  return dio;
});

/// Booking service provider
final bookingServiceProvider = Provider<BookingService>((ref) {
  final dio = ref.watch(dioProvider);
  return BookingService(dio);
});

/// Payment service provider
final paymentServiceProvider = Provider<PaymentService>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentService(dio);
});

/// Ticket service provider
final ticketServiceProvider = Provider<TicketService>((ref) {
  final dio = ref.watch(dioProvider);
  return TicketService(dio);
});

/// Movie service provider
final movieServiceProvider = Provider<MovieService>((ref) {
  final dio = ref.watch(dioProvider);
  return MovieService(dio);
});
