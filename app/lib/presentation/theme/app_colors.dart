import 'package:flutter/material.dart';

/// アプリケーション全体で使用する色定義
///
/// このクラスで定義された色を常に参照することで、
/// デザインの統一感を保証します。
class AppColors {
  AppColors._(); // インスタンス化禁止

  // ============================================================================
  // Primary Color System
  // ============================================================================

  /// プライマリカラー（主要色・強調色）
  /// インディゴ系で、落ち着きと信頼感を表現
  static const Color primary = Color(0xFF5C6BC0);

  /// プライマリカラー（薄）
  static const Color primaryLight = Color(0xFF818CF8);

  /// プライマリカラー（濃）
  static const Color primaryDark = Color(0xFF4338CA);

  // ============================================================================
  // Semantic Colors（意味を持つ色）
  // ============================================================================

  /// 成功色：タスク完了（Done）状態
  static const Color success = Color(0xFF10B981);

  /// 注意色：タスク進行中（Doing）状態
  static const Color warning = Color(0xFFF59E0B);

  /// エラー色：削除・警告操作
  static const Color error = Color(0xFFEF4444);

  /// 情報色：通知・説明
  static const Color info = Color(0xFF3B82F6);

  // ============================================================================
  // Neutral Colors（ニュートラル・背景・テキスト）
  // ============================================================================

  /// 背景色（最明色）
  static const Color neutral100 = Color(0xFFFFFFFF);

  /// 薄い背景色
  static const Color neutral50 = Color(0xFFFAFAFA);

  /// 線・ボーダー色
  static const Color neutral200 = Color(0xFFF3F4F6);

  /// グレー系（アイコン等）
  static const Color neutral300 = Color(0xFFD1D5DB);

  /// グレー系（無効化テキスト）
  static const Color neutral400 = Color(0xFF9CA3AF);

  /// 薄いテキスト・プレースホルダー
  static const Color neutral500 = Color(0xFF6B7280);

  /// サブテキスト・補助情報
  static const Color neutral600 = Color(0xFF4B5563);

  /// メインテキスト
  static const Color neutral800 = Color(0xFF1F2937);

  /// 強調テキスト
  static const Color neutral900 = Color(0xFF111827);

  // ============================================================================
  // Goal Category Colors（ゴールカテゴリー色）
  // ============================================================================

  /// 健康・フィットネス
  static const Color categoryHealth = Color(0xFFEC4899);

  /// 仕事・キャリア
  static const Color categoryWork = Color(0xFF8B5CF6);

  /// 学習・スキル
  static const Color categoryLearning = Color(0xFF06B6D4);

  /// 趣味・娯楽
  static const Color categoryHobby = Color(0xFF84CC16);

  /// その他
  static const Color categoryOther = Color(0xFF6B7280);

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// ゴールカテゴリーから色を取得
  static Color getCategoryColor(String? category) {
    return switch (category) {
      '健康' => categoryHealth,
      '仕事' => categoryWork,
      '学習' => categoryLearning,
      '趣味' => categoryHobby,
      _ => categoryOther,
    };
  }

  /// タスク状態から色を取得
  static Color getStatusColor(String status) {
    return switch (status) {
      'done' => success,
      'doing' => warning,
      'todo' => neutral500,
      _ => neutral500,
    };
  }

  /// 進捗率から色を取得（グラデーション的）
  static Color getProgressColor(int progressPercentage) {
    if (progressPercentage < 33) {
      return error;
    } else if (progressPercentage < 66) {
      return warning;
    } else {
      return success;
    }
  }
}
