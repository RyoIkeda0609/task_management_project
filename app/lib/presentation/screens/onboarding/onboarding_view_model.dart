import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_state.dart';
import '../../state_management/providers/app_providers.dart';

/// オンボーディング画面のViewModel
///
/// 責務：
/// - ページ遷移のオーケストレーション
/// - オンボーディング完了処理
/// - UI状態の更新
///
/// 禁止：
/// - UI部品の操作
/// - BuildContext の保持
/// - PageController の直接操作
class OnboardingViewModel extends StateNotifier<OnboardingPageState> {
  final Ref _ref;

  OnboardingViewModel(this._ref) : super(OnboardingPageState.initial());

  /// 次のページへ遷移または完了処理を実行
  ///
  /// 最後のページなら完了フラグをオンボーディング完了プロバイダーに保存
  Future<void> nextPageOrComplete() async {
    try {
      state = state.nextPageOrComplete();

      if (state.isCompleted) {
        // オンボーディング完了フラグを保存
        _ref.read(onboardingCompleteProvider.notifier).state = true;
      }
    } catch (e) {
      state = OnboardingPageState(
        currentPageIndex: state.currentPageIndex,
        isCompleted: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// ページを指定して遷移
  ///
  /// PageView の onPageChanged コールバックから呼ばれる
  void setCurrentPage(int pageIndex) {
    state = OnboardingPageState(
      currentPageIndex: pageIndex,
      isCompleted: false,
    );
  }
}

/// オンボーディング画面のViewModel Provider
final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingPageState>((ref) {
      return OnboardingViewModel(ref);
    });
