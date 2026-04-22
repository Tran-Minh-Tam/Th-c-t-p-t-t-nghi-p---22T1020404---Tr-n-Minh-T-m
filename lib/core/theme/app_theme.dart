import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00686D);
  static const Color primaryContainer = Color(0xFF0D8389);
  static const Color backgroundColor = Color(0xFFF6FAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color onSurfaceColor = Color(0xFF181C1D);
  static const Color secondaryColor = Color(0xFF436466);
  static const Color tertiaryColor = Color(0xFF8D4C20);
  static const Color outlineColor = Color(0xFFBDC9C9);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Colors.white,
      surface: backgroundColor,
      onSurface: onSurfaceColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      outline: outlineColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: onSurfaceColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurfaceColor,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurfaceColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        color: onSurfaceColor,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: outlineColor.withValues(alpha: 0.2), width: 1),
      ),
    ),
  );
}
