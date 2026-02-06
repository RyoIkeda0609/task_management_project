import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// カスタムアプリケーションバー
///
/// アプリケーション全体で統一されたAppBarを提供します。
/// タイトル、戻るボタン、アクションボタンをカスタマイズ可能です。
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// ボタンのテキスト
  final String title;

  /// 戻るボタンの表示有無
  final bool hasLeading;

  /// 戻るボタン押下時のコールバック
  final VoidCallback? onLeadingPressed;

  /// 右側のアクションボタン群
  final List<Widget>? actions;

  /// アプリバーの背景色
  final Color backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.hasLeading = true,
    this.onLeadingPressed,
    this.actions,
    this.backgroundColor = AppColors.neutral100,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTextStyles.headlineLarge),
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: hasLeading
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions ?? [],
      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
