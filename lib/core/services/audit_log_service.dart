import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/audit_log.dart';

class AuditLogService {
  final Dio _dio;
  final Logger _logger = Logger();
  final String baseUrl = 'https://localhost:7238/api';

  AuditLogService(this._dio);

  /// Creates a new audit log entry
  Future<AuditLog> createAuditLog(CreateAuditLogRequest request) async {
    try {
      _logger.i('Creating audit log for ${request.action} on ${request.entityType}');

      final response = await _dio.post(
        '$baseUrl/auditlog/add',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          _logger.i('Audit log created successfully: ${data['id']}');
          // Return a minimal audit log since backend doesn't return full object
          return AuditLog(
            id: data['id'] as String,
            action: request.action,
            entityType: request.entityType,
            entityId: request.entityId,
            userId: request.userId,
            userEmail: request.userEmail,
            description: request.description,
            timestamp: DateTime.now(),
            ipAddress: '',
            details: request.details,
            severity: request.severity,
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to create audit log');
        }
      } else {
        throw Exception('Failed to create audit log: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Error creating audit log', error: e);
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Failed to create audit log');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error creating audit log', error: e);
      throw Exception('Failed to create audit log: $e');
    }
  }

  /// Gets an audit log by ID
  Future<AuditLog?> getAuditLog(String id) async {
    try {
      _logger.i('Fetching audit log $id');

      final response = await _dio.get('$baseUrl/auditlog/get/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return AuditLog.fromJson(data['log']);
        }
      }
      return null;
    } on DioException catch (e) {
      _logger.e('Error fetching audit log', error: e);
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to fetch audit log: ${e.message}');
    }
  }

  /// Gets all audit logs
  Future<List<AuditLog>> getAllAuditLogs() async {
    try {
      _logger.i('Fetching all audit logs');

      final response = await _dio.get('$baseUrl/auditlog/get-all');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> logsJson = data['logs'];
          return logsJson
              .map((json) => AuditLog.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching all audit logs', error: e);
      throw Exception('Failed to fetch audit logs: ${e.message}');
    }
  }

  /// Gets audit logs by user ID
  Future<List<AuditLog>> getAuditLogsByUser(String userId) async {
    try {
      _logger.i('Fetching audit logs for user $userId');

      final response = await _dio.get('$baseUrl/auditlog/get-by-user/$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> logsJson = data['logs'];
          return logsJson
              .map((json) => AuditLog.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching user audit logs', error: e);
      throw Exception('Failed to fetch user audit logs: ${e.message}');
    }
  }

  /// Gets audit logs by entity
  Future<List<AuditLog>> getAuditLogsByEntity(
      String entityType, String entityId) async {
    try {
      _logger.i('Fetching audit logs for $entityType $entityId');

      final response = await _dio.get(
        '$baseUrl/auditlog/get-by-entity',
        queryParameters: {
          'entityType': entityType,
          'entityId': entityId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> logsJson = data['logs'];
          return logsJson
              .map((json) => AuditLog.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching entity audit logs', error: e);
      throw Exception('Failed to fetch entity audit logs: ${e.message}');
    }
  }

  /// Gets audit logs by action
  Future<List<AuditLog>> getAuditLogsByAction(String action) async {
    try {
      _logger.i('Fetching audit logs for action $action');

      final response =
          await _dio.get('$baseUrl/auditlog/get-by-action/$action');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> logsJson = data['logs'];
          return logsJson
              .map((json) => AuditLog.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching action audit logs', error: e);
      throw Exception('Failed to fetch action audit logs: ${e.message}');
    }
  }

  /// Gets audit logs by date range
  Future<List<AuditLog>> getAuditLogsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      _logger.i('Fetching audit logs from $startDate to $endDate');

      final response = await _dio.get(
        '$baseUrl/auditlog/get-by-date-range',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> logsJson = data['logs'];
          return logsJson
              .map((json) => AuditLog.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching audit logs by date range', error: e);
      throw Exception('Failed to fetch audit logs by date range: ${e.message}');
    }
  }

  /// Deletes an audit log
  Future<bool> deleteAuditLog(String id) async {
    try {
      _logger.i('Deleting audit log $id');

      final response = await _dio.delete('$baseUrl/auditlog/delete/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      _logger.e('Error deleting audit log', error: e);
      throw Exception('Failed to delete audit log: ${e.message}');
    }
  }

  /// Gets audit log count
  Future<int> getAuditLogCount() async {
    try {
      _logger.i('Fetching audit log count');

      final response = await _dio.get('$baseUrl/auditlog/count');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['count'] as int;
        }
      }
      return 0;
    } on DioException catch (e) {
      _logger.e('Error fetching audit log count', error: e);
      throw Exception('Failed to fetch audit log count: ${e.message}');
    }
  }

  /// Seeds audit logs for testing (admin only)
  Future<bool> seedAuditLogs({int count = 20}) async {
    try {
      _logger.i('Seeding $count audit logs');

      final response = await _dio.post(
        '$baseUrl/auditlog/seed',
        queryParameters: {'count': count},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      _logger.e('Error seeding audit logs', error: e);
      throw Exception('Failed to seed audit logs: ${e.message}');
    }
  }
}
