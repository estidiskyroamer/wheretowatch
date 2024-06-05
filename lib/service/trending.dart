import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:wheretowatch/common/config.dart';

class Trending {

  getTrendingMovies([int page = 1, String region = ""]) async {
    try {
      final response = await Config().dio.get(
          '${Config().baseUrl}/trending/movie/day',
          queryParameters: {'page': page, 'region': region});
      return response.data;
    } on DioException catch (e) {
      inspect(e.message);
    }
  }
}
