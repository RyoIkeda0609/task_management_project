import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'custom_button.dart';

/// 空状態（EmptyState）Widget
///
/// データがない場合の空状態を視覚的に表示します。
/// アイコン、タイトル、メッセージ、アクションボタンをカスタマイズ可能です。
class EmptyState extends StatelessWidget {
  /// 表示するアイコン
  final IconData icon;

  /// タイトルテキスト
  final String title;

  /// メッセージテキスト
  final String? message;

  /// アクションボタンのテキスト
  final String? actionText;

  /// アクションボタン押下時のコールバック
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Spacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // アイコン
            Icon(icon, size: 64, color: AppColors.neutral300),

            SizedBox(height: Spacing.medium),

            // タイトル
            Text(
              title,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),

            // メッセージ
            if (message != null) ...[
              SizedBox(height: Spacing.small),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.withColor(AppColors.neutral500),
                textAlign: TextAlign.center,
              ),
            ],

            // アクションボタン
            if (actionText != null && onActionPressed != null) ...[
              SizedBox(height: Spacing.large),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: actionText!,
                  onPressed: onActionPressed,
                  type: ButtonType.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
