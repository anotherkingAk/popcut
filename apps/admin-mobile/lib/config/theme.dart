import 'package:flutter/material.dart';

class AdminColors {
  static const background = Color(0xFF0a0a0b);
  static const surface = Color(0xFF141416);
  static const surfaceElevated = Color(0xFF1c1c1f);
  static const border = Color(0xFF2a2a2e);
  static const borderLight = Color(0xFF3a3a3e);

  static const primary = Color(0xFF6366f1);
  static const primaryLight = Color(0xFF818cf8);
  static const primaryDim = Color(0xFF4338ca);

  static const textHigh = Color(0xFFFAFAFA);
  static const textMedium = Color(0xFFA1A1AA);
  static const textLow = Color(0xFF52525B);

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  static const glassBase = Color(0x0DFFFFFF);
  static const glassHover = Color(0x1AFFFFFF);
}

class AdminTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AdminColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AdminColors.primary,
        secondary: AdminColors.primaryLight,
        surface: AdminColors.surface,
        onSurface: AdminColors.textHigh,
        error: AdminColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AdminColors.background,
        foregroundColor: AdminColors.textHigh,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AdminColors.textHigh,
        ),
      ),
      cardTheme: CardThemeData(
        color: AdminColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AdminColors.border, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AdminColors.border,
        thickness: 0.5,
        space: 0,
      ),
      iconTheme: const IconThemeData(color: AdminColors.textMedium, size: 20),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AdminColors.surfaceElevated,
        contentTextStyle: const TextStyle(
          fontSize: 13,
          color: AdminColors.textHigh,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AdminColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.primary,
          foregroundColor: AdminColors.textHigh,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AdminColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminColors.textHigh,
          side: const BorderSide(color: AdminColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.surface,
        hintStyle: const TextStyle(color: AdminColors.textLow, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.error, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AdminColors.primary;
          return AdminColors.textLow;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AdminColors.primary.withValues(alpha: 0.3);
          }
          return AdminColors.border;
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AdminColors.primary,
        foregroundColor: AdminColors.textHigh,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AdminColors.background,
        selectedItemColor: AdminColors.primary,
        unselectedItemColor: AdminColors.textLow,
      ),
    );
  }
}
