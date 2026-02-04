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

  /// エラーダイアログを表示
  static Future<void> showErrorDialog(
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
          style: AppTextStyles.headlineMedium.withColor(AppColors.error),
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
}
