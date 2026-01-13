import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// App Theme Configuration
/// Implements Material 3 design with custom color palette and typography
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    return baseTheme.copyWith(
      // Color Scheme
      colorScheme: _lightColorScheme,

      // Scaffold and Background
      scaffoldBackgroundColor: AppColors.background,

      // App Bar Theme
      appBarTheme: _appBarTheme(baseTheme),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: _bottomNavTheme(baseTheme),

      // Card Theme
      cardTheme: _cardTheme(baseTheme),

      // Elevated Button Theme
      elevatedButtonTheme: _elevatedButtonTheme(baseTheme),

      // Outlined Button Theme
      outlinedButtonTheme: _outlinedButtonTheme(baseTheme),

      // Text Button Theme
      textButtonTheme: _textButtonTheme(baseTheme),

      // Input Decoration Theme
      inputDecorationTheme: _inputDecorationTheme(baseTheme),

      // Dialog Theme
      dialogTheme: _dialogTheme(baseTheme),

      // Bottom Sheet Theme
      bottomSheetTheme: _bottomSheetTheme(baseTheme),

      // Snack Bar Theme
      snackBarTheme: _snackBarTheme(baseTheme),

      // Floating Action Button Theme
      floatingActionButtonTheme: _fabTheme(baseTheme),

      // Divider Theme
      dividerTheme: _dividerTheme(baseTheme),

      // Chip Theme
      chipTheme: _chipTheme(baseTheme),

      // Tab Bar Theme
      tabBarTheme: _tabBarTheme(baseTheme),

      // Text Theme
      textTheme: _textTheme(baseTheme.textTheme),

      // Primary Text Theme
      primaryTextTheme: _primaryTextTheme(baseTheme.primaryTextTheme),
    );
  }

  /// Dark theme configuration (future implementation)
  static ThemeData get darkTheme {
    // For now, return light theme - can be expanded later
    return lightTheme;
  }

  /// Light color scheme based on app colors
  static ColorScheme get _lightColorScheme {
    return ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.secondaryLight,
      onSecondaryContainer: AppColors.secondaryDark,
      tertiary: AppColors.accent,
      onTertiary: AppColors.white,
      tertiaryContainer: AppColors.accentLight,
      onTertiaryContainer: AppColors.accentDark,
      error: AppColors.error,
      onError: AppColors.white,
      errorContainer: AppColors.error.withValues(alpha: 0.1),
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.divider,
      shadow: AppColors.shadow,
    );
  }

  /// App bar theme
  static AppBarTheme _appBarTheme(ThemeData baseTheme) {
    return AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: AppColors.shadow.withValues(alpha: 0.1),
      surfaceTintColor: Colors.transparent,
      shape: const Border(
        bottom: BorderSide(
          color: AppColors.divider,
          width: AppSizes.borderWidthThin,
        ),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontXxl,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(
        color: AppColors.onSurface,
        size: AppSizes.iconLg,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.onSurface,
        size: AppSizes.iconLg,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Bottom navigation bar theme
  static BottomNavigationBarThemeData _bottomNavTheme(ThemeData baseTheme) {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: AppSizes.elevationSm,
      selectedItemColor: AppColors.onSurface,
      unselectedItemColor: AppColors.onSurfaceVariant,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontXs,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontXs,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }

  /// Card theme
  static CardTheme _cardTheme(ThemeData baseTheme) {
    return CardTheme(
      color: AppColors.surface,
      shadowColor: AppColors.shadow,
      elevation: AppSizes.elevationNone,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: AppColors.divider,
          width: AppSizes.borderWidthThin,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      surfaceTintColor: Colors.transparent,
    );
  }

  /// Elevated button theme
  static ElevatedButtonThemeData _elevatedButtonTheme(ThemeData baseTheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: AppSizes.elevationSm,
        shadowColor: AppColors.shadow,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        minimumSize: Size(double.infinity, AppSizes.buttonHeightMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  /// Outlined button theme
  static OutlinedButtonThemeData _outlinedButtonTheme(ThemeData baseTheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: AppSizes.borderWidthNormal,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        minimumSize: Size(double.infinity, AppSizes.buttonHeightMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  /// Text button theme
  static TextButtonThemeData _textButtonTheme(ThemeData baseTheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        minimumSize: Size(0, AppSizes.buttonHeightMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  /// Input decoration theme
  static InputDecorationTheme _inputDecorationTheme(ThemeData baseTheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(
          color: AppColors.divider,
          width: AppSizes.borderWidthNormal,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(
          color: AppColors.divider,
          width: AppSizes.borderWidthNormal,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: AppSizes.borderWidthThick,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(
          color: AppColors.error,
          width: AppSizes.borderWidthNormal,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(
          color: AppColors.error,
          width: AppSizes.borderWidthThick,
        ),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontMd,
        color: AppColors.onSurfaceVariant,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontMd,
        color: AppColors.textHint,
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontSm,
        color: AppColors.error,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontSm,
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
      helperStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontSm,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  /// Dialog theme
  static DialogTheme _dialogTheme(ThemeData baseTheme) {
    return DialogTheme(
      backgroundColor: AppColors.surface,
      elevation: AppSizes.elevationMd,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontXl,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontMd,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  /// Bottom sheet theme
  static BottomSheetThemeData _bottomSheetTheme(ThemeData baseTheme) {
    return BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      elevation: AppSizes.elevationMd,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      modalBackgroundColor: AppColors.surface,
      modalElevation: AppSizes.elevationMd,
    );
  }

  /// Snack bar theme
  static SnackBarThemeData _snackBarTheme(ThemeData baseTheme) {
    return SnackBarThemeData(
      backgroundColor: AppColors.onSurface,
      actionTextColor: AppColors.primary,
      contentTextStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontMd,
        color: AppColors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: AppSizes.elevationMd,
    );
  }

  /// Floating action button theme
  static FloatingActionButtonThemeData _fabTheme(ThemeData baseTheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: AppSizes.elevationMd,
      focusElevation: AppSizes.elevationLg,
      hoverElevation: AppSizes.elevationLg,
      highlightElevation: AppSizes.elevationXl,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
    );
  }

  /// Divider theme
  static DividerThemeData _dividerTheme(ThemeData baseTheme) {
    return DividerThemeData(
      color: AppColors.divider,
      thickness: AppSizes.borderWidthNormal,
      space: AppSizes.md,
    );
  }

  /// Chip theme
  static ChipThemeData _chipTheme(ThemeData baseTheme) {
    return ChipThemeData(
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      deleteIconColor: AppColors.onSurfaceVariant,
      disabledColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
      labelStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontSm,
        color: AppColors.onSurface,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontSm,
        color: AppColors.primary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      side: BorderSide(
        color: AppColors.divider,
        width: AppSizes.borderWidthThin,
      ),
    );
  }

  /// Tab bar theme
  static TabBarTheme _tabBarTheme(ThemeData baseTheme) {
    return TabBarTheme(
      indicator: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      indicatorColor: AppColors.primary,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.onSurfaceVariant,
      labelStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontMd,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontMd,
        fontWeight: FontWeight.w400,
      ),
      overlayColor: WidgetStateProperty.all(
        AppColors.primary.withValues(alpha: 0.1),
      ),
    );
  }

  /// Custom text theme with Inter font
  static TextTheme _textTheme(TextTheme baseTheme) {
    return GoogleFonts.interTextTheme(baseTheme).copyWith(
      // Display styles
      displayLarge: GoogleFonts.inter(
        fontSize: AppSizes.fontDisplayLg,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        height: AppSizes.lineHeightTight,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontDisplayMd,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: AppSizes.lineHeightTight,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: AppSizes.fontXxxl,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: AppSizes.lineHeightTight,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.inter(
        fontSize: AppSizes.fontXxl,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: AppSizes.lineHeightTight,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontXl,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: AppSizes.lineHeightTight,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: AppSizes.fontLg,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: AppSizes.lineHeightTight,
      ),

      // Title styles
      titleLarge: GoogleFonts.inter(
        fontSize: AppSizes.fontLg,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: AppSizes.lineHeightNormal,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontMd,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: AppSizes.lineHeightNormal,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: AppSizes.fontSm,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: AppSizes.lineHeightNormal,
      ),

      // Body styles
      bodyLarge: GoogleFonts.inter(
        fontSize: AppSizes.fontMd,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: AppSizes.lineHeightRelaxed,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontSm,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: AppSizes.lineHeightRelaxed,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: AppSizes.fontXs,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: AppSizes.lineHeightRelaxed,
      ),

      // Label styles
      labelLarge: GoogleFonts.inter(
        fontSize: AppSizes.fontMd,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: AppSizes.lineHeightNormal,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontSm,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: AppSizes.lineHeightNormal,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: AppSizes.fontXs,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: AppSizes.lineHeightNormal,
      ),
    );
  }

  /// Primary text theme (for app bars and headers)
  static TextTheme _primaryTextTheme(TextTheme baseTheme) {
    return _textTheme(baseTheme).apply(
      bodyColor: AppColors.white,
      displayColor: AppColors.white,
    );
  }
}