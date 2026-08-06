import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_palette.dart';

class AppTextTheme {
  static TextTheme get(Color textColor) => TextTheme(
        displayLarge: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 32.0,
          letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 28.0,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 24.0,
        ),
        headlineLarge: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 32.0,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 20.0,
        ),
        titleLarge: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 22.0,
        ),
        titleMedium: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 16.0,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textColor,
          fontWeight: FontWeight.w400,
          fontSize: 16.0,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textColor,
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppPalette.textSecondary,
          fontWeight: FontWeight.w400,
          fontSize: 12.0,
        ),
        labelLarge: GoogleFonts.inter(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
          letterSpacing: 0.1,
        ),
      );
}
