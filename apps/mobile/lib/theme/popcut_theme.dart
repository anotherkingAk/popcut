import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PopCutColors {
  static const background = Color(0xFF0B0B0F);
  static const backgroundSecondary = Color(0xFF141419);
  static const surface = Color(0xFF1B1B22);
  static const surfaceHover = Color(0xFF252530);
  static const border = Color(0xFF2E2E38);
  static const primary = Color(0xFF00D4FF);
  static const secondary = Color(0xFF7C3AED);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA1A1AA);
  static const textMuted = Color(0xFF71717A);

  static Color glass({double opacity = 0.08}) =>
      const Color(0xFFFFFFFF).withValues(alpha: opacity);

  static Color glassBorder({double opacity = 0.12}) =>
      const Color(0xFFFFFFFF).withValues(alpha: opacity);

  static Color glassGlow({double opacity = 0.15}) =>
      const Color(0xFF00D4FF).withValues(alpha: opacity);

  static Color shimmerBase = const Color(0xFF1B1B22);
  static Color shimmerHighlight = const Color(0xFF252530);
}

class PopCutTypography {
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: PopCutColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: PopCutColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: PopCutColors.textPrimary,
  );

  static TextStyle get headline => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: PopCutColors.textPrimary,
  );

  static TextStyle get title => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: PopCutColors.textPrimary,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: PopCutColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: PopCutColors.textSecondary,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: PopCutColors.textMuted,
  );

  static TextStyle get captionBold => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: PopCutColors.textSecondary,
  );

  static TextStyle get button => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PopCutColors.textPrimary,
    letterSpacing: 0.3,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: PopCutColors.textMuted,
    letterSpacing: 0.5,
  );
}

class PopCutShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get glow => [
    BoxShadow(
      color: PopCutColors.primary.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 0),
    ),
    BoxShadow(
      color: PopCutColors.primary.withValues(alpha: 0.1),
      blurRadius: 40,
      offset: const Offset(0, 0),
    ),
  ];

  static List<BoxShadow> glowColor(Color color, {double intensity = 0.25}) => [
    BoxShadow(
      color: color.withValues(alpha: intensity),
      blurRadius: 20,
      offset: const Offset(0, 0),
    ),
    BoxShadow(
      color: color.withValues(alpha: intensity * 0.4),
      blurRadius: 40,
      offset: const Offset(0, 0),
    ),
  ];
}

class PopCutTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: PopCutColors.background,
      colorScheme: const ColorScheme.dark(
        primary: PopCutColors.primary,
        secondary: PopCutColors.secondary,
        surface: PopCutColors.surface,
        onPrimary: PopCutColors.background,
        onSecondary: PopCutColors.textPrimary,
        onSurface: PopCutColors.textPrimary,
        error: PopCutColors.error,
        onError: PopCutColors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: PopCutTypography.displayLarge,
        displayMedium: PopCutTypography.displayMedium,
        displaySmall: PopCutTypography.displaySmall,
        headlineMedium: PopCutTypography.headline,
        titleLarge: PopCutTypography.title,
        titleMedium: PopCutTypography.body,
        titleSmall: PopCutTypography.bodySmall,
        bodyLarge: PopCutTypography.body,
        bodyMedium: PopCutTypography.bodySmall,
        labelLarge: PopCutTypography.button,
        labelSmall: PopCutTypography.caption,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: PopCutColors.background,
        foregroundColor: PopCutColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: PopCutColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: PopCutColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: PopCutColors.border, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: PopCutColors.border,
        thickness: 0.5,
        space: 0,
      ),
      iconTheme: const IconThemeData(
        color: PopCutColors.textSecondary,
        size: 20,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: PopCutColors.backgroundSecondary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PopCutColors.surface,
        contentTextStyle: const TextStyle(
          fontSize: 13,
          color: PopCutColors.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: PopCutColors.backgroundSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PopCutColors.primary,
          foregroundColor: PopCutColors.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: PopCutTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PopCutColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PopCutColors.textPrimary,
          side: const BorderSide(color: PopCutColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PopCutColors.background,
        selectedItemColor: PopCutColors.primary,
        unselectedItemColor: PopCutColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PopCutColors.surface,
        hintStyle: PopCutTypography.bodySmall.copyWith(
          color: PopCutColors.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PopCutColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PopCutColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PopCutColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        activeTrackColor: PopCutColors.primary,
        inactiveTrackColor: PopCutColors.surfaceHover,
        thumbColor: PopCutColors.primary,
        overlayColor: PopCutColors.primary.withValues(alpha: 0.12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return PopCutColors.primary;
          return PopCutColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PopCutColors.primary.withValues(alpha: 0.3);
          }
          return PopCutColors.surfaceHover;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return PopCutColors.primary;
          return PopCutColors.surfaceHover;
        }),
        checkColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return PopCutColors.background;
          return PopCutColors.textMuted;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
