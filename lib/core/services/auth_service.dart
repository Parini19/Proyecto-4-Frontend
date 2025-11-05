import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Keys para SharedPreferences
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserData = 'user_data';

  // Estado en memoria
  String? _authToken;
  UserData? _currentUser;

  // Getters
  bool get isAuthenticated => _authToken != null && _currentUser != null;
  String? get authToken => _authToken;
  UserData? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?.role?.toLowerCase() == 'admin';
  bool get isUser => _currentUser?.role?.toLowerCase() == 'user';

  // Inicializar el servicio y cargar datos guardados
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _authToken = prefs.getString(_keyAuthToken);
    final userData = prefs.getString(_keyUserData);

    if (userData != null) {
      try {
        _currentUser = UserData.fromJson(jsonDecode(userData));
      } catch (e) {
        print('Error cargando datos de usuario: $e');
        await clearSession();
      }
    }
  }

  // Guardar sesión completa
  Future<void> saveSession({
    required String token,
    required String uid,
    required String email,
    String? displayName,
    String? role,
  }) async {
    _authToken = token;
    _currentUser = UserData(
      uid: uid,
      email: email,
      displayName: displayName,
      role: role ?? 'user',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
    await prefs.setString(_keyUserData, jsonEncode(_currentUser!.toJson()));
  }

  // Limpiar sesión (logout)
  Future<void> clearSession() async {
    _authToken = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyUserData);
  }

  // Actualizar datos del usuario
  Future<void> updateUserData({
    String? displayName,
    String? email,
    String? role,
  }) async {
    if (_currentUser == null) return;

    _currentUser = UserData(
      uid: _currentUser!.uid,
      email: email ?? _currentUser!.email,
      displayName: displayName ?? _currentUser!.displayName,
      role: role ?? _currentUser!.role,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(_currentUser!.toJson()));
  }
}

// Modelo de datos del usuario
class UserData {
  final String uid;
  final String email;
  final String? displayName;
  final String role;

  UserData({
    required this.uid,
    required this.email,
    this.displayName,
    required this.role,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'UserData(uid: $uid, email: $email, displayName: $displayName, role: $role)';
  }
}
