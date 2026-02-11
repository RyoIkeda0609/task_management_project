import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'home_state.dart';
import '../../state_management/providers/app_providers.dart';
import '../../../domain/entities/goal.dart';

/// ホーム画面の ViewModel
///
/// 責務：
/// - ゴール一覧のロード
/// - タブインデックスの管理
/// - 進捗色の計算
/// - UI 状態の更新
///
/// 禁止：
/// - UI 部品の操作
/// - BuildContext 保持
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

  /// 進捗率に応じた色を取得
  Color getProgressColor(int progressValue) {
    if (progressValue == 0) {
      return const Color(0xFFBCC0CA); // neutral400
    } else if (progressValue < 50) {
      return const Color(0xFF6366F1); // primary
    } else if (progressValue < 100) {
      return const Color(0xFFF59E0B); // warning
    } else {
      return const Color(0xFF10B981); // success
    }
  }

  /// ゴール作成ボタンが押された
  void onCreateGoalPressed() {
    // ナビゲーションは Page が担当するため、
    // ここでは何もしない（Page でコールバック処理）
  }

  /// ゴールカード選択
  void onGoalCardTapped(Goal goal) {
    // ナビゲーションは Page が担当
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
