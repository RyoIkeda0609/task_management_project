import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// ダイアログ表示用ヘルパークラス
///
/// アプリケーション全体で統一されたダイアログを表示します。
class DialogHelper {
  DialogHelper._(); // インスタンス化禁止

  /// 確認ダイアログを表示
  ///
  /// 戻り値: ユーザーが「OK」をタップした場合true、「キャンセル」をタップした場合false
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String okText = 'はい',
    String cancelText = 'いいえ',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTextStyles.headlineMedium),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: AppTextStyles.button.withColor(AppColors.neutral600),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(cancelText),
          ),
        ],
      ),
    );
  }

  /// エラーダイアログを表示（統一されたエラーUI）
  ///
  /// 見出し：「エラーが発生しました」
  /// ボタン：「OK」
  /// 色：赤系統一
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String message,
    String title = 'エラーが発生しました',
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.error),
        ),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// バリデーションエラーダイアログを表示
  ///
  /// 入力形式エラー用。見出しは「入力エラー」に固定
  static Future<void> showValidationErrorDialog(
    BuildContext context, {
    required String message,
    String buttonText = 'OK',
  }) {
    return showErrorDialog(
      context,
      title: '入力エラー',
      message: message,
      buttonText: buttonText,
    );
  }

  /// ネットワークエラーダイアログを表示
  ///
  /// 通信失敗時の統一UI
  /// TODO: APIエラーハンドリング時に呼び出し実装（retry button付き）
  static Future<bool?> showNetworkErrorDialog(
    BuildContext context, {
    String message = '通信に失敗しました。',
    String retryText = '再試行',
    String cancelText = 'キャンセル',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'エラーが発生しました',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.error),
        ),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: AppTextStyles.button.copyWith(color: AppColors.neutral600),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(retryText),
          ),
        ],
      ),
    );
  }

  /// データ破損エラーダイアログを表示
  ///
  /// Hive やデータベース破損時の統一UI
  /// TODO: Hiveボックスクローズ時のエラーハンドリングで実装
  static Future<void> showDataErrorDialog(
    BuildContext context, {
    String message = 'データを読み込めませんでした。',
    String buttonText = 'OK',
  }) {
    return showErrorDialog(
      context,
      title: 'エラーが発生しました',
      message: message,
      buttonText: buttonText,
    );
  }

  /// リソース不在エラーダイアログを表示
  ///
  /// ゴール、マイルストーン、タスクが見つからないときの統一UI
  /// TODO: 詳細画面のerror状態で showNotFoundErrorDialog(context, resourceName: 'ゴール') を呼び出す
  static Future<void> showNotFoundErrorDialog(
    BuildContext context, {
    required String resourceName,
    String? customMessage,
    String buttonText = 'OK',
  }) {
    final message = customMessage ?? '$resourceName が見つかりません。';
    return showErrorDialog(context, message: message, buttonText: buttonText);
  }

  /// 成功ダイアログを表示
  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTextStyles.headlineMedium.withColor(AppColors.success),
        ),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// 情報ダイアログを表示
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTextStyles.headlineMedium.withColor(AppColors.info),
        ),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.info),
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// 削除確認ダイアログを表示
  static Future<bool?> showDeleteConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String deleteText = '削除',
    String cancelText = 'キャンセル',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTextStyles.headlineMedium),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: AppTextStyles.button.copyWith(color: AppColors.neutral600),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(deleteText),
          ),
        ],
      ),
    );
  }
}
