import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:wheretowatch/common/config.dart';

class TV {

  getTVDetail(int id, [String language = ""]) async {
    try {
      final response = await Config().dio.get(
          '${Config().baseUrl}/tv/$id',
          queryParameters: {'language': language, 'append_to_response': "watch/providers,releases,credits"});
      return response.data;
    } on DioException catch (e) {
      inspect(e.message);
    }
  }

  
  getSeasonDetail(int id, int seasonNo) async {
    try {
      final response = await Config().dio.get(
          '${Config().baseUrl}/tv/$id/season/$seasonNo');
      return response.data;
    } on DioException catch (e) {
      inspect(e.message);
    }
  }
}
