import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// カスタムプログレスインジケーター
///
/// タスク完了率や進捗状況を0～100のパーセンテージで表示します。
/// プログレスバーはアニメーション付きで滑らかに変化します。
class ProgressIndicator extends StatelessWidget {
  /// 進捗率（0～100）
  final double percentage;

  /// ラベル表示有無
  final bool showLabel;

  /// プログレスバーの高さ
  final double height;

  /// プログレスバーの色
  final Color color;

  /// 背景色
  final Color backgroundColor;

  /// アニメーション時間
  final Duration animationDuration;

  const ProgressIndicator({
    super.key,
    required this.percentage,
    this.showLabel = true,
    this.height = 8,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.neutral200,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    // パーセンテージを0～1に正規化
    final normalizedPercentage = (percentage / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // アニメーション付きプログレスバー
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.small),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: normalizedPercentage),
            duration: animationDuration,
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: height,
                backgroundColor: backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            },
          ),
        ),

        // ラベル表示
        if (showLabel)
          Padding(
            padding: EdgeInsets.only(top: Spacing.xSmall),
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: AppTextStyles.labelMedium,
            ),
          ),
      ],
    );
  }
}
