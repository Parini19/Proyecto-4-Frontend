import 'package:dio/dio.dart';
import 'config.dart';

class ApiClient {
  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ));

  final Dio _dio;

  Future<Map<String, dynamic>> health() async {
    final res = await _dio.get('/health');
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<MovieDto>> getMovies() async {
    final res = await _dio.get('/api/movies');
    final data = res.data as List;
    return data.map((e) => MovieDto.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}

class MovieDto {
  final String id;
  final String title;
  final int year;
  MovieDto({required this.id, required this.title, required this.year});
  factory MovieDto.fromJson(Map<String, dynamic> json) =>
      MovieDto(id: json['id'] ?? '', title: json['title'] ?? '', year: (json['year'] ?? 0) as int);
}
