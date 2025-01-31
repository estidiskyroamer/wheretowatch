import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:wheretowatch/common/config.dart';

class Search {

  getSearchMovie(String query, [int page = 1, String region = ""]) async {
    try {
      final response = await Config().dio.get(
          '${Config().baseUrl}/search/movie',
          queryParameters: {'query': query, 'page': page, 'region': region});
      return response.data;
    } on DioException catch (e) {
      inspect(e.message);
    }
  }

  getSearchTV(String query, [int page = 1, String region = ""]) async {
    try {
      final response = await Config().dio.get(
          '${Config().baseUrl}/search/tv',
          queryParameters: {'query': query, 'page': page, 'region': region});
      return response.data;
    } on DioException catch (e) {
      inspect(e.message);
    }
  }
}
