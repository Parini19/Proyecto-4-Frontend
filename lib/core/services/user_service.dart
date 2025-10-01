import 'dart:convert';
import 'package:http/http.dart' as http;
import '../entities/user.dart';

class UserService {
  final String baseUrl;

  UserService(this.baseUrl);

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/FirebaseTest/get-all-users'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final users = (data['users'] as List)
          .map((u) => User.fromJson(u))
          .toList();
      return users;
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/FirebaseTest/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = json.decode(response.body);
    
    if (response.statusCode == 200 && data['success'] == true) {
      return LoginResponse(
        success: true,
        message: 'Login successful',
        uid: data['uid'],
        email: data['email'],
        displayName: data['displayName'],
        role: data['role'],
        token: data['token'],
      );
    } else {
      return LoginResponse(
        success: false,
        message: data['message'] ?? 'Login failed',
      );
    }
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
