// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary     = Color(0xFF3B6DDB);
  static const Color primaryLight= Color(0xFF5B8BF5);
  static const Color background  = Color(0xFFF8F9FF);
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color border      = Color(0xFFE8ECFF);
  static const Color textDark    = Color(0xFF1A2040);
  static const Color textMid     = Color(0xFF3D4A6B);
  static const Color textMuted   = Color(0xFF8892B0);
  static const Color success     = Color(0xFF3B6D11);
  static const Color successBg   = Color(0xFFEAF3DE);
  static const Color warning     = Color(0xFF854F0B);
  static const Color warningBg   = Color(0xFFFFF3E0);
  static const Color danger      = Color(0xFFE24B4A);
  static const Color dangerBg    = Color(0xFFFEECEC);
  static const Color infoBg      = Color(0xFFEEF2FF);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        surface: surface,
        error: danger,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w600, color: textDark),
        headlineMedium: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        titleLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
        titleMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: textDark),
        bodyLarge: GoogleFonts.dmSans(fontSize: 14, color: textMid),
        bodyMedium: GoogleFonts.dmSans(fontSize: 13, color: textMuted),
        labelSmall: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: textMuted, letterSpacing: 0.8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
        iconTheme: const IconThemeData(color: textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF4F6FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: danger, width: 0.5),
        ),
        labelStyle: GoogleFonts.dmSans(color: textMuted, fontSize: 13),
        suffixStyle: GoogleFonts.dmSans(color: textMuted, fontSize: 12),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 0.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static Color riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'low': return success;
      case 'moderate': return warning;
      case 'high': return const Color(0xFFE07B39);
      case 'very high': return danger;
      default: return textMuted;
    }
  }

  static Color riskBg(String level) {
    switch (level.toLowerCase()) {
      case 'low': return successBg;
      case 'moderate': return warningBg;
      case 'high': return const Color(0xFFFFF0E8);
      case 'very high': return dangerBg;
      default: return background;
    }
  }
}
