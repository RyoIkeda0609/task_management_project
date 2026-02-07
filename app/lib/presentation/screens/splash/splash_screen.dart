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

  /// 2秒後に初回起動フロー制御を実行し、適切な画面へ遷移
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      _performInitialNavigation();
    }
  }

  /// 初回起動フロー制御：オンボーディング完了フラグを確認
  Future<void> _performInitialNavigation() async {
    try {
      // SharedPreferences または 他の永続化機構でオンボーディング完了フラグを確認
      // 現在は簡易実装：常にオンボーディング画面を表示する初回フローに戻す
      // TODO: 実装時にフラグをチェックして分岐
      if (mounted) {
        AppRouter.navigateFromSplash(context, false);
      }
    } catch (e) {
      // エラー時はオンボーディング画面へ
      if (mounted) {
        AppRouter.navigateFromSplash(context, false);
      }
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
