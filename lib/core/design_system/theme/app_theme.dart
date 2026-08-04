import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
export 'design_tokens.dart';
import 'design_tokens.dart';

// Private Color Palette
class _Palette {
  static const Color primary = Color(0xFF6B4FA9);
  static const Color secondary = Color(0xFF64748B);
  static const Color accent = Color(0xFFF59E0B);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF3B82F6);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color disabled = Color(0xFF94A3B8);

  static const Color darkBackground = Color(0xFF020617);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkPrimary = Color(0xFFD0BCFF);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkError = Color(0xFFF87171);

  // Surface Containers
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);
  static const Color secondaryContainer = Color(0xFFE2E8F0);
  static const Color onSecondaryContainer = Color(0xFF1E293B);

  // Dark Containers
  static const Color darkPrimaryContainer = Color(0xFF4F378B);
  static const Color darkOnPrimaryContainer = Color(0xFFEADDFF);
  static const Color darkSecondaryContainer = Color(0xFF334155);
  static const Color darkOnSecondaryContainer = Color(0xFFF1F5F9);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        primaryColor: _Palette.primary,
        scaffoldBackgroundColor: _Palette.background,
        dividerColor: _Palette.divider,
        colorScheme: const ColorScheme.light(
          primary: _Palette.primary,
          onPrimary: Colors.white,
          primaryContainer: _Palette.primaryContainer,
          onPrimaryContainer: _Palette.onPrimaryContainer,
          secondary: _Palette.secondary,
          onSecondary: Colors.white,
          secondaryContainer: _Palette.secondaryContainer,
          onSecondaryContainer: _Palette.onSecondaryContainer,
          tertiary: _Palette.accent,
          onTertiary: Colors.white,
          surface: _Palette.surface,
          onSurface: _Palette.textPrimary,
          onSurfaceVariant: _Palette.textSecondary,
          surfaceContainer: _Palette.surfaceContainer,
          error: _Palette.error,
          onError: Colors.white,
          outline: _Palette.border,
          outlineVariant: _Palette.divider,
        ),
        textTheme: _textTheme(_Palette.textPrimary),
        appBarTheme: AppBarTheme(
          backgroundColor: _Palette.surface,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: _Palette.textPrimary, size: 24),
          titleTextStyle: GoogleFonts.poppins(
            color: _Palette.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          shape: const Border(
            bottom: BorderSide(color: _Palette.divider, width: 1),
          ),
        ),
        cardTheme: CardThemeData(
          color: _Palette.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _Palette.divider, width: 1),
          ),
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          headingTextStyle: GoogleFonts.inter(
            color: _Palette.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          dataTextStyle: GoogleFonts.inter(
            color: _Palette.textSecondary,
            fontSize: 14,
          ),
          dividerThickness: 1,
          horizontalMargin: 24,
          columnSpacing: 24,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: _Palette.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titleTextStyle: GoogleFonts.poppins(
            color: _Palette.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: GoogleFonts.inter(
            color: _Palette.textSecondary,
            fontSize: 16,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _Palette.darkSurface,
          contentTextStyle: GoogleFonts.inter(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: _Palette.surface,
          showDragHandle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: _Palette.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(0)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _Palette.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _Palette.primary,
            side: const BorderSide(color: _Palette.border),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _Palette.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _Palette.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _Palette.surface,
          indicatorColor: _Palette.primary.withValues(alpha: 0.1),
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        expansionTileTheme: ExpansionTileThemeData(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          tilePadding: const EdgeInsets.symmetric(horizontal: 24),
          iconColor: _Palette.primary,
          collapsedIconColor: _Palette.textSecondary,
          textColor: _Palette.primary,
          collapsedTextColor: _Palette.textPrimary,
          shape: const Border(),
          collapsedShape: const Border(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _Palette.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _Palette.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _Palette.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _Palette.error),
          ),
          labelStyle: GoogleFonts.inter(
            color: _Palette.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.inter(
            color: _Palette.disabled,
            fontSize: 14,
          ),
        ),
        extensions: [
          const DesignTokens(
            success: _Palette.success,
            warning: _Palette.warning,
            info: _Palette.info,
            error: _Palette.error,
            textPrimary: _Palette.textPrimary,
            textSecondary: _Palette.textSecondary,
          ),
        ],
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primaryColor: _Palette.darkPrimary,
        scaffoldBackgroundColor: _Palette.darkBackground,
        dividerColor: _Palette.darkSurface,
        colorScheme: const ColorScheme.dark(
          primary: _Palette.darkPrimary,
          onPrimary: Colors.white,
          primaryContainer: _Palette.darkPrimaryContainer,
          onPrimaryContainer: _Palette.darkOnPrimaryContainer,
          secondary: _Palette.secondary,
          onSecondary: Colors.white,
          secondaryContainer: _Palette.darkSecondaryContainer,
          onSecondaryContainer: _Palette.darkOnSecondaryContainer,
          tertiary: _Palette.accent,
          onTertiary: Colors.white,
          surface: _Palette.darkSurface,
          onSurface: _Palette.darkText,
          onSurfaceVariant: _Palette.darkTextSecondary,
          surfaceContainer: _Palette.darkCard,
          error: _Palette.darkError,
          onError: Colors.white,
          outline: _Palette.darkCard,
          outlineVariant: _Palette.darkSurface,
        ),
        textTheme: _textTheme(_Palette.darkText),
        appBarTheme: AppBarTheme(
          backgroundColor: _Palette.darkSurface,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: _Palette.darkText, size: 24),
          titleTextStyle: GoogleFonts.poppins(
            color: _Palette.darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          shape: const Border(
            bottom: BorderSide(color: _Palette.darkCard, width: 1),
          ),
        ),
        cardTheme: CardThemeData(
          color: _Palette.darkCard,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155), width: 1),
          ),
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
          headingTextStyle: GoogleFonts.inter(
            color: _Palette.darkText,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          dataTextStyle: GoogleFonts.inter(
            color: _Palette.darkText.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          dividerThickness: 1,
          horizontalMargin: 24,
          columnSpacing: 24,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: _Palette.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titleTextStyle: GoogleFonts.poppins(
            color: _Palette.darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: GoogleFonts.inter(
            color: _Palette.darkText.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _Palette.surface,
          contentTextStyle: GoogleFonts.inter(color: _Palette.textPrimary),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: _Palette.darkSurface,
          showDragHandle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _Palette.darkSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _Palette.darkCard),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _Palette.darkCard),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _Palette.darkPrimary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _Palette.error),
          ),
          labelStyle: GoogleFonts.inter(
            color: _Palette.darkText.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.inter(
            color: _Palette.disabled,
            fontSize: 14,
          ),
        ),
        extensions: [
          DesignTokens(
            success: const Color(0xFF4ADE80), // Brighter green for dark mode
            warning: const Color(0xFFFBBF24),
            info: const Color(0xFF60A5FA),
            error: const Color(0xFFF87171),
            textPrimary: _Palette.darkText,
            textSecondary: const Color(0xFF94A3B8),
          ),
        ],
      );

  static TextTheme _textTheme(Color textColor) => TextTheme(
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
          color: _Palette.textSecondary,
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

extension BuildContextThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  DesignTokens get tokens => theme.extension<DesignTokens>()!;

  // Color Shortcuts
  Color get primaryColor => colorScheme.primary;
  Color get secondaryColor => colorScheme.secondary;
  Color get errorColor => colorScheme.error;
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get onSurfaceVariantColor => colorScheme.onSurfaceVariant;

  // Semantic Shortcuts from Tokens
  Color get successColor => tokens.success;
  Color get warningColor => tokens.warning;
  Color get infoColor => tokens.info;
}
