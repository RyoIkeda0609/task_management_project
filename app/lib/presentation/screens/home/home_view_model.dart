import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_state.dart';
import '../../state_management/providers/app_providers.dart';

/// ホーム画面の ViewModel
///
/// 責務：
/// - ゴール一覧のロード
/// - タブインデックスの管理
/// - UI 状態の更新
///
/// 禁止：
/// - UI 部品の操作
/// - BuildContext 保持
/// - UI整形ロジック（色計算など）
class HomeViewModel extends StateNotifier<HomePageState> {
  final Ref _ref;

  HomeViewModel(this._ref) : super(HomePageState.initial());

  /// ゴール一覧を読み込む
  Future<void> loadGoals() async {
    try {
      // goalsProvider をロードする
      await _ref.read(goalsProvider.notifier).loadGoals();

      // ロード後、現在の状態を取得して更新
      final goalsAsync = _ref.read(goalsProvider);
      goalsAsync.when(
        data: (loadedGoals) {
          state = HomePageState.withData(loadedGoals);
        },
        loading: () {
          state = HomePageState.initial();
        },
        error: (error, _) {
          state = HomePageState.withError(error.toString());
        },
      );
    } catch (e) {
      state = HomePageState.withError(e.toString());
    }
  }

  /// タブを選択
  void selectTab(int tabIndex) {
    state = state.updateTabIndex(tabIndex);
  }
}

/// ホーム画面の ViewModel Provider
final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomePageState>((ref) {
      final viewModel = HomeViewModel(ref);
      // 初期化時にゴール一覧を読み込む
      Future.microtask(() => viewModel.loadGoals());
      return viewModel;
    });
