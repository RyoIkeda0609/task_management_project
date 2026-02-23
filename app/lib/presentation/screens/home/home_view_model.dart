import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import 'home_state.dart';
import '../../state_management/providers/app_providers.dart';
import '../../../application/providers/use_case_providers.dart';

/// ホーム画面の ViewModel
///
/// 責務：
/// - ゴール一覧のロード
/// - タブインデックスの管理
/// - ゴールフィルターの管理
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
      await _ref.read(goalsProvider.notifier).loadGoals();

      final goalsAsync = _ref.read(goalsProvider);
      await goalsAsync.when(
        data: (loadedGoals) async {
          final progressMap = await _calculateProgressMap(loadedGoals);
          state = HomePageState.withData(
            loadedGoals,
            goalProgressMap: progressMap,
            filter: state.filter,
          );
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

  /// フィルターを切り替える
  void toggleFilter(HomeGoalFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// タブを選択
  void selectTab(int tabIndex) {
    state = state.copyWith(selectedTabIndex: tabIndex);
  }

  /// 全ゴールの進捗率を計算
  Future<Map<String, int>> _calculateProgressMap(List<Goal> goals) async {
    final progressMap = <String, int>{};
    final calculateProgress = _ref.read(calculateProgressUseCaseProvider);

    for (final goal in goals) {
      try {
        final progress = await calculateProgress.calculateGoalProgress(
          goal.itemId.value,
        );
        progressMap[goal.itemId.value] = progress.value;
      } catch (_) {
        progressMap[goal.itemId.value] = 0;
      }
    }
    return progressMap;
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
