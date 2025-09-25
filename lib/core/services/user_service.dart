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
}
