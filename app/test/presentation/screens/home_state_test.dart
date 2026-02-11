import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/screens/home/home_state.dart';
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
  });
}
