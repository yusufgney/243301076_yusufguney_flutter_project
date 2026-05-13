import 'package:flutter/material.dart';

/// Tüm uygulamanın tasarım sistemini barındıran sınıf.
class AppTheme {
  // ─── Renk Paleti (Sabitler) ────────────────────────────────────────────────
  // Sadece bu dosyada kullanılacak özel renkleri tanımlıyoruz.
  // Uygulamanın geri kalanında `Theme.of(context).colorScheme...` kullanılacak.
  
  static const Color _primarySeed = Color(0xFF6366F1); // Modern bir Indigo/Mor

  // Light Mode Renkleri
  static const Color _lightBackground = Color(0xFFF9FAFB);
  static const Color _lightSurface = Colors.white;
  static const Color _lightText = Color(0xFF1A1A1A);
  static const Color _lightTextSecondary = Color(0xFF4B5563);
  static const Color _lightOutline = Color(0xFFE5E7EB);

  // Dark Mode Renkleri (AMOLED Dostu)
  static const Color _darkBackground = Color(0xFF000000); // Tam siyah
  static const Color _darkSurface = Color(0xFF121212); // Element arkaplanı
  static const Color _darkText = Color(0xFFFFFFFF); // Tam beyaz
  static const Color _darkTextSecondary = Color(0xFFA1A1AA);
  static const Color _darkOutline = Color(0xFF27272A);

  // ─── Tipografi ─────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color textColor, Color secondaryTextColor) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textColor),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textColor),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textColor),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: secondaryTextColor),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
    );
  }

  // ─── Ortak Stil Değişkenleri ───────────────────────────────────────────────
  static final BorderRadius _borderRadius = BorderRadius.circular(12);

  // ─── LIGHT THEME ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.light,
      surface: _lightBackground,
      onSurface: _lightText,
      surfaceContainerHighest: _lightSurface, // Kart benzeri yapılar için
      outline: _lightOutline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      textTheme: _buildTextTheme(_lightText, _lightTextSecondary),
      
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightText,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
      ),
      
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: _borderRadius,
          side: const BorderSide(color: _lightOutline),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        border: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: const BorderSide(color: _lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: const BorderSide(color: _lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: _lightTextSecondary),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: _lightTextSecondary,
      ),
      
      drawerTheme: const DrawerThemeData(
        backgroundColor: _lightBackground,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  // ─── DARK THEME ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.dark,
      surface: _darkBackground, // AMOLED siyahı
      onSurface: _darkText,
      surfaceContainerHighest: _darkSurface,
      outline: _darkOutline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground, // AMOLED siyahı
      textTheme: _buildTextTheme(_darkText, _darkTextSecondary),
      
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBackground, // AMOLED siyahı
        foregroundColor: _darkText,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
      ),
      
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: _borderRadius,
          side: const BorderSide(color: _darkOutline),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: const BorderSide(color: _darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: const BorderSide(color: _darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: _darkTextSecondary),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: _darkTextSecondary,
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: _darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
