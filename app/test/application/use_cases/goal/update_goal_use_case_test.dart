import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/goal/update_goal_use_case.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/infrastructure/repositories/goal_repository.dart';

class MockGoalRepository implements GoalRepository {
  final List<Goal> _goals = [];

  @override
  Future<List<Goal>> getAllGoals() async => _goals;

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      return _goals.firstWhere((g) => g.id.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    _goals.removeWhere((g) => g.id.value == goal.id.value);
    _goals.add(goal);
  }

  @override
  Future<void> deleteGoal(String id) async =>
      _goals.removeWhere((g) => g.id.value == id);

  @override
  Future<void> deleteAllGoals() async => _goals.clear();

  @override
  Future<int> getGoalCount() async => _goals.length;
}

void main() {
  group('UpdateGoalUseCase', () {
    late UpdateGoalUseCase useCase;
    late MockGoalRepository repository;

    setUp(() {
      repository = MockGoalRepository();
      useCase = UpdateGoalUseCaseImpl(repository);
    });

    test('存在しないゴール ID でエラーが発生すること', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      expect(
        () => useCase.call(
          goalId: 'non-existent',
          title: 'タイトル',
          category: 'カテゴリ',
          reason: '理由',
          deadline: tomorrow,
        ),
        throwsArgumentError,
      );
    });

    test('ゴール ID が正しければゴールが更新されること', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final goal = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('元のタイトル'),
        category: GoalCategory('元のカテゴリ'),
        reason: GoalReason('元の理由'),
        deadline: GoalDeadline(tomorrow),
      );

      await repository.saveGoal(goal);

      final nextDay = tomorrow.add(const Duration(days: 1));
      final updatedGoal = await useCase.call(
        goalId: 'goal-1',
        title: '新しいタイトル',
        category: '新しいカテゴリ',
        reason: '新しい理由',
        deadline: nextDay,
      );

      expect(updatedGoal.title.value, '新しいタイトル');
      expect(updatedGoal.category.value, '新しいカテゴリ');
      expect(updatedGoal.reason.value, '新しい理由');
    });
  });
}
