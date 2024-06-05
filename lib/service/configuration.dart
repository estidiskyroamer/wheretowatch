import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:wheretowatch/common/config.dart';

class Configuration {
  getImageConfig() async {
    try {
      final response = await Config().dio.get(
          '${Config().baseUrl}/configuration');
      return response.data;
    } on DioException catch (e) {
      inspect(e.message);
    }
  }
}
