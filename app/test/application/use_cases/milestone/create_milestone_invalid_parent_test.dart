import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/milestone/create_milestone_use_case.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';

class FakeGoalRepository implements GoalRepository {
  @override
  Future<bool> deleteAllGoals() async => true;

  @override
  Future<void> deleteGoal(String id) async {}

  @override
  Future<int> getGoalCount() async => 0;

  @override
  Future<List<Goal>> getAllGoals() async => [];

  @override
  Future<Goal?> getGoalById(String id) async => null;

  @override
  Future<void> saveGoal(Goal goal) async {}
}

void main() {
  group('CreateMilestoneUseCase - 不正な親への追加テスト', () {
    late CreateMilestoneUseCase useCase;

    setUp(() {
      useCase = CreateMilestoneUseCaseImpl();
    });

    test('マイルストーンは ValueObject のバリデーションで作成できる', () async {
      final milestone = await useCase.call(
        title: 'テストマイルストーン',
        deadline: DateTime(2026, 12, 31),
        goalId: 'goal-1',
      );

      expect(milestone.title.value, 'テストマイルストーン');
      expect(milestone.goalId, 'goal-1');
    });

    test('空のゴール ID でマイルストーンを作成しようとするとエラー', () async {
      expect(
        () async => await useCase.call(
          title: 'マイルストーン',
          deadline: DateTime(2026, 12, 31),
          goalId: '',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('期限が本日より前の日付でもマイルストーンが作成できること', () async {
      expect(
        () async => await useCase.call(
          title: 'マイルストーン',
          deadline: DateTime(2020, 1, 1),
          goalId: 'goal-1',
        ),
        returnsNormally,
      );
    });
  });
}
