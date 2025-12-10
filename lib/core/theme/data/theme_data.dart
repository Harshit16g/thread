import 'package:flutter/material.dart';
import '../app_theme.dart';

class AppThemeData {
  static ThemeData getTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return _lightTheme;
      case AppTheme.dark:
        return _darkTheme;
      case AppTheme.halloween:
        return _halloweenTheme;
      case AppTheme.christmas:
        return _christmasTheme;
      case AppTheme.summer:
        return _summerTheme;
      case AppTheme.winter:
        return _winterTheme;
    }
  }

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.amber,
    scaffoldBackgroundColor: const Color(0xFF1C1C1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1C1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.amber,
      secondary: Colors.amberAccent,
      surface: Color(0xFF1C1C1E),
    ),
  );

  static final ThemeData _halloweenTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: const Color(0xFF120500), // Dark orange/brown
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF120500),
      foregroundColor: Colors.orange,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.orange,
      secondary: Colors.purple,
      surface: Color(0xFF120500),
    ),
  );

  static final ThemeData _christmasTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.red,
    scaffoldBackgroundColor: const Color(0xFFF0FFF0), // Mint cream
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.red,
      secondary: Colors.green,
      surface: Color(0xFFF0FFF0),
    ),
  );

  static final ThemeData _summerTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: const Color(0xFFFFF8E1), // Amber 50
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.orange,
      secondary: Colors.cyan,
      surface: Color(0xFFFFF8E1),
    ),
  );

  static final ThemeData _winterTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFFE3F2FD), // Blue 50
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.indigo,
      surface: Color(0xFFE3F2FD),
    ),
  );
}
