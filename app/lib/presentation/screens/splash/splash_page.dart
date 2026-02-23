import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../navigation/app_router.dart';
import '../../state_management/providers/app_providers.dart';
import 'splash_view_model.dart';
import 'splash_widgets.dart';

/// スプラッシュ画面
///
/// アプリケーション起動時に2秒間表示され、その後ホーム画面またはオンボーディング画面に自動遷移します。
///
/// 責務：
/// - Scaffold と Provider の接続
/// - Widget の並列表示
/// - ViewModel 呼び出し
///
/// 禁止：
/// - ビジネスロジック
/// - データ変換
/// - 状態判定（if isLoading など）
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// アプリケーションの初期化処理を実行
  ///
  /// ViewModel の initialize() を呼び出し、
  /// 完了後に遷移処理を実行。
  Future<void> _initializeApp() async {
    final viewModel = ref.read(splashViewModelProvider.notifier);
    final isSuccess = await viewModel.initialize();

    if (!mounted) return;

    if (isSuccess) {
      _onInitializationComplete();
    } else {
      _onInitializationError();
    }
  }

  /// 初期化完了時の処理
  ///
  /// オンボーディング完了フラグを確認して遷移先を決定
  void _onInitializationComplete() {
    final isOnboardingComplete = ref.read(onboardingCompleteProvider);

    AppRouter.navigateFromSplash(context, isOnboardingComplete);
  }

  /// 初期化エラー時の処理
  ///
  /// ホーム画面に遷移（フォールバック）
  void _onInitializationError() {
    AppRouter.navigateFromSplash(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: const SplashContent(),
    );
  }
}
