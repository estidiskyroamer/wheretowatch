import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:wheretowatch/pages/search/search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Where To Watch',
      theme: ThemeData(
        primaryColor: HexColor("#092042"),
        textTheme: TextTheme(
          bodyLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: const TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
          bodySmall: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          labelLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white.withAlpha(100),
          ),
          labelMedium: TextStyle(
            fontSize: 16,
            color: Colors.white.withAlpha(100),
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            color: Colors.white.withAlpha(100),
          ),
        ),
      ),
      home: const SearchScreen(),
    );
  }
}
