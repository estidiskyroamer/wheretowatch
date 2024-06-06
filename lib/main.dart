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
    if (!Prefs().preferences.containsKey("region")) {
      Prefs().preferences.setString("region", "US");
      Prefs().preferences.setString("region_name", "United States of America");
    }
    return MaterialApp(
      title: 'Where To Watch',
      theme: ThemeData(
        colorSchemeSeed: HexColor("#092042"),
        textTheme: TextTheme(
          titleLarge: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.0,
          ),
          titleMedium: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.0,
          ),
          titleSmall: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.0,
          ),
          bodyLarge: const TextStyle(
            fontSize: 28,
            color: Colors.white,
          ),
          bodyMedium: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          bodySmall: const TextStyle(
            fontSize: 12,
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
