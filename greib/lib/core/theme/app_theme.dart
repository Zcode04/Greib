import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_palette.dart';
import 'design_tokens.dart';

/// ============================================================================
///  AppTheme — ثيم التطبيق الموحّد
///  الهوية: Slate 900 + Sapphire (#3B82F6)
///
///  ★ يُبنى الآن من [AppColorPalette] المركزية، ويُسجّلها كـ ThemeExtension
///    ليقرأها أي مكوّن عبر `context.palette` / `Theme.of(context)`.
///    ⇒ تغيير أي لون عبر [ColorPaletteController] يسري فوراً على كل الثيم.
/// ============================================================================

class AppTheme {
  // =========================================================================
  //  LIGHT THEME
  // =========================================================================
  static ThemeData lightTheme([AppColorPalette? palette]) {
    final p = palette ?? AppColorPalette.light();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,
      extensions: [p],

      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary:            p.accent,                       // ★ اللون الرسمي (ديناميكي)
        onPrimary:          p.text.onAccent,
        primaryContainer:   AppColors.accentPrimaryContainer,
        onPrimaryContainer: AppColors.accentPrimaryDark,

        secondary:              AppColors.secondary,
        onSecondary:            Colors.white,
        secondaryContainer:     AppColors.neutral100,
        onSecondaryContainer:   p.text.secondary,

        tertiary:    AppColors.info,
        onTertiary:  Colors.white,

        error:   AppColors.error,
        onError: Colors.white,

        surface:             p.background.surface,
        onSurface:           p.text.primary,
        onSurfaceVariant:    p.text.secondary,
        outline:             p.background.outline,
        surfaceContainerHighest: p.background.surfaceElevated,
      ),

      scaffoldBackgroundColor: p.background.primary,


      appBarTheme: AppBarTheme(
        backgroundColor: p.background.surface,
        foregroundColor: p.text.primary,
        elevation: AppElevation.none,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: p.text.primary,
        ),
      ),

      cardTheme: CardThemeData(
        color: p.background.surface,
        elevation: AppElevation.sm,
        shadowColor: p.accent.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          side: BorderSide(color: p.background.outline, width: 0.5),
        ),
      ),

      textTheme: GoogleFonts.cairoTextTheme(
        TextTheme(
          displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5, color: p.text.primary),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.3, color: p.text.primary),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.2, color: p.text.primary),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4, color: p.text.primary),
          titleLarge:   TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4, color: p.text.primary),
          titleMedium:  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5, color: p.text.primary),
          bodyLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: p.text.primary),
          bodyMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: p.text.primary),
          bodySmall:    TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, color: p.text.secondary),
          labelLarge:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: p.text.primary),
          labelMedium:  TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4, color: p.text.primary),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.background.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: p.background.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: p.background.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: p.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        labelStyle: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: p.text.secondary),
        hintStyle:  TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: p.text.tertiary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.text.onAccent,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
          elevation: AppElevation.xs,
          shadowColor: p.accent.withValues(alpha: 0.4),
          textStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.accent,
          side: BorderSide(color: p.accent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
          textStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
      ),

      dividerTheme: DividerThemeData(color: p.background.outline, thickness: 1, space: 1),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.background.surfaceElevated,
        elevation: AppElevation.md,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        contentTextStyle: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: p.text.primary),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.background.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: p.background.surface,
        elevation: AppElevation.lg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xxl)),
        titleTextStyle: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 20, fontWeight: FontWeight.w700, color: p.text.primary),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.background.surface,
        elevation: AppElevation.sm,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: p.accent);
          }
          return TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: p.text.secondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: p.accent);
          }
          return IconThemeData(color: p.text.secondary);
        }),
      ),
    );
  }

  // =========================================================================
  //  DARK THEME
  // =========================================================================
  static ThemeData darkTheme([AppColorPalette? palette]) {
    final p = palette ?? AppColorPalette.dark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,
      extensions: [p],

      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary:            p.accent,                  // ★ اللون الرسمي (ديناميكي)
        onPrimary:          p.text.onAccent,
        primaryContainer:   AppColors.accentPrimaryContainerDark,
        onPrimaryContainer:  p.accent,

        secondary:              AppColors.secondary,
        onSecondary:            Colors.white,
        secondaryContainer:     p.background.surface,
        onSecondaryContainer:   p.text.secondary,

        tertiary:   AppColors.info,
        onTertiary: Colors.white,

        error:   AppColors.error,
        onError: Colors.black,

        surface:             p.background.surface,
        onSurface:           p.text.primary,
        onSurfaceVariant:    p.text.secondary,
        outline:             p.background.outline,
        surfaceContainerHighest: p.background.surfaceElevated,
      ),

      scaffoldBackgroundColor: p.background.primary,


      appBarTheme: AppBarTheme(
        backgroundColor: p.background.primary,
        foregroundColor: p.text.primary,
        elevation: AppElevation.none,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: p.text.primary,
        ),
      ),

      cardTheme: CardThemeData(
        color: p.background.surface,
        elevation: AppElevation.sm,
        shadowColor: p.accent.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          side: BorderSide(color: p.background.outline, width: 0.5),
        ),
      ),

      textTheme: GoogleFonts.cairoTextTheme(
        TextTheme(
          displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5, color: p.text.primary),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.3, color: p.text.primary),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.2, color: p.text.primary),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4, color: p.text.primary),
          titleLarge:   TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4, color: p.text.primary),
          titleMedium:  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5, color: p.text.primary),
          bodyLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: p.text.primary),
          bodyMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: p.text.primary),
          bodySmall:    TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, color: p.text.secondary),
          labelLarge:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: p.text.primary),
          labelMedium:  TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4, color: p.text.primary),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.background.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: p.background.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: p.background.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: p.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        labelStyle: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: p.text.secondary),
        hintStyle:  TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: p.text.tertiary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.text.onAccent,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
          elevation: AppElevation.xs,
          shadowColor: p.accent.withValues(alpha: 0.4),
          textStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.accent,
          side: BorderSide(color: p.accent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
          textStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
      ),

      dividerTheme: DividerThemeData(color: p.background.outline, thickness: 1, space: 1),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.background.surfaceElevated,
        elevation: AppElevation.md,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        contentTextStyle: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: p.text.primary),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.background.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: p.background.surface,
        elevation: AppElevation.lg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xxl)),
        titleTextStyle: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 20, fontWeight: FontWeight.w700, color: p.text.primary),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.background.surface,
        elevation: AppElevation.sm,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: p.accent);
          }
          return TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: p.text.secondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: p.accent);
          }
          return IconThemeData(color: p.text.secondary);
        }),
      ),
    );
  }
}