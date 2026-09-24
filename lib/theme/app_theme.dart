import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFFFFCF8);
  static const Color brown = Color(0xFF5C4033);
  static const Color lightBrown = Color(0xFFE8D8C8);
  static const Color darkText = Color(0xFF2D2521);
  static const Color grayText = Color(0xFF8A817C);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: brown,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: false,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkText,
      ),

      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: darkText,
      ),

      bodyLarge: TextStyle(
        fontSize: 16,
        color: darkText,
      ),

      bodyMedium: TextStyle(
        fontSize: 14,
        color: grayText,
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,

      indicatorColor: lightBrown,

      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}