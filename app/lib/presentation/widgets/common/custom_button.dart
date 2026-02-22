import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// ボタンのタイプを定義
enum ButtonType {
  /// プライマリボタン（強調・メイン操作）
  primary,

  /// セカンダリボタン（補助操作）
  secondary,

  /// ダンジャーボタン（削除・警告操作）
  danger,

  /// テキストボタン（最小限の強調）
  text,
}

/// カスタムボタンWidget
///
/// アプリケーション全体で統一されたボタンスタイルを提供します。
/// タイプ、幅、高さ、ローディング状態、無効状態をカスタマイズ可能です。
class CustomButton extends StatelessWidget {
  /// ボタンのテキスト
  final String text;

  /// ボタン押下時のコールバック
  final VoidCallback? onPressed;

  /// ボタンのタイプ
  final ButtonType type;

  /// ボタンの幅（省略可。デフォルトはdouble.infinity）
  final double? width;

  /// ボタンの高さ（省略可。デフォルトは48）
  final double? height;

  /// ボタンのアイコン（省略可）
  final IconData? icon;

  /// 無効状態フラグ
  final bool isDisabled;

  /// ローディング状態フラグ
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.width,
    this.height = 48,
    this.icon,
    this.isDisabled = false,
    this.isLoading = false,
  });

  /// ボタンのスタイルを取得
  ButtonStyle _getButtonStyle() {
    switch (type) {
      case ButtonType.primary:
        return FilledButton.styleFrom(
          backgroundColor: isDisabled
              ? AppColors.neutral300
              : AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.neutral300,
          disabledForegroundColor: AppColors.neutral400,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.medium,
            vertical: Spacing.small,
          ),
          minimumSize: Size(width ?? double.infinity, height ?? 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );

      case ButtonType.secondary:
        return OutlinedButton.styleFrom(
          foregroundColor: isDisabled
              ? AppColors.neutral300
              : AppColors.primary,
          side: BorderSide(
            color: isDisabled ? AppColors.neutral300 : AppColors.primary,
            width: 1,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.medium,
            vertical: Spacing.small,
          ),
          minimumSize: Size(width ?? double.infinity, height ?? 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );

      case ButtonType.danger:
        return FilledButton.styleFrom(
          backgroundColor: isDisabled ? AppColors.neutral300 : AppColors.error,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.neutral300,
          disabledForegroundColor: AppColors.neutral400,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.medium,
            vertical: Spacing.small,
          ),
          minimumSize: Size(width ?? double.infinity, height ?? 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );

      case ButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: isDisabled
              ? AppColors.neutral300
              : AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.small,
            vertical: Spacing.xSmall,
          ),
          minimumSize: Size(width ?? 0, height ?? 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final onButtonPressed = (isDisabled || isLoading) ? null : onPressed;
    final buttonContent = _buildContent();

    return _buildButton(buttonStyle, onButtonPressed, buttonContent);
  }

  Widget _buildContent() {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.secondary || type == ButtonType.text
                    ? AppColors.primary
                    : Colors.white,
              ),
            ),
          ),
          SizedBox(width: Spacing.xSmall),
          Text(text),
        ],
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          SizedBox(width: Spacing.xSmall),
          Text(text),
        ],
      );
    }
    return Text(text);
  }

  Widget _buildButton(
    ButtonStyle style,
    VoidCallback? onPressed,
    Widget child,
  ) {
    return switch (type) {
      ButtonType.primary || ButtonType.danger => FilledButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
      ButtonType.secondary => OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
      ButtonType.text => TextButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    };
  }
}
