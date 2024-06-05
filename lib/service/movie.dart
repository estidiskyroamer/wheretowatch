import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:wheretowatch/common/config.dart';

class Movie {

  getMovieDetail(int id, [String language = ""]) async {
    try {
      final response = await Config().dio.get(
          '${Config().baseUrl}/movie/$id',
          queryParameters: {'language': language, 'append_to_response': "watch/providers"});
      return response.data;
    } on DioException catch (e) {
      inspect(e.message);
    }
  }
}
