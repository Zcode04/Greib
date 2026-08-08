import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

/// ============================================================================
///  AppTheme — ثيم التطبيق الموحّد
///  الهوية: Deep Space Black + Electric Violet
///  يعتمد حصرياً على AppColors من design_tokens.dart
/// ============================================================================

class AppTheme {
  // =========================================================================
  //  LIGHT THEME
  // =========================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,

      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary:            AppColors.accentPrimary,      // Violet 600
        onPrimary:          Colors.white,
        primaryContainer:   Color(0xFFEDE9FE),            // Violet 100
        onPrimaryContainer: AppColors.accentPrimaryDark,

        secondary:              AppColors.secondary,
        onSecondary:            Colors.white,
        secondaryContainer:     Color(0xFFF4F4F5),
        onSecondaryContainer:   AppColors.lightTextSecondary,

        tertiary:    AppColors.info,
        onTertiary:  Colors.white,

        error:   AppColors.error,
        onError: Colors.white,

        surface:             AppColors.lightSurface,
        onSurface:           AppColors.lightText,
        onSurfaceVariant:    AppColors.lightTextSecondary,
        outline:             AppColors.lightOutline,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
      ),

      scaffoldBackgroundColor: AppColors.lightBackground,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightText,
        elevation: AppElevation.none,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: AppElevation.sm,
        shadowColor: AppColors.accentPrimary.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          side: const BorderSide(color: AppColors.lightOutline, width: 0.5),
        ),
      ),

      textTheme: GoogleFonts.cairoTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5, color: AppColors.lightText),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.3, color: AppColors.lightText),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.2, color: AppColors.lightText),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.lightText),
          titleLarge:   TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.lightText),
          titleMedium:  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5, color: AppColors.lightText),
          bodyLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.lightText),
          bodyMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.lightText),
          bodySmall:    TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.lightTextSecondary),
          labelLarge:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: AppColors.lightText),
          labelMedium:  TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4, color: AppColors.lightText),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.accentPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        labelStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: AppColors.lightTextSecondary),
        hintStyle:  const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: AppColors.lightTextTertiary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
          elevation: AppElevation.xs,
          shadowColor: AppColors.accentGlow.withValues(alpha: 0.4),
          textStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          side: const BorderSide(color: AppColors.accentPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
          textStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          textStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.lightOutline, thickness: 1, space: 1),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral900,
        elevation: AppElevation.md,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        contentTextStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: Colors.white),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: AppElevation.lg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xxl)),
        titleTextStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.lightText),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: AppElevation.sm,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentPrimary);
          }
          return const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.lightTextSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentPrimary);
          }
          return const IconThemeData(color: AppColors.lightTextSecondary);
        }),
      ),
    );
  }

  // =========================================================================
  //  DARK THEME
  // =========================================================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary:            AppColors.accentPrimary,      // Violet 600
        onPrimary:          Colors.white,
        primaryContainer:   AppColors.accentPrimaryDark,  // Violet 900
        onPrimaryContainer: AppColors.accentPrimaryLight, // Violet 400

        secondary:              AppColors.secondary,
        onSecondary:            Colors.white,
        secondaryContainer:     AppColors.surfaceCard,
        onSecondaryContainer:   AppColors.textSecondary,

        tertiary:   AppColors.info,
        onTertiary: Colors.white,

        error:   AppColors.error,
        onError: Colors.black,

        surface:             AppColors.surfaceCard,
        onSurface:           AppColors.textPrimary,
        onSurfaceVariant:    AppColors.textSecondary,
        outline:             AppColors.outline,
        surfaceContainerHighest: AppColors.surfaceOverlay,
      ),

      scaffoldBackgroundColor: AppColors.backgroundPrimary,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: AppElevation.none,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: AppElevation.sm,
        shadowColor: AppColors.accentPrimary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          side: const BorderSide(color: AppColors.outline, width: 0.5),
        ),
      ),

      textTheme: GoogleFonts.cairoTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5, color: AppColors.textPrimary),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.3, color: AppColors.textPrimary),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.2, color: AppColors.textPrimary),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.textPrimary),
          titleLarge:   TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.textPrimary),
          titleMedium:  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5, color: AppColors.textPrimary),
          bodyLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textPrimary),
          bodyMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textPrimary),
          bodySmall:    TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textSecondary),
          labelLarge:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: AppColors.textPrimary),
          labelMedium:  TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4, color: AppColors.textPrimary),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceOverlay,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.accentPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        labelStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: AppColors.textSecondary),
        hintStyle:  const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: AppColors.textTertiary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
          elevation: AppElevation.xs,
          shadowColor: AppColors.accentGlow.withValues(alpha: 0.4),
          textStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          side: const BorderSide(color: AppColors.accentPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
          textStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          textStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.outline, thickness: 1, space: 1),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceCardElevated,
        elevation: AppElevation.md,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        contentTextStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: AppColors.textPrimary),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceCard,
        elevation: AppElevation.lg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xxl)),
        titleTextStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceCard,
        elevation: AppElevation.sm,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentPrimary);
          }
          return const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentPrimary);
          }
          return const IconThemeData(color: AppColors.textSecondary);
        }),
      ),
    );
  }
}