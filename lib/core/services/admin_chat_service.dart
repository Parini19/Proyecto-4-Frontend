import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logger/logger.dart';

/// Servicio de chat específico para administradores
/// Proporciona consultas sobre reportes, estadísticas y análisis del sistema
class AdminChatService {
  // Base URL - Detección automática según plataforma
  static String get _baseUrl {
    if (kIsWeb) {
      // Web: usa localhost con HTTPS
      return 'https://localhost:7238';
    } else if (Platform.isAndroid) {
      // Android: usa 10.0.2.2 (apunta al localhost del host) con HTTP
      return 'http://10.0.2.2:5000';
    } else if (Platform.isIOS) {
      // iOS: usa localhost
      return 'http://localhost:5000';
    } else {
      // Desktop (Windows/Mac/Linux): usa localhost con HTTP
      return 'http://localhost:5000';
    }
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  final Logger _logger = Logger();

  /// Envía un mensaje al chatbot admin y recibe la respuesta
  Future<String> sendMessage(String message) async {
    try {
      _logger.i('Enviando mensaje al chatbot admin: $message');

      final response = await _dio.post(
        '/api/admin/chat',
        data: {
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _logger.i('Respuesta del chatbot admin recibida');
        return data['reply'] ?? 'Lo siento, no pude generar una respuesta.';
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Error en AdminChatService: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Tiempo de espera agotado. Por favor, intenta nuevamente.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No se pudo conectar al servidor. Verifica tu conexión.');
      } else {
        throw Exception('Error de red: ${e.message}');
      }
    } catch (e) {
      _logger.e('Error inesperado en AdminChatService: $e');
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }
}
