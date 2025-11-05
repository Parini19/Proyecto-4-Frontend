import 'package:cinema_frontend/core/services/api_service.dart';
import 'package:cinema_frontend/core/services/auth_service.dart';
import '../entities/user.dart';

class UserService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<List<User>> fetchUsers() async {
    try {
      final response = await _apiService.get('/FirebaseTest/get-all-users');
      if (response.success && response.data != null) {
        final users = (response.data['users'] as List)
            .map((u) => User.fromJson(u))
            .toList();
        return users;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to load users: $e');
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _apiService.post('/FirebaseTest/login', body: {
        'email': email,
        'password': password,
      });

      if (response.success && response.data != null) {
        final data = response.data;

        // Guardar token en ApiService
        final token = data['jwtToken'] ?? data['token'];
        if (token != null) {
          await _apiService.setAuthToken(token);

          // Guardar sesión completa en AuthService
          await _authService.saveSession(
            token: token,
            uid: data['uid'] ?? '',
            email: data['email'] ?? '',
            displayName: data['displayName'],
            role: data['role'],
          );
        }

        return LoginResponse(
          success: true,
          message: 'Login successful',
          uid: data['uid'],
          email: data['email'],
          displayName: data['displayName'],
          role: data['role'],
          token: token,
        );
      } else {
        return LoginResponse(
          success: false,
          message: response.message ?? 'Login failed',
        );
      }
    } catch (e) {
      print('Login error: $e');
      return LoginResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  Future<LoginResponse> register({
    required String email,
    required String password,
    required String displayName,
    String role = 'user',
  }) async {
    try {
      final response = await _apiService.post('/FirebaseTest/add-user', body: {
        'email': email,
        'password': password,
        'displayName': displayName,
        'role': role,
      });

      if (response.success) {
        final data = response.data ?? {};

        return LoginResponse(
          success: true,
          message: data['message'] ?? 'User created successfully',
          uid: data['uid'],
          email: email,
          displayName: displayName,
          role: role,
        );
      } else {
        return LoginResponse(
          success: false,
          message: response.message ?? 'Registration failed',
        );
      }
    } catch (e) {
      print('Registration error: $e');
      return LoginResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  Future<void> logout() async {
    await _apiService.clearAuthToken();
    await _authService.clearSession();
  }

  Future<bool> isLoggedIn() async {
    return _authService.isAuthenticated;
  }

  // Obtener el usuario actual
  UserData? getCurrentUser() {
    return _authService.currentUser;
  }

  // Verificar si es admin
  bool isAdmin() {
    return _authService.isAdmin;
  }

  // Verificar si es user
  bool isUser() {
    return _authService.isUser;
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final String? uid;
  final String? email;
  final String? displayName;
  final String? role;
  final String? token;

  LoginResponse({
    required this.success,
    required this.message,
    this.uid,
    this.email,
    this.displayName,
    this.role,
    this.token,
  });
}
