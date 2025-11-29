import 'package:dio/dio.dart';

class ConfigService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://localhost:7238/api/config';

  /// Get current audit logging status
  Future<bool> getAuditLoggingStatus() async {
    try {
      final response = await _dio.get('$_baseUrl/audit-logging');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['enabled'] as bool;
      }
      return false;
    } catch (e) {
      print('Error getting audit logging status: $e');
      return false;
    }
  }

  /// Enable or disable audit logging
  Future<bool> setAuditLogging(bool enabled) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/audit-logging',
        data: {'enabled': enabled},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ Audit logging ${enabled ? "ENABLED" : "DISABLED"}');
        return true;
      }
      return false;
    } catch (e) {
      print('Error setting audit logging: $e');
      return false;
    }
  }
}
