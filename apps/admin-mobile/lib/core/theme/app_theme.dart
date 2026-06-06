import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'typography.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AdminColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AdminColors.primary,
        secondary: AdminColors.secondary,
        surface: AdminColors.surface,
        onSurface: AdminColors.textPrimary,
        error: AdminColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelSmall: AppTypography.labelSmall,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AdminColors.background,
        foregroundColor: AdminColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: AdminColors.textPrimary),
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
      iconTheme: const IconThemeData(color: AdminColors.textSecondary, size: 20),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AdminColors.surface,
        contentTextStyle: const TextStyle(fontSize: 13, color: AdminColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AdminColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.primary,
          foregroundColor: AdminColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: AppTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AdminColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminColors.textPrimary,
          side: const BorderSide(color: AdminColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.surface,
        hintStyle: TextStyle(color: AdminColors.textMuted, fontSize: 14),
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
          return AdminColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AdminColors.primary.withValues(alpha: 0.3);
          return AdminColors.border;
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AdminColors.primary,
        foregroundColor: AdminColors.textPrimary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AdminColors.background,
        selectedItemColor: AdminColors.primary,
        unselectedItemColor: AdminColors.textMuted,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AdminColors.surface,
        selectedColor: AdminColors.primary.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: AdminColors.textSecondary, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: AdminColors.border),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AdminColors.primary,
        circularTrackColor: AdminColors.border,
      ),
    );
  }
}
