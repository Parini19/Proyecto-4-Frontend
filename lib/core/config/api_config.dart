import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  // Configura aquí tu IP local (encuentra con 'ipconfig' en Windows)
  static const String _localIp = '192.168.1.100'; // ⚠️ CAMBIA ESTO A TU IP

  // URL base del API según la plataforma
  static String get baseUrl {
    if (kIsWeb) {
      // En Web, localhost funciona
      return 'http://localhost:5000';
    } else {
      // En Android/iOS, necesitas la IP de tu computadora
      return 'http://$_localIp:5000';
    }
  }

  // URLs de endpoints específicos
  static String get loginUrl => '$baseUrl/api/FirebaseTest/login';
  static String get registerUrl => '$baseUrl/api/FirebaseTest/add-user';
  static String get usersUrl => '$baseUrl/api/FirebaseTest/get-all-users';
  static String get moviesUrl => '$baseUrl/api/movies';
  static String get meUrl => '$baseUrl/api/me';
}
