import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:loading_indicator/loading_indicator.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class Config {
  String apiKey = "8accedf111e59fb160ff3561c7c90e0e";
  String accessToken =
      "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4YWNjZWRmMTExZTU5ZmIxNjBmZjM1NjFjN2M5MGUwZSIsInN1YiI6IjYxYmE4ZDk3MjhkN2ZlMDA0M2VjZjgzNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Geq8PJdk6by2Xl5fG0SOicHJFvUlxHpg_-xif7kn47Y";
  String baseUrl = "https://api.themoviedb.org/3";
  String imageUrl = "https://image.tmdb.org/t/p/";
  String backdropSize = "w1280";
  String posterSize = "w780";
  String stillSize = "w300";
  String logoSize = "w154";
  Dio dio = Dio()
    ..interceptors.add(InterceptorsWrapper(onRequest: ((options, handler) {
      options.headers['accept'] = "application/json";
      options.headers['Authorization'] = "Bearer ${Config().accessToken}";
      return handler.next(options);
    })))
    ..interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));
  LoadingIndicator loadingIndicator = LoadingIndicator(
    indicatorType: Indicator.ballPulseSync,
    colors: [
      Colors.white.withAlpha(50),
      Colors.white.withAlpha(125),
      Colors.white
    ],
  );
}
