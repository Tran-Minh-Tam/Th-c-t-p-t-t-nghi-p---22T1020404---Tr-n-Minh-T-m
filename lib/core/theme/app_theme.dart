import 'package:flutter/material.dart';

class AppTheme {
  // Light Mode Colors
  static const Color primaryColor = Color(0xFF00696D);
  static const Color secondaryColor = Color(0xFF4A6364);
  static const Color tertiaryColor = Color(0xFF4B607C);
  static const Color backgroundColor = Color(0xFFFAFDFD);
  static const Color primaryContainer = Color(0xFF181C1D);

  // Dark Mode Colors
  static const Color primaryColorDark = Color(0xFF4DD9E0);
  static const Color secondaryColorDark = Color(0xFFB1CBCD);
  static const Color tertiaryColorDark = Color(0xFFB2C8E8);
  static const Color backgroundColorDark = Color(0xFF191C1C);
  static const Color primaryContainerDark = Color(0xFFE1E3E3);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColor,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: primaryContainer, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: primaryContainer),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColorDark,
    scaffoldBackgroundColor: backgroundColorDark,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColorDark,
      brightness: Brightness.dark,
      primary: primaryColorDark,
      secondary: secondaryColorDark,
      surface: backgroundColorDark,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: primaryContainerDark, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: primaryContainerDark),
    ),
  );
}

class ThemeManager {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  static void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
