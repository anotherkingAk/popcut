import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextStyle get displayLarge => GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2);
  static TextStyle get displayMedium => GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25);
  static TextStyle get displaySmall => GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle get headlineLarge => GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle get headlineMedium => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, height: 1.35);
  static TextStyle get headlineSmall => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get titleLarge => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get titleMedium => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.45);
  static TextStyle get titleSmall => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, height: 1.45);
  static TextStyle get bodyLarge => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodyMedium => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySmall => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get labelLarge => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: 0.5);
  static TextStyle get labelSmall => GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: 0.5);
  static TextStyle get caption => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, height: 1.4);
  static TextStyle get overline => GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: 1.0);
  static TextStyle get button => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get buttonSmall => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get mono => GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get statValue => GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, height: 1.1);
  static TextStyle get statLabel => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4);
}
