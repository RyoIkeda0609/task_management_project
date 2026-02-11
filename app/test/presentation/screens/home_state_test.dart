import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/screens/home/home_state.dart';
import 'package:app/presentation/screens/home/home_view_model.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';

void main() {
  group('HomePageState', () {
    test('初期状態がローディング', () {
      final state = HomePageState.initial();

      expect(state.isLoading, true);
      expect(state.isEmpty, false);
      expect(state.hasData, false);
      expect(state.isError, false);
      expect(state.goals, isEmpty);
      expect(state.selectedTabIndex, 0);
    });

    test('データが入ると hasData が true', () {
      final goals = [
        Goal(
          id: GoalId.generate(),
          title: GoalTitle('テストゴール'),
          category: GoalCategory('学習'),
          reason: GoalReason('能力向上'),
          deadline: GoalDeadline(DateTime.now().add(const Duration(days: 30))),
        ),
      ];

      final state = HomePageState.withData(goals);

      expect(state.hasData, true);
      expect(state.isEmpty, false);
      expect(state.goals.length, 1);
    });

    test('ゴールが空の場合 isEmpty が true', () {
      final state = HomePageState.withData([]);

      expect(state.isEmpty, true);
      expect(state.hasData, false);
    });

    test('エラー時 isError が true', () {
      final state = HomePageState.withError('エラーメッセージ');

      expect(state.isError, true);
      expect(state.errorMessage, 'エラーメッセージ');
    });

    test('タブインデックスが更新される', () {
      final state = HomePageState.initial();
      final updated = state.updateTabIndex(2);

      expect(updated.selectedTabIndex, 2);
      expect(state.selectedTabIndex, 0); // 元の state は変わらない
    });

    test('ゴールがソートされる（期限が近い順）', () {
      final now = DateTime.now();
      final goal1 = Goal(
        id: GoalId.generate(),
        title: GoalTitle('ゴール1'),
        category: GoalCategory('学習'),
        reason: GoalReason('理由1'),
        deadline: GoalDeadline(now.add(const Duration(days: 30))),
      );
      final goal2 = Goal(
        id: GoalId.generate(),
        title: GoalTitle('ゴール2'),
        category: GoalCategory('健康'),
        reason: GoalReason('理由2'),
        deadline: GoalDeadline(now.add(const Duration(days: 10))),
      );

      final state = HomePageState.withData([goal1, goal2]);
      final sorted = state.sortedGoals;

      expect(sorted[0].title.value, 'ゴール2'); // 10日後
      expect(sorted[1].title.value, 'ゴール1'); // 30日後
    });
  });

  group('HomeViewModel', () {
    test('初期状態はローディング', () {
      final container = ProviderContainer();
      final state = container.read(homeViewModelProvider);

      expect(state.isLoading, true);
    });

    test('タブを選択できる', () {
      final container = ProviderContainer();
      final viewModel = container.read(homeViewModelProvider.notifier);

      viewModel.selectTab(1);

      expect(container.read(homeViewModelProvider).selectedTabIndex, 1);
    });

    test('進捗率に応じた色を取得できる', () {
      final container = ProviderContainer();
      final viewModel = container.read(homeViewModelProvider.notifier);

      final color0 = viewModel.getProgressColor(0);
      final color25 = viewModel.getProgressColor(25);
      final color75 = viewModel.getProgressColor(75);
      final color100 = viewModel.getProgressColor(100);

      expect(color0, isNotNull);
      expect(color25, isNotNull);
      expect(color75, isNotNull);
      expect(color100, isNotNull);
    });
  });
}
