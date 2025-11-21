import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/chat_models.dart';

class ChatService {
  final Dio _dio;

  ChatService() : _dio = Dio() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Agregar interceptor para logging (opcional)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  Future<String> sendMessage(String message) async {
    try {
      final request = ChatRequest(message: message);
      
      final response = await _dio.post(
        '/api/chat',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final chatResponse = ChatResponse.fromJson(response.data);
        return chatResponse.reply;
      } else {
        throw Exception('Error al obtener respuesta del chat: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Tiempo de conexión agotado. Verifica tu conexión a internet.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Tiempo de espera agotado. El servidor tardó demasiado en responder.');
      } else if (e.response != null) {
        throw Exception('Error del servidor: ${e.response!.statusCode}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}