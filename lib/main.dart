import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:wheretowatch/common/shared_preferences.dart';
import 'package:wheretowatch/pages/search/search.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs().init();
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
        indicatorColor: HexColor("#8896ab"),
        textTheme: TextTheme(
          titleLarge: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.0,
          ),
          titleMedium: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.0,
          ),
          titleSmall: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.0,
          ),
          bodyLarge: const TextStyle(
            fontSize: 32,
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
