import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // URL base del API según la plataforma
  static String get baseUrl {
    if (kIsWeb) {
      // Web: usa localhost con HTTPS (puerto 7238)
      return 'https://localhost:7238';
    } else if (Platform.isAndroid) {
      // Android: usa 10.0.2.2 (apunta al localhost del host) con HTTP (puerto 5000)
      return 'http://10.0.2.2:5000';
    } else if (Platform.isIOS) {
      // iOS: usa localhost con HTTP
      return 'http://localhost:5000';
    } else {
      // Desktop (Windows/Mac/Linux): usa localhost con HTTP
      return 'http://localhost:5000';
    }
  }

  // URLs de endpoints específicos
  static String get loginUrl => '$baseUrl/api/FirebaseTest/login';
  static String get registerUrl => '$baseUrl/api/FirebaseTest/add-user';
  static String get usersUrl => '$baseUrl/api/FirebaseTest/get-all-users';
  static String get moviesUrl => '$baseUrl/api/movies';
  static String get meUrl => '$baseUrl/api/me';
  static String get claimsUrl => '$baseUrl/api/ClaimTicket';
}
