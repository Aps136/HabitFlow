import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFE91E8C);
  static const Color primaryDark = Color(0xFFAD1457);
  static const Color accent = Color(0xFF9C27B0);
  static const Color accentLight = Color(0xFFCE93D8);
  static const Color background = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF252545);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0D0);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFFF5252);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? background : const Color(0xFFF5F0FF);
    final surf = isDark ? surface : Colors.white;
    final surfL = isDark ? surfaceLight : const Color(0xFFEDE7F6);
    final txtPrimary = isDark ? Colors.white : const Color(0xFF1A0A2E);
    final txtSecondary = isDark ? textSecondary : const Color(0xFF6B5B7B);

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        background: bg,
        onBackground: txtPrimary,
        surface: surf,
        onSurface: txtPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        brightness == Brightness.dark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surf,
        elevation: 0,
        iconTheme: IconThemeData(color: txtPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfL,
        labelStyle: TextStyle(color: txtSecondary),
        hintStyle: TextStyle(color: txtSecondary),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      cardColor: surf,
      dividerColor: surfL,
    );
  }
}