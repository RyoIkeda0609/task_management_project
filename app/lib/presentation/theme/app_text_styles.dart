import 'package:flutter/material.dart';
import 'app_colors.dart';

/// アプリケーション全体で使用するテキストスタイル定義
///
/// Flutterの推奨パターンに従い、Typography階層を統一しています。
class AppTextStyles {
  AppTextStyles._(); // インスタンス化禁止

  // ============================================================================
  // Display (最大サイズ・フォーカス用)
  // ============================================================================

  /// ディスプレイラージ：アプリケーション内で最も大きなテキスト
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.neutral900,
  );

  /// ディスプレイメディアム
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.neutral900,
  );

  /// ディスプレイスモール：アプリケーション内で通常サイズのディスプレイ
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.neutral900,
  );

  // ============================================================================
  // Headline (画面タイトル・セクション見出し)
  // ============================================================================

  /// ヘッドラインラージ：画面タイトル
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.neutral900,
  );

  /// ヘッドラインメディアム：セクション見出し
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.neutral900,
  );

  /// ヘッドラインスモール：サブセクション見出し
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.neutral900,
  );

  // ============================================================================
  // Title (強調されたテキスト)
  // ============================================================================

  /// タイトルラージ
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.neutral900,
  );

  /// タイトルメディアム：リストアイテムのタイトル
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.neutral900,
  );

  /// タイトルスモール
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.neutral800,
  );

  // ============================================================================
  // Body (本文テキスト)
  // ============================================================================

  /// ボディラージ：標準的な本文
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.neutral800,
  );

  /// ボディメディアム：通常の本文
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.neutral800,
  );

  /// ボディスモール：補助テキスト
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: AppColors.neutral600,
  );

  // ============================================================================
  // Label (ラベル・UI要素用)
  // ============================================================================

  /// ラベルラージ
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.neutral900,
  );

  /// ラベルメディアム
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.05,
    color: AppColors.neutral900,
  );

  /// ラベルスモール
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.05,
    color: AppColors.neutral600,
  );

  // ============================================================================
  // Semantic Styles (意味を持つテキストスタイル)
  // ============================================================================

  /// エラーテキスト
  static const TextStyle error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );

  /// ヒントテキスト・プレースホルダー
  static const TextStyle hint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.neutral500,
  );

  /// 無効状態のテキスト
  static const TextStyle disabled = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.neutral400,
  );

  // ============================================================================
  // Button Text Styles
  // ============================================================================

  /// ボタン用テキスト
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.05,
  );

  /// 小さいボタン用テキスト
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.05,
  );
}

/// 拡張メソッド：テキストのカラー変更を容易に
extension TextStyleExtension on TextStyle {
  /// テキストカラーを変更したコピーを返す
  TextStyle withColor(Color color) {
    return copyWith(color: color);
  }

  /// テキストサイズを変更したコピーを返す
  TextStyle withSize(double size) {
    return copyWith(fontSize: size);
  }

  /// テキスト太さを変更したコピーを返す
  TextStyle withWeight(FontWeight weight) {
    return copyWith(fontWeight: weight);
  }
}
