import 'dart:math';
import '../entities/user.dart';
import 'api_service.dart';
import 'auth_service.dart';

class UserService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  /// Get all users from the backend
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _apiService.get('/FirebaseTest/get-all-users');

      if (!response.success) {
        return [];
      }

      if (response.data == null) {
        return [];
      }

      // El backend devuelve { success: true, users: [...] }
      final List<dynamic> usersJson = response.data['users'] as List<dynamic>;

      return usersJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Legacy method for compatibility
  Future<List<User>> fetchUsers() async {
    return getAllUsers();
  }

  /// Get a specific user by UID
  Future<User?> getUserById(String uid) async {
    try {
      final response = await _apiService.get('/FirebaseTest/get-user/$uid');

      if (!response.success || response.data == null) {
        return null;
      }

      // El backend devuelve { success: true, user: {...} }
      return User.fromJson(response.data['user']);
    } catch (e) {
      return null;
    }
  }

  /// Create a new user (admin function)
  Future<bool> createUser({
    required String email,
    required String password,
    required String displayName,
    String role = 'user',
  }) async {
    try {
      // Generate a unique UID for the new user
      final userUid = _generateUserId();
      
      final response = await _apiService.post('/FirebaseTest/add-user', body: {
        'uid': userUid, // Include the UID in the request body as required by backend validation
        'email': email,
        'password': password,
        'displayName': displayName,
        'role': role,
      });

      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Update user information
  Future<bool> updateUser(User user) async {
    try {
      final response = await _apiService.put('/FirebaseTest/edit-user/${user.uid}', body: {
        'uid': user.uid, // Include the UID in the request body as required by backend validation
        'displayName': user.displayName,
        'role': user.role,
        'disabled': user.disabled,
      });

      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Delete a user
  Future<bool> deleteUser(String uid) async {
    try {
      final response = await _apiService.delete('/FirebaseTest/delete-user/$uid');
      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Toggle user status (enable/disable)
  Future<bool> toggleUserStatus(String uid, bool disabled) async {
    try {
      final response = await _apiService.put('/FirebaseTest/toggle-user-status/$uid', body: {
        'uid': uid, // Include the UID in the request body as required by backend validation
        'disabled': disabled,
      });

      return response.success;
    } catch (e) {
      return false;
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

  /// Generate a unique ID for new users
  String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return 'USER_${timestamp}_$random';
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
