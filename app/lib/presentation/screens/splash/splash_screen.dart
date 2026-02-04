import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../navigation/app_router.dart';

/// スプラッシュ画面
///
/// アプリケーション起動時に2秒間表示され、その後ホーム画面またはオンボーディング画面に自動遷移します。
class SplashScreen extends StatefulWidget {
  /// オンボーディング完了フラグ
  ///
  /// true の場合はホーム画面へ、false の場合はオンボーディング画面へ遷移
  final bool isOnboardingComplete;

  const SplashScreen({super.key, this.isOnboardingComplete = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  /// 2秒後に次の画面へ自動遷移
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      AppRouter.navigateFromSplash(context, widget.isOnboardingComplete);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // アプリロゴ
            Icon(Icons.checklist_rtl, size: 80, color: Colors.white),

            SizedBox(height: Spacing.large),

            // アプリ名
            Text(
              'タスク管理',
              style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
            ),

            SizedBox(height: Spacing.medium),

            // サブテキスト
            Text(
              'あなたの目標を達成するための完全なツール',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: Spacing.xxxLarge),

            // ローディングインジケーター
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
