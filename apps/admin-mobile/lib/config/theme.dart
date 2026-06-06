import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/colors.dart' as new_colors;

class AdminColors {
  static const background = Color(0xFF0B0B0F);
  static const surface = Color(0xFF1B1B22);
  static const surfaceElevated = Color(0xFF252530);
  static const border = Color(0xFF2E2E38);
  static const borderLight = Color(0xFF3A3A3E);
  static const primary = Color(0xFF00D4FF);
  static const primaryLight = Color(0xFF7C3AED);
  static const primaryDim = Color(0xFF00A3CC);
  static const textHigh = Color(0xFFFFFFFF);
  static const textMedium = Color(0xFFA1A1AA);
  static const textLow = Color(0xFF71717A);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF00D4FF);
  static const glassBase = Color(0x0DFFFFFF);
  static const glassHover = Color(0x1AFFFFFF);
}

class AdminTheme {
  static ThemeData get dark => AppTheme.dark;
}

final themeProvider = Provider<ThemeData>((_) => AppTheme.dark);
