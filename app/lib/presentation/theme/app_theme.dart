import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// アプリケーション全体の Theme 設定
///
/// Flutter の ThemeData にアプリケーション固有の設定を施し、
/// 統一されたデザインシステムを構築します。
class AppTheme {
  AppTheme._(); // インスタンス化禁止

  /// ライトテーマの ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ============================================================================
      // Color Scheme
      // ============================================================================
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.warning,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.neutral100,
        onSurface: AppColors.neutral900,
      ),

      // ============================================================================
      // Scaffold Theme
      // ============================================================================
      scaffoldBackgroundColor: AppColors.neutral50,

      // ============================================================================
      // AppBar Theme
      // ============================================================================
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.neutral100,
        foregroundColor: AppColors.neutral900,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.headlineLarge,
        iconTheme: const IconThemeData(color: AppColors.neutral900, size: 24),
      ),

      // ============================================================================
      // Button Themes
      // ============================================================================
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXLarge,
            vertical: spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTextStyles.button,
          minimumSize: const Size(double.infinity, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXLarge,
            vertical: spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTextStyles.button,
          minimumSize: const Size(double.infinity, 48),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingXSmall,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ============================================================================
      // Text Field Theme
      // ============================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.hint,
        errorStyle: AppTextStyles.error,
        counterStyle: AppTextStyles.bodySmall,
      ),

      // ============================================================================
      // Dialog Theme
      // ============================================================================
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusXLarge)),
        ),
      ),

      // ============================================================================
      // Divider Theme
      // ============================================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 0,
      ),

      // ============================================================================
      // Card Theme
      // ============================================================================
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusXLarge)),
          side: BorderSide(color: AppColors.neutral200, width: 1),
        ),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),

      // ============================================================================
      // List Tile Theme
      // ============================================================================
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
        ),
      ),

      // ============================================================================
      // Icon Theme
      // ============================================================================
      iconTheme: const IconThemeData(color: AppColors.neutral900, size: 24),

      // ============================================================================
      // Progress Indicator Theme
      // ============================================================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearMinHeight: 4,
      ),

      // ============================================================================
      // Typography
      // ============================================================================
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }

  /// スペーシング定数（マージン・パディング）
  static const double spacingNone = 0;
  static const double spacingXxSmall = 4;
  static const double spacingXSmall = 8;
  static const double spacingSmall = 12;
  static const double spacingMedium = 16;
  static const double spacingLarge = 20;
  static const double spacingXLarge = 24;
  static const double spacingXxLarge = 32;
  static const double spacingXxxLarge = 48;

  /// ボーダーラディウス定数
  static const double radiusSmall = 4;
  static const double radiusMedium = 8;
  static const double radiusLarge = 12;
  static const double radiusXLarge = 16;
  static const double radiusFull = 9999;
}

/// スペーシング定数へのアクセスを簡単にするヘルパー
class Spacing {
  Spacing._();

  static const double none = AppTheme.spacingNone;
  static const double xxSmall = AppTheme.spacingXxSmall;
  static const double xSmall = AppTheme.spacingXSmall;
  static const double small = AppTheme.spacingSmall;
  static const double medium = AppTheme.spacingMedium;
  static const double large = AppTheme.spacingLarge;
  static const double xLarge = AppTheme.spacingXLarge;
  static const double xxLarge = AppTheme.spacingXxLarge;
  static const double xxxLarge = AppTheme.spacingXxxLarge;
}

/// ボーダーラディウス定数へのアクセスを簡単にするヘルパー
class Radii {
  Radii._();

  static const double small = AppTheme.radiusSmall;
  static const double medium = AppTheme.radiusMedium;
  static const double large = AppTheme.radiusLarge;
  static const double xLarge = AppTheme.radiusXLarge;
  static const double full = AppTheme.radiusFull;
}
