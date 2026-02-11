import 'package:app/presentation/screens/home/home_state.dart';
import 'package:app/presentation/state_management/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../navigation/app_router.dart';
import 'home_widgets.dart';

/// ホーム画面
///
/// 3つの異なるビュー（リスト / ピラミッド / カレンダー）でゴール・マイルストーン・タスクを表示します。
///
/// 責務：
/// - Scaffold と Provider の接続
/// - _Body への配線
/// - ナビゲーション処理
///
/// 禁止：
/// - ビジネスロジック
/// - データ変換
/// - 状態判定（if isLoading など）- ロジックは _Body へ
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const HomeAppBar(),
        body: goalsAsync.when(
          data: (goals) => _Body(
            state: HomePageState.withData(goals),
            onCreatePressed: () => _onCreateGoalPressed(context),
          ),
          loading: () => _Body(
            state: HomePageState.initial(),
            onCreatePressed: () => _onCreateGoalPressed(context),
          ),
          error: (error, stackTrace) => _Body(
            state: HomePageState.withError(error.toString()),
            onCreatePressed: () => _onCreateGoalPressed(context),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _onCreateGoalPressed(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _onCreateGoalPressed(BuildContext context) {
    AppRouter.navigateToGoalCreate(context);
  }
}

class _Body extends StatelessWidget {
  final HomePageState state;
  final VoidCallback onCreatePressed;

  const _Body({required this.state, required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return TabBarView(
        children: [
          _buildLoadingTab(),
          _buildLoadingTab(),
          _buildLoadingTab(),
        ],
      );
    }

    if (state.isError) {
      return GoalErrorView(
        errorMessage: state.errorMessage ?? 'Unknown error',
        onCreatePressed: onCreatePressed,
      );
    }

    if (state.isEmpty) {
      return GoalEmptyView(onCreatePressed: onCreatePressed);
    }

    return HomeContent(
      state: state,
      onCreatePressed: onCreatePressed,
    );
  }

  Widget _buildLoadingTab() {
    return const Center(child: CircularProgressIndicator());
  }
}
