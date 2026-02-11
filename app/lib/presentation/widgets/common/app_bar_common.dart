import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// カスタムアプリケーションバー
///
/// アプリケーション全体で統一されたAppBarを提供します。
/// タイトル、戻るボタン、アクションボタンをカスタマイズ可能です。
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isNavigating = false;

  Future<void> _onBackPressed() async {
    // 連打防止: 既にナビゲーション中の場合は処理をスキップ
    if (_isNavigating) {
      return;
    }

    _isNavigating = true;

    try {
      if (widget.onLeadingPressed != null) {
        widget.onLeadingPressed!();
      } else if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // ナビゲーション失敗時はログ出力のみ（ユーザーには影響なし）
      debugPrint('Back button navigation error: $e');
    } finally {
      // ナビゲーション完了後、フラグをリセット
      if (mounted) {
        _isNavigating = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title, style: AppTextStyles.headlineLarge),
      backgroundColor: widget.backgroundColor,
      elevation: 0,
      leading: widget.hasLeading
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _onBackPressed,
            )
          : null,
      actions: widget.actions ?? [],
      surfaceTintColor: Colors.transparent,
    );
  }
}
