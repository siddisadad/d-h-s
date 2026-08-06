import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
export 'design_tokens.dart';
import 'design_tokens.dart';
import 'app_palette.dart';
import 'app_text_theme.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        primaryColor: AppPalette.primary,
        scaffoldBackgroundColor: AppPalette.background,
        dividerColor: AppPalette.divider,
        colorScheme: const ColorScheme.light(
          primary: AppPalette.primary,
          onPrimary: Colors.white,
          primaryContainer: AppPalette.primaryContainer,
          onPrimaryContainer: AppPalette.onPrimaryContainer,
          secondary: AppPalette.secondary,
          onSecondary: Colors.white,
          secondaryContainer: AppPalette.secondaryContainer,
          onSecondaryContainer: AppPalette.onSecondaryContainer,
          tertiary: AppPalette.accent,
          onTertiary: Colors.white,
          surface: AppPalette.surface,
          onSurface: AppPalette.textPrimary,
          onSurfaceVariant: AppPalette.textSecondary,
          surfaceContainer: AppPalette.surfaceContainer,
          error: AppPalette.error,
          onError: Colors.white,
          outline: AppPalette.border,
          outlineVariant: AppPalette.divider,
        ),
        textTheme: AppTextTheme.get(AppPalette.textPrimary),
        appBarTheme: AppBarTheme(
          backgroundColor: AppPalette.surface,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: AppPalette.textPrimary, size: 24),
          titleTextStyle: GoogleFonts.poppins(
            color: AppPalette.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          shape: const Border(
            bottom: BorderSide(color: AppPalette.divider, width: 1),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppPalette.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppPalette.divider, width: 1),
          ),
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          headingTextStyle: GoogleFonts.inter(
            color: AppPalette.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
          dataTextStyle: GoogleFonts.inter(
            color: AppPalette.textSecondary,
            fontSize: 14,
          ),
          dividerThickness: 1,
          horizontalMargin: 20,
          columnSpacing: 20,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppPalette.surface,
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titleTextStyle: GoogleFonts.poppins(
            color: AppPalette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: GoogleFonts.inter(
            color: AppPalette.textSecondary,
            fontSize: 15,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppPalette.textPrimary,
          contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppPalette.surface,
          showDragHandle: true,
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppPalette.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(0)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPalette.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: AppPalette.primary.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: 0.2),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppPalette.textPrimary,
            side: const BorderSide(color: AppPalette.border, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppPalette.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppPalette.surface,
          elevation: 0,
          indicatorColor: AppPalette.primary.withValues(alpha: 0.1),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppPalette.primary);
            }
            return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppPalette.textSecondary);
          }),
        ),
        expansionTileTheme: ExpansionTileThemeData(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20),
          iconColor: AppPalette.primary,
          collapsedIconColor: AppPalette.textSecondary,
          textColor: AppPalette.primary,
          collapsedTextColor: AppPalette.textPrimary,
          shape: const Border(),
          collapsedShape: const Border(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppPalette.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppPalette.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppPalette.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppPalette.error, width: 1),
          ),
          labelStyle: GoogleFonts.inter(
            color: AppPalette.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.inter(
            color: AppPalette.disabled,
            fontSize: 14,
          ),
        ),
        extensions: [
          const DesignTokens(
            success: AppPalette.success,
            warning: AppPalette.warning,
            info: AppPalette.info,
            error: AppPalette.error,
            textPrimary: AppPalette.textPrimary,
            textSecondary: AppPalette.textSecondary,
          ),
        ],
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primaryColor: AppPalette.darkPrimary,
        scaffoldBackgroundColor: AppPalette.darkBackground,
        dividerColor: AppPalette.darkSurface,
        colorScheme: const ColorScheme.dark(
          primary: AppPalette.darkPrimary,
          onPrimary: Colors.white,
          primaryContainer: AppPalette.darkPrimaryContainer,
          onPrimaryContainer: AppPalette.darkOnPrimaryContainer,
          secondary: AppPalette.secondary,
          onSecondary: Colors.white,
          secondaryContainer: AppPalette.darkSecondaryContainer,
          onSecondaryContainer: AppPalette.darkOnSecondaryContainer,
          tertiary: AppPalette.accent,
          onTertiary: Colors.white,
          surface: AppPalette.darkSurface,
          onSurface: AppPalette.darkText,
          onSurfaceVariant: AppPalette.darkTextSecondary,
          surfaceContainer: AppPalette.darkCard,
          error: AppPalette.darkError,
          onError: Colors.white,
          outline: AppPalette.darkCard,
          outlineVariant: AppPalette.darkSurface,
        ),
        textTheme: AppTextTheme.get(AppPalette.darkText),
        appBarTheme: AppBarTheme(
          backgroundColor: AppPalette.darkSurface,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: AppPalette.darkText, size: 24),
          titleTextStyle: GoogleFonts.poppins(
            color: AppPalette.darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          shape: const Border(
            bottom: BorderSide(color: AppPalette.darkCard, width: 1),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppPalette.darkCard,
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
            color: AppPalette.darkText,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          dataTextStyle: GoogleFonts.inter(
            color: AppPalette.darkText.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          dividerThickness: 1,
          horizontalMargin: 24,
          columnSpacing: 24,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppPalette.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titleTextStyle: GoogleFonts.poppins(
            color: AppPalette.darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: GoogleFonts.inter(
            color: AppPalette.darkText.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppPalette.surface,
          contentTextStyle: GoogleFonts.inter(color: AppPalette.textPrimary),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppPalette.darkSurface,
          showDragHandle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppPalette.darkSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppPalette.darkCard),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppPalette.darkCard),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppPalette.darkPrimary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppPalette.error),
          ),
          labelStyle: GoogleFonts.inter(
            color: AppPalette.darkText.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.inter(
            color: AppPalette.disabled,
            fontSize: 14,
          ),
        ),
        extensions: [
          DesignTokens(
            success: const Color(0xFF4ADE80),
            warning: const Color(0xFFFBBF24),
            info: const Color(0xFF60A5FA),
            error: const Color(0xFFF87171),
            textPrimary: AppPalette.darkText,
            textSecondary: const Color(0xFF94A3B8),
          ),
        ],
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
