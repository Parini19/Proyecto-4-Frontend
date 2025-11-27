import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/report.dart';

class ReportsService {
  final Dio _dio;
  final Logger _logger = Logger();
  final String baseUrl = 'https://localhost:7238/api';

  ReportsService(this._dio);

  /// Generates a sales report
  Future<SalesReportData> getSalesReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.i('Generating sales report');

      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _dio.get(
        '$baseUrl/reports/sales',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          _logger.i('Sales report generated successfully');
          return SalesReportData.fromJson(data['report']);
        } else {
          throw Exception(data['message'] ?? 'Failed to generate sales report');
        }
      } else {
        throw Exception('Failed to generate sales report: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Error generating sales report', error: e);
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Failed to generate sales report');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error generating sales report', error: e);
      throw Exception('Failed to generate sales report: $e');
    }
  }

  /// Generates a movie popularity report
  Future<MoviePopularityReportData> getMoviePopularityReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.i('Generating movie popularity report');

      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _dio.get(
        '$baseUrl/reports/movie-popularity',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          _logger.i('Movie popularity report generated successfully');
          return MoviePopularityReportData.fromJson(data['report']);
        } else {
          throw Exception(data['message'] ?? 'Failed to generate movie popularity report');
        }
      } else {
        throw Exception('Failed to generate movie popularity report: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Error generating movie popularity report', error: e);
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Failed to generate movie popularity report');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error generating movie popularity report', error: e);
      throw Exception('Failed to generate movie popularity report: $e');
    }
  }

  /// Generates an occupancy report
  Future<OccupancyReportData> getOccupancyReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.i('Generating occupancy report');

      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _dio.get(
        '$baseUrl/reports/occupancy',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          _logger.i('Occupancy report generated successfully');
          return OccupancyReportData.fromJson(data['report']);
        } else {
          throw Exception(data['message'] ?? 'Failed to generate occupancy report');
        }
      } else {
        throw Exception('Failed to generate occupancy report: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Error generating occupancy report', error: e);
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Failed to generate occupancy report');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error generating occupancy report', error: e);
      throw Exception('Failed to generate occupancy report: $e');
    }
  }

  /// Generates a revenue report
  Future<RevenueReportData> getRevenueReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.i('Generating revenue report');

      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _dio.get(
        '$baseUrl/reports/revenue',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          _logger.i('Revenue report generated successfully');
          return RevenueReportData.fromJson(data['report']);
        } else {
          throw Exception(data['message'] ?? 'Failed to generate revenue report');
        }
      } else {
        throw Exception('Failed to generate revenue report: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Error generating revenue report', error: e);
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Failed to generate revenue report');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error generating revenue report', error: e);
      throw Exception('Failed to generate revenue report: $e');
    }
  }

  /// Gets dashboard summary
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      _logger.i('Fetching dashboard summary');

      final response = await _dio.get('$baseUrl/reports/dashboard-summary');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          _logger.i('Dashboard summary fetched successfully');
          return DashboardSummary.fromJson(data['summary']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch dashboard summary');
        }
      } else {
        throw Exception('Failed to fetch dashboard summary: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Error fetching dashboard summary', error: e);
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Failed to fetch dashboard summary');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error fetching dashboard summary', error: e);
      throw Exception('Failed to fetch dashboard summary: $e');
    }
  }
}
