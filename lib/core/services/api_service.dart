import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL - Cambiar según el ambiente
  static const String _baseUrl = 'https://localhost:7238/api';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Token de autenticación
  String? _authToken;

  // Headers base
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Inicializar el servicio y cargar token guardado
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  // Guardar token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Limpiar token
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // GET request
  Future<ApiResponse> get(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      print('GET: $url');

      final response = await http.get(url, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      print('Error en GET: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // POST request
  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      print('POST: $url');
      print('Body: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      print('Error en POST: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // PUT request
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      print('PUT: $url');

      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      print('Error en PUT: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // DELETE request
  Future<ApiResponse> delete(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      print('DELETE: $url');

      final response = await http.delete(url, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      print('Error en DELETE: $e');
      return ApiResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Manejar respuesta HTTP
  ApiResponse _handleResponse(http.Response response) {
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    try {
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          data: data,
          statusCode: response.statusCode,
        );
      } else {
        // Error del servidor
        String message = 'Error del servidor';

        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        } else if (data is Map && data.containsKey('error')) {
          message = data['error'];
        }

        return ApiResponse(
          success: false,
          message: message,
          statusCode: response.statusCode,
          data: data,
        );
      }
    } catch (e) {
      print('Error parseando respuesta: $e');
      return ApiResponse(
        success: false,
        message: 'Error parseando respuesta del servidor',
        statusCode: response.statusCode,
      );
    }
  }

  // Verificar si hay conexión al servidor
  Future<bool> checkConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/health');
      final response = await http.get(url).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('No hay conexión con el servidor: $e');
      return false;
    }
  }

  // Obtener URL base (útil para debugging)
  String get baseUrl => _baseUrl;

  // Verificar si está autenticado
  bool get isAuthenticated => _authToken != null;
}

// Clase para respuestas de la API
class ApiResponse {
  final bool success;
  final String? message;
  final dynamic data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}
