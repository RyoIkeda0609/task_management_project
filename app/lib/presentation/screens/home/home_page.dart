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
/// - Widget の並列表示
/// - ViewModel 呼び出し
/// - ナビゲーション処理
///
/// 禁止：
/// - ビジネスロジック
/// - データ変換
/// - 状態判定（if isLoading など）- ロジックは ViewModel へ
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // goalsProvider を直接監視
    final goalsAsync = ref.watch(goalsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const HomeAppBar(),
        body: goalsAsync.when(
          data: (goals) {
            final state = HomePageState.withData(goals);
            return HomeContent(
              state: state,
              onCreatePressed: () => _onCreateGoalPressed(context),
            );
          },
          loading: () {
            final state = HomePageState.initial();
            return HomeContent(
              state: state,
              onCreatePressed: () => _onCreateGoalPressed(context),
            );
          },
          error: (error, stackTrace) {
            final state = HomePageState.withError(error.toString());
            return HomeContent(
              state: state,
              onCreatePressed: () => _onCreateGoalPressed(context),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _onCreateGoalPressed(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// ゴール作成ボタンが押された
  void _onCreateGoalPressed(BuildContext context) {
    AppRouter.navigateToGoalCreate(context);
  }
}
