import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const bgBase = Color(0xFF000000);
  static const bgElevated = Color(0xFF0A0A0A);
  static const bgSurface = Color(0xFF111111);
  static const bgOverlay = Color(0xFF1A1A1A);

  // Brand (Monochrome)
  static const brand50 = Color(0xFFFFFFFF);
  static const brand100 = Color(0xFFF5F5F5);
  static const brand200 = Color(0xFFE0E0E0);
  static const brand300 = Color(0xFFCCCCCC);
  static const brand400 = Color(0xFFB8B8B8);
  static const brand500 = Color(0xFFFFFFFF);
  static const brand600 = Color(0xFFE0E0E0);
  static const brand700 = Color(0xFFCCCCCC);
  static const brand800 = Color(0xFFB8B8B8);
  static const brand900 = Color(0xFFA0A0A0);

  // Glass
  static const glassBase = Color(0x0DFFFFFF);
  static const glassHover = Color(0x1AFFFFFF);
  static const glassActive = Color(0x29FFFFFF);

  // Text
  static const textHigh = Color(0xFFFFFFFF);
  static const textMedium = Color(0xFFA0A0A0);
  static const textLow = Color(0xFF555555);
  static const textDisabled = Color(0xFF333333);

  // Semantic
  static const success = Color(0xFFFFFFFF);
  static const warning = Color(0xFFFFAA00);
  static const error = Color(0xFFFF3333);
  static const info = Color(0xFFFFFFFF);

  // Track colors (monochrome intensity)
  static const trackVideo = Color(0xFFFFFFFF);
  static const trackAudio = Color(0xFFAAAAAA);
  static const trackText = Color(0xFF888888);
  static const trackOverlay = Color(0xFF666666);
  static const trackEffect = Color(0xFF444444);
  static const trackGraphic = Color(0xFF555555);

  // Timeline
  static const timelineBg = Color(0xFF000000);
  static const timelineGrid = Color(0xFF1A1A1A);

  // Border
  static const border = Color(0xFF2A2A2A);
  static const borderLight = Color(0xFF3A3A3A);

  // Interactive states
  static const activeOverlay = Color(0xFF333333);
  static const selectedOverlay = Color(0xFF2A2A2A);
  static const hoverOverlay = Color(0xFF222222);

  // Legacy (migration compat)
  static const background = bgBase;
  static const surface = bgSurface;
  static const surfaceElevated = bgElevated;
  static const panelBg = bgElevated;
  static const card = bgBase;
  static const foreground = textHigh;
  static const foregroundSecondary = textMedium;
  static const foregroundMuted = textLow;
  static const primary = brand500;
  static const primaryForeground = Color(0xFF000000);
  static const secondary = Color(0xFF0A0A0A);
  static const secondaryForeground = Color(0xFFCCCCCC);
  static const secondaryBorder = Color(0xFF1A1A1A);
  static const accent = Color(0xFFFFFFFF);
  static const muted = Color(0xFF2A2A2A);
  static const destructive = error;
  static const constructive = success;
  static const caution = warning;
  static const playheadColor = textHigh;
  static const playheadGlow = Color(0xFFFFFFFF);
  static const snapColor = Color(0xFFFFFFFF);
  static const beatColor = Color(0xFFFFFFFF);
}

class AppTypography {
  // Display
  static const displayLg = TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1.0, color: AppColors.textHigh);
  static const displayMd = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.75, color: AppColors.textHigh);
  static const displaySm = TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: AppColors.textHigh);

  // Title
  static const titleLg = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textHigh);
  static const titleMd = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textHigh);
  static const titleSm = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textHigh);

  // Body
  static const bodyLg = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textHigh);
  static const bodyMd = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textMedium);
  static const bodySm = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4, color: AppColors.textLow);

  // Label
  static const label = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.textLow);

  // Code
  static const code = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'JetBrainsMono', color: AppColors.textHigh);

  // Getters for dynamic color
  static TextStyle displayLgWith(Color c) => displayLg.copyWith(color: c);
  static TextStyle titleLgWith(Color c) => titleLg.copyWith(color: c);
  static TextStyle bodyMdWith(Color c) => bodyMd.copyWith(color: c);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets card = EdgeInsets.all(lg);
  static const EdgeInsets panel = EdgeInsets.all(md);
}

class AppElevation {
  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 2;
  static const double level4 = 4;
  static const double level8 = 8;

  static List<BoxShadow> shadow(Color c, {double y = 2, double blur = 8, double alpha = 0.2}) {
    return [BoxShadow(color: c.withValues(alpha: alpha), blurRadius: blur, offset: Offset(0, y))];
  }

  static final List<BoxShadow> cardShadow = shadow(AppColors.bgOverlay, y: 2, blur: 8, alpha: 0.3);
  static final List<BoxShadow> elevatedShadow = shadow(AppColors.bgOverlay, y: 4, blur: 16, alpha: 0.4);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgBase,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brand500,
        secondary: AppColors.brand300,
        surface: AppColors.bgSurface,
        onSurface: AppColors.textHigh,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgSurface,
        foregroundColor: AppColors.textHigh,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.titleSm,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 0.5, space: 0),
      iconTheme: const IconThemeData(color: AppColors.textMedium, size: 18),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgOverlay,
        contentTextStyle: const TextStyle(fontSize: 13, color: AppColors.textHigh),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bgOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgOverlay,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand500,
          foregroundColor: AppColors.bgBase,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand500,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textHigh,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.brand500;
          return AppColors.textLow;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.brand500.withValues(alpha: 0.3);
          return AppColors.muted;
        }),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 2.5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        activeTrackColor: AppColors.brand500,
        inactiveTrackColor: AppColors.muted,
        thumbColor: AppColors.brand500,
        overlayColor: AppColors.brand500.withValues(alpha: 0.12),
      ),
    );
  }
}
