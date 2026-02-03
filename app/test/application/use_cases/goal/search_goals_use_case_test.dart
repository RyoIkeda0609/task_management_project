import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/goal/search_goals_use_case.dart';
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
  Future<Goal?> getGoalById(String id) async => _goals.firstWhere(
    (g) => g.id.value == id,
    orElse: () => throw Exception(),
  );

  @override
  Future<void> saveGoal(Goal goal) async => _goals.add(goal);

  @override
  Future<void> deleteGoal(String id) async =>
      _goals.removeWhere((g) => g.id.value == id);

  @override
  Future<void> deleteAllGoals() async => _goals.clear();

  @override
  Future<int> getGoalCount() async => _goals.length;
}

void main() {
  group('SearchGoalsUseCase', () {
    late SearchGoalsUseCase useCase;
    late MockGoalRepository repository;

    setUp(() {
      repository = MockGoalRepository();
      useCase = SearchGoalsUseCaseImpl(repository);
    });

    test('空のキーワードでエラーが発生すること', () async {
      expect(() => useCase.call(''), throwsArgumentError);
    });

    test('キーワードでゴールが検索できること', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      final goal1 = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('Flutter学習'),
        category: GoalCategory('プログラミング'),
        reason: GoalReason('スキル習得'),
        deadline: GoalDeadline(tomorrow),
      );

      final goal2 = Goal(
        id: GoalId('goal-2'),
        title: GoalTitle('ダイエット'),
        category: GoalCategory('健康'),
        reason: GoalReason('体重減少'),
        deadline: GoalDeadline(tomorrow),
      );

      await repository.saveGoal(goal1);
      await repository.saveGoal(goal2);

      final results = await useCase.call('Flutter');

      expect(results, hasLength(1));
      expect(results.first.title.value, 'Flutter学習');
    });

    test('カテゴリ検索が機能すること', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      final goal = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('タイトル'),
        category: GoalCategory('プログラミング'),
        reason: GoalReason('理由'),
        deadline: GoalDeadline(tomorrow),
      );

      await repository.saveGoal(goal);

      final results = await useCase.call('プログラミング');

      expect(results, hasLength(1));
    });
  });
}
