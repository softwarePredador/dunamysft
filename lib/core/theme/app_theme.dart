import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// App Theme Definition
class AppTheme {
  // Primary colors from FlutterFlow
  static const Color primary = Color(0xFF4B39EF);
  static const Color secondary = Color(0xFF39D2C0);
  static const Color tertiary = Color(0xFFEE8B60);
  static const Color alternate = Color(0xFFE0E3E7);

  // Text colors
  static const Color primaryText = Color(0xFF4B3E3C);
  static const Color secondaryText = Color(0xFF57636C);

  // Background colors
  static const Color primaryBackground = Color(0xFFF1F4F8);
  static const Color secondaryBackground = Color(0xFFFFFFFF);

  // Accent colors
  static const Color accent1 = Color(0x4C4B39EF);
  static const Color accent2 = Color(0x4D39D2C0);
  static const Color accent3 = Color(0x4DEE8B60);
  static const Color accent4 = Color(0xCCFFFFFF);

  // Status colors
  static const Color success = Color(0xFF249689);
  static const Color warning = Color(0xFFF9CF58);
  static const Color error = Color(0xFFFF5963);
  static const Color info = Color(0xFFFFFFFF);

  // Order status colors - cores específicas para status de pedidos
  static const Color statusPending = Color(0xFFF9CF58); // Amarelo - Pendente
  static const Color statusPreparing = Color(0xFFFF9431); // Laranja - Preparando
  static const Color statusReady = Color(0xFF2196F3); // Azul - Pronto
  static const Color statusDelivered = Color(0xFF249689); // Verde - Entregue
  static const Color statusCancelled = Color(0xFFFF5963); // Vermelho - Cancelado

  // Stock status colors
  static const Color stockLow = Color(0xFFFF5963); // Vermelho - Baixo
  static const Color stockMedium = Color(0xFFFF9431); // Laranja - Médio
  static const Color stockOk = Color(0xFF249689); // Verde - OK

  // Social/Brand colors (podem ser hardcoded)
  static const Color whatsappGreen = Color(0xFF25D366);

  // Gradient colors for client navbar
  static const Color amareloGradientStart = Color(0xFFD0AA5E);
  static const Color amareloGradientEnd = Color(0xFFCD9A32);

  // Custom colors from FlutterFlow
  static const Color amarelo = Color(0xFFD0AA5E);
  static const Color disabled = Color(0xFFD9D9D9);

  // Admin specific colors - usar primaryText como cor de destaque
  static const Color adminAccent = Color(0xFF4B3E3C); // Mesmo que primaryText
  static const Color adminAccentLight = Color(0xFF6B5E5C); // Versão mais clara para hover
  static const Color secondaryColor1 = Color(0xFFFF3B30);
  static const Color primaryColors = Color(0xFFFF9431);
  static const Color grayPaletteGray10 = Color(0xFFFAFAFA);
  static const Color grayPaletteGray20 = Color(0xFFF5F5F5);
  static const Color grayPaletteGray30 = Color(0xFFEDEDED);
  static const Color grayPaletteGray60 = Color(0xFF9E9E9E);
  static const Color grayPaletteGray100 = Color(0xFF0A0A0A);
  static const Color bordaCinza = Color(0xFFCCCCCC);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: primaryBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        error: error,
        surface: secondaryBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: primaryText,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(color: primaryText, fontWeight: FontWeight.w600, fontSize: 64.0),
        displayMedium: GoogleFonts.poppins(color: primaryText, fontWeight: FontWeight.w600, fontSize: 44.0),
        displaySmall: GoogleFonts.poppins(color: primaryText, fontWeight: FontWeight.w600, fontSize: 36.0),
        headlineLarge: GoogleFonts.poppins(color: primaryText, fontWeight: FontWeight.w600, fontSize: 32.0),
        headlineMedium: GoogleFonts.poppins(color: primaryText, fontWeight: FontWeight.w600, fontSize: 28.0),
        headlineSmall: GoogleFonts.poppins(color: primaryText, fontWeight: FontWeight.w600, fontSize: 24.0),
        titleLarge: GoogleFonts.poppins(color: primaryText, fontWeight: FontWeight.w600, fontSize: 20.0),
        titleMedium: GoogleFonts.poppins(color: primaryText, fontWeight: FontWeight.w600, fontSize: 18.0),
        titleSmall: GoogleFonts.poppins(color: primaryText, fontWeight: FontWeight.w600, fontSize: 16.0),
        labelLarge: GoogleFonts.inter(color: secondaryText, fontWeight: FontWeight.normal, fontSize: 16.0),
        labelMedium: GoogleFonts.inter(color: secondaryText, fontWeight: FontWeight.normal, fontSize: 14.0),
        labelSmall: GoogleFonts.inter(color: secondaryText, fontWeight: FontWeight.normal, fontSize: 12.0),
        bodyLarge: GoogleFonts.inter(color: primaryText, fontWeight: FontWeight.normal, fontSize: 16.0),
        bodyMedium: GoogleFonts.inter(color: primaryText, fontWeight: FontWeight.normal, fontSize: 14.0),
        bodySmall: GoogleFonts.inter(color: primaryText, fontWeight: FontWeight.normal, fontSize: 12.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: bordaCinza),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: bordaCinza),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: GoogleFonts.inter(color: secondaryText, fontSize: 14),
      ),
      cardTheme: const CardThemeData(
        color: secondaryBackground,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryText,
        circularTrackColor: Colors.transparent,
      ),
    );
  }
}
