import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/goal/get_goal_by_id_use_case.dart';
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
  Future<Goal?> getGoalById(String id) async =>
      _goals.firstWhere((g) => g.id.value == id, orElse: () => throw Exception());

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
  group('GetGoalByIdUseCase', () {
    late GetGoalByIdUseCase useCase;
    late MockGoalRepository repository;

    setUp(() {
      repository = MockGoalRepository();
      useCase = GetGoalByIdUseCaseImpl(repository);
    });

    test('空のゴール ID でエラーが発生すること', () async {
      expect(
        () => useCase.call(''),
        throwsArgumentError,
      );
    });

    test('存在するゴール ID でゴールが返されること', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final goal = Goal(
        id: GoalId('goal-1'),
        title: GoalTitle('テストゴール'),
        category: GoalCategory('カテゴリ'),
        reason: GoalReason('理由'),
        deadline: GoalDeadline(tomorrow),
      );

      await repository.saveGoal(goal);

      final result = await useCase.call('goal-1');

      expect(result?.title.value, 'テストゴール');
    });
  });
}
