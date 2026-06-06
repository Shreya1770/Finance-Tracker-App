import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevent instantiation

  // ── Backgrounds ──────────────────────────────
  static const Color bg           = Color(0xFF0A0E1A);
  static const Color surface      = Color(0xFF0F1330);
  static const Color cardBg       = Color(0xFF141830);
  static const Color inputBg      = Color(0x0FFFFFFF); // ~6% white
  static const Color border       = Color(0x1AFFFFFF); // ~10% white
  static const Color divider      = Color(0x0AFFFFFF); // ~4% white

  // ── Accent ───────────────────────────────────
  static const Color primary      = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFFa89cff);
  static const Color primaryMuted = Color(0x266C63FF); // 15% opacity
  static const Color secondary    = Color(0xFF4FD1C5);

  // ── Semantic ─────────────────────────────────
  static const Color income       = Color(0xFF68D391);
  static const Color incomeBg     = Color(0x2668D391); // 15% opacity
  static const Color expense      = Color(0xFFFC8181);
  static const Color expenseBg    = Color(0x26FC8181); // 15% opacity
  static const Color warning      = Color(0xFFF6AD55);
  static const Color warningBg    = Color(0x26F6AD55); // 15% opacity
  static const Color danger       = Color(0xFFF56565);

  // ── Text ─────────────────────────────────────
  static const Color textPrimary     = Color(0xFFFFFFFF);
  static const Color textSecondary   = Color(0xBFFFFFFF); // 75%
  static const Color textMuted       = Color(0x73FFFFFF); // 45%
  static const Color textPlaceholder = Color(0x40FFFFFF); // 25%
  static const Color textDisabled    = Color(0x26FFFFFF); // 15%

  // ── Gradient ─────────────────────────────────
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF4FD1C5)],
    stops: [0.0, 1.0],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary:   AppColors.primary,
      secondary: AppColors.secondary,
      surface:   AppColors.surface,
      error:     AppColors.danger,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: AppColors.inputBg,

  contentPadding: const EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
  ),

  hintStyle: const TextStyle(
    color: AppColors.textPlaceholder,
    fontSize: 16,
  ),

  labelStyle: const TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16,
  ),

  floatingLabelStyle: const TextStyle(
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  ),

  prefixIconColor: AppColors.textSecondary,
  suffixIconColor: AppColors.textSecondary,

  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(
      color: AppColors.border,
    ),
  ),

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(
      color: AppColors.border,
      width: 1,
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(
      color: AppColors.primary,
      width: 2,
    ),
  ),

  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(
      color: AppColors.danger,
      width: 1.5,
    ),
  ),

  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(
      color: AppColors.danger,
      width: 2,
    ),
  ),
),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    dividerColor: AppColors.divider,
    fontFamily: 'DM Sans',
  );
}
