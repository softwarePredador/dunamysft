import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryText = Color(0xFF4B3E3C);
  static const Color secondaryText = Color(0xFF57636C);
  static const Color primaryBackground = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFFFFFFF);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: primaryBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryText,
        background: primaryBackground,
        surface: secondaryBackground,
        onSurface: primaryText,
        onBackground: primaryText,
      ),
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'Poppins',
        bodyColor: primaryText,
        displayColor: primaryText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryText,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
