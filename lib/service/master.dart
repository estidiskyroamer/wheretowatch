import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class Master {
  final dio = Dio();
  /* ..interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    )); */
  String apiKey = "8accedf111e59fb160ff3561c7c90e0e";
  String accessToken =
      "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4YWNjZWRmMTExZTU5ZmIxNjBmZjM1NjFjN2M5MGUwZSIsInN1YiI6IjYxYmE4ZDk3MjhkN2ZlMDA0M2VjZjgzNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Geq8PJdk6by2Xl5fG0SOicHJFvUlxHpg_-xif7kn47Y";
  String baseUrl = "https://api.themoviedb.org/3";
  Options options = Options(headers: {
    Headers.acceptHeader: "application/json",
    'Authorization':
        "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4YWNjZWRmMTExZTU5ZmIxNjBmZjM1NjFjN2M5MGUwZSIsInN1YiI6IjYxYmE4ZDk3MjhkN2ZlMDA0M2VjZjgzNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Geq8PJdk6by2Xl5fG0SOicHJFvUlxHpg_-xif7kn47Y"
  });

  searchMovie(String query, [int page = 1, String region = ""]) async {
    try {
      final response = await dio.get('$baseUrl/search/movie',
          options: options,
          queryParameters: {'query': query, 'page': page, 'region': region});
      return response.data;
    } on DioException catch (e) {
      inspect(e.message);
    }
  }
}
