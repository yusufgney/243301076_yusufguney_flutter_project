import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF8FAFC);
  static const Color onSurface = Colors.black;
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF475569);
  static const Color outline = Color(0xFFCBD5E1);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);

  static const double spacingXs = 8;
  static const double spacingSm = 12;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2xl = 48;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      height: 1.1,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.25,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.35,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.35,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.55,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
    ),
  );

  static final ThemeData light = _buildLightTheme();
  static final ThemeData dark = _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          surface: surface,
          surfaceContainerLow: surfaceDim,
          surfaceContainerHighest: surfaceVariant,
          outline: outline,
        ).copyWith(
          primary: primary,
          onPrimary: Colors.white,
          secondary: const Color(0xFF7C3AED),
          onSecondary: Colors.white,
          onSurfaceVariant: onSurfaceVariant,
          onSurface: onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(bodyColor: onSurface, displayColor: onSurface),
      scaffoldBackgroundColor: surfaceDim,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: onSurface),
        iconTheme: const IconThemeData(color: onSurface, size: 22),
        shadowColor: outline.withValues(alpha: 0.4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(color: onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 22);
          }
          return const IconThemeData(color: onSurfaceVariant, size: 22);
        }),
        elevation: 0,
        shadowColor: outline.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        height: 68,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
        hintStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMd),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMd),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: outline),
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMd),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: borderRadiusSm),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusLg,
          side: const BorderSide(color: outline, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 0.8,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primary.withValues(alpha: 0.12),
        side: const BorderSide(color: outline, width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: borderRadiusSm),
        labelStyle: textTheme.labelMedium?.copyWith(color: onSurface),
        padding: const EdgeInsets.symmetric(horizontal: spacingXs, vertical: 4),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: surface,
        shape: RoundedRectangleBorder(borderRadius: borderRadiusMd),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingXs,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: surfaceVariant,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: borderRadiusMd),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    const dSurface = Color(0xFF1C1C1E);
    const dSurfaceDim = Color(0xFF000000);
    const dSurfaceVariant = Color(0xFF2C2C2E);
    const dOnSurface = Colors.white;
    const dOnSurfaceVariant = Color(0xFFAEAEB2);
    const dOutline = Color(0xFF38383A);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          surface: dSurface,
          surfaceContainerLow: dSurfaceDim,
          surfaceContainerHighest: dSurfaceVariant,
          outline: dOutline,
        ).copyWith(
          primary: const Color(0xFF3478F6),
          onPrimary: Colors.white,
          secondary: const Color(0xFF7C3AED),
          onSecondary: Colors.white,
          onSurfaceVariant: dOnSurfaceVariant,
          onSurface: dOnSurface,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: dOnSurface,
        displayColor: dOnSurface,
      ),
      scaffoldBackgroundColor: dSurfaceDim,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: dSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: dOnSurface),
        iconTheme: const IconThemeData(color: dOnSurface, size: 22),
        shadowColor: dOutline.withValues(alpha: 0.4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dSurface,
        indicatorColor: primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(color: dOnSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 22);
          }
          return const IconThemeData(color: dOnSurfaceVariant, size: 22);
        }),
        elevation: 0,
        shadowColor: dOutline.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        height: 68,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMd),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMd),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: dOutline),
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMd),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dSurface,
        border: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: const BorderSide(color: dOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: const BorderSide(color: dOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: dOnSurfaceVariant),
        hintStyle: textTheme.bodyMedium?.copyWith(color: dOnSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: dSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusLg,
          side: const BorderSide(color: dOutline, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: dOutline,
        thickness: 0.8,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dSurfaceVariant,
        selectedColor: primary.withValues(alpha: 0.2),
        side: const BorderSide(color: dOutline, width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: borderRadiusSm),
        labelStyle: textTheme.labelMedium?.copyWith(color: dOnSurface),
        padding: const EdgeInsets.symmetric(horizontal: spacingXs, vertical: 4),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: dSurface,
        textColor: dOnSurface,
        iconColor: dOnSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: borderRadiusMd),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingXs,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: dSurfaceVariant,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dOnSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: dSurface),
        shape: RoundedRectangleBorder(borderRadius: borderRadiusMd),
      ),
    );
  }
}
