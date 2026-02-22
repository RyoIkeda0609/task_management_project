import 'package:app/presentation/screens/home/home_state.dart';
import 'package:app/presentation/state_management/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_colors.dart';
import 'home_widgets.dart';

/// ホーム画面
///
/// ゴール一覧をリスト形式で表示します。
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

    return Scaffold(
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
    return switch (state.viewState) {
      HomeViewState.loading => const _LoadingView(),
      HomeViewState.error => _ErrorView(
        errorMessage: state.errorMessage ?? 'Unknown error',
        onCreatePressed: onCreatePressed,
      ),
      HomeViewState.empty => _EmptyView(onCreatePressed: onCreatePressed),
      HomeViewState.data => _ContentView(
        state: state,
        onCreatePressed: onCreatePressed,
      ),
    };
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onCreatePressed;

  const _ErrorView({required this.errorMessage, required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    return GoalErrorView(
      errorMessage: errorMessage,
      onCreatePressed: onCreatePressed,
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onCreatePressed;

  const _EmptyView({required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    return GoalEmptyView(onCreatePressed: onCreatePressed);
  }
}

class _ContentView extends StatelessWidget {
  final HomePageState state;
  final VoidCallback onCreatePressed;

  const _ContentView({required this.state, required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    return HomeContent(state: state, onCreatePressed: onCreatePressed);
  }
}
