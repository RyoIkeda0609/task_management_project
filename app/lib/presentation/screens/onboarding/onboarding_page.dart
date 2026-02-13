import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../navigation/app_router.dart';
import 'onboarding_view_model.dart';
import 'onboarding_widgets.dart';

/// オンボーディング画面
///
/// アプリケーション初回起動時に、ゴール設定やタスク完了の説明など、
/// 2ページの PageView で構成されます。
///
/// 責務：
/// - Scaffold と Provider の接続
/// - Widget の並列表示
/// - ViewModel 呼び出し
/// - PageController 管理
///
/// 禁止：
/// - ビジネスロジック
/// - データ変換
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    final viewModel = ref.read(onboardingViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: Column(
        children: [
          Expanded(
            child: OnboardingPageView(
              currentPageIndex: state.currentPageIndex,
              pageController: _pageController,
              onPageChanged: (index) {
                viewModel.setCurrentPage(index);
              },
            ),
          ),
          OnboardingButtonArea(
            state: state,
            onPressed: () => _onButtonPressed(context, viewModel, state),
          ),
        ],
      ),
    );
  }

  /// ボタンが押されたときの処理
  ///
  /// ViewModel の nextPageOrComplete() を呼び出し、
  /// 完了時または最後のページ時に PageView をスクロール
  Future<void> _onButtonPressed(
    BuildContext context,
    OnboardingViewModel viewModel,
    dynamic state,
  ) async {
    await viewModel.nextPageOrComplete();

    // 次のフレームで実行（状態更新後）
    if (!mounted || !context.mounted) return;

    final newState = ref.read(onboardingViewModelProvider);

    if (newState.isCompleted) {
      // オンボーディング完了：ホーム画面へ遷移
      AppRouter.navigateToHome(context);
    } else if (newState.currentPageIndex > state.currentPageIndex) {
      // 次のページへスクロール
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
