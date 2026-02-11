import 'package:app/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// スプラッシュ画面のロゴ部品
class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.checklist_rtl, size: 80, color: Colors.white);
  }
}

/// スプラッシュ画面のアプリ名表示部品
class SplashAppName extends StatelessWidget {
  const SplashAppName({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'タスク管理',
      style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
    );
  }
}

/// スプラッシュ画面のサブテキスト表示部品
class SplashSubtitle extends StatelessWidget {
  const SplashSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'あなたの目標を達成するための完全なツール',
      style: AppTextStyles.bodyMedium.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// スプラッシュ画面のローディングインジケーター部品
class SplashLoadingIndicator extends StatelessWidget {
  const SplashLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
    );
  }
}

/// スプラッシュ画面の中身全体
///
/// ロゴ、アプリ名、サブテキスト、ローディング表示を縦に並べます。
class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SplashLogo(),
          SizedBox(height: Spacing.large),
          const SplashAppName(),
          SizedBox(height: Spacing.medium),
          const SplashSubtitle(),
          SizedBox(height: Spacing.xxxLarge),
          const SplashLoadingIndicator(),
        ],
      ),
    );
  }
}
