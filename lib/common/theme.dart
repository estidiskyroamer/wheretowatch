import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppThemes {
  static final lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: HexColor("#DFEBFD")),
      useMaterial3: true);
  static final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: HexColor("#092042")),
      useMaterial3: true);
}
