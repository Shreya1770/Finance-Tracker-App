import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevent instantiation

  // ── Backgrounds ──────────────────────────────
  static const Color bg           = Color(0xFF0A0E1A);
  static const Color surface      = Color(0xFF0F1330);
  static const Color cardBg       = Color(0xFF141830);
  static const Color inputBg = Color(0x1AFFFFFF);
  static const Color border       = Color(0x1AFFFFFF); // ~10% white
  static const Color divider      = Color(0x0AFFFFFF); // ~4% white

  // ── Dialog / Sheet / Overlay ─────────────────
  static const Color dialogBg      = Color(0xFF161B38);
  static const Color sheetBg       = Color(0xFF10142C);
  static const Color scrimColor    = Color(0xB3000000); // 70% black overlay
  static const Color snackBarBg    = Color(0xFF1C2140);
  static const Color tooltipBg     = Color(0xFF1F2445);

  // ── Nav / AppBar / Home screen chrome ────────
  static const Color appBarBg      = Color(0xFF0A0E1A);
  static const Color navBarBg      = Color(0xFF0F1330);
  static const Color navBarSelected   = Color(0xFF6C63FF);
  static const Color navBarUnselected = Color(0x73FFFFFF); // 45%
  static const Color fabBg         = Color(0xFF6C63FF);
  static const Color chipBg        = Color(0x1AFFFFFF);
  static const Color chipSelectedBg = Color(0x266C63FF);

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

    // ── Card ────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // ── AppBar (home screen top bar) ────────────
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.appBarBg,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        fontFamily: 'DM Sans',
      ),
    ),

    // ── Bottom navigation (home screen tabs) ────
    navigationBarTheme: NavigationBarThemeData(
  backgroundColor: AppColors.surface,

  indicatorColor: AppColors.primaryMuted,

  iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
    (states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(
          color: AppColors.primary,
        );
      }

      return const IconThemeData(
        color: AppColors.textMuted,
      );
    },
  ),

  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
    (states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        );
      }

      return const TextStyle(
        color: AppColors.textMuted,
      );
    },
  ),
),

    // ── Floating Action Button (home screen "add") ─
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.fabBg,
      foregroundColor: AppColors.textPrimary,
      elevation: 2,
    ),

    // ── Dialog box ───────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.dialogBg,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'DM Sans',
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
        fontFamily: 'DM Sans',
      ),
    ),

    // ── Bottom sheet (e.g. "add transaction" sheet) ─
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.sheetBg,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      modalBackgroundColor: AppColors.sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    // ── Scrim behind dialogs / sheets / drawers ──
    // (used directly where needed, e.g. barrierColor: AppColors.scrimColor)

    // ── SnackBar ─────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.snackBarBg,
      contentTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontFamily: 'DM Sans',
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actionTextColor: AppColors.primaryLight,
    ),

    // ── Tooltip ──────────────────────────────────
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.tooltipBg,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12,
      ),
    ),

    // ── Chip (filter chips, category tags on home) ─
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.chipBg,
      selectedColor: AppColors.chipSelectedBg,
      disabledColor: AppColors.textDisabled,
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontFamily: 'DM Sans',
      ),
      secondaryLabelStyle: const TextStyle(
        color: AppColors.primaryLight,
        fontSize: 13,
        fontFamily: 'DM Sans',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // ── List tiles (home screen transaction list) ─
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      textColor: AppColors.textPrimary,
      iconColor: AppColors.textSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    // ── Icon ─────────────────────────────────────
    iconTheme: const IconThemeData(color: AppColors.textSecondary),

    // ── Input fields ─────────────────────────────
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

    // ── Buttons ──────────────────────────────────
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

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'DM Sans',
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),

    // ── Divider ──────────────────────────────────
    dividerColor: AppColors.divider,

    fontFamily: 'DM Sans',
  );
}