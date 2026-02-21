import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/milestone/create_milestone_use_case.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/repositories/milestone_repository.dart';

/// MockGoalRepository
class MockGoalRepository implements GoalRepository {
  final List<Goal> _goals = [];

  @override
  Future<bool> deleteAllGoals() async => true;

  @override
  Future<void> deleteGoal(String id) async =>
      _goals.removeWhere((g) => g.itemId.value == id);

  @override
  Future<int> getGoalCount() async => _goals.length;

  @override
  Future<List<Goal>> getAllGoals() async => _goals;

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      return _goals.firstWhere((g) => g.itemId.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    final index = _goals.indexWhere((g) => g.itemId.value == goal.itemId.value);
    if (index >= 0) {
      _goals[index] = goal;
    } else {
      _goals.add(goal);
    }
  }
}

class MockMilestoneRepository implements MilestoneRepository {
  final List<Milestone> _milestones = [];

  @override
  Future<List<Milestone>> getAllMilestones() async => _milestones;

  @override
  Future<Milestone?> getMilestoneById(String id) async {
    try {
      return _milestones.firstWhere((m) => m.itemId.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async =>
      _milestones.where((m) => m.goalId.value == goalId).toList();

  @override
  Future<void> saveMilestone(Milestone milestone) async =>
      _milestones.add(milestone);

  @override
  Future<void> deleteMilestone(String id) async =>
      _milestones.removeWhere((m) => m.itemId.value == id);

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async =>
      _milestones.removeWhere((m) => m.goalId.value == goalId);

  @override
  Future<int> getMilestoneCount() async => _milestones.length;
}

void main() {
  group('CreateMilestoneUseCase', () {
    late CreateMilestoneUseCase useCase;
    late MockMilestoneRepository mockMilestoneRepository;
    late MockGoalRepository mockGoalRepository;

    setUp(() {
      mockMilestoneRepository = MockMilestoneRepository();
      mockGoalRepository = MockGoalRepository();
      useCase = CreateMilestoneUseCaseImpl(
        mockMilestoneRepository,
        mockGoalRepository,
      );

      // Pre-populate goal-123 for tests
      mockGoalRepository.saveGoal(
        Goal(
          itemId: ItemId('goal-123'),
          title: ItemTitle('テスト用ゴール'),
          category: GoalCategory('ビジネス'),
          description: ItemDescription('テスト'),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
        ),
      );
    });

    group('実行', () {
      test('有効な入力でマイルストーンが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const goalId = 'goal-123';

        final milestone = await useCase.call(
          title: 'フロントエンド構築',
          deadline: tomorrow,
          goalId: goalId,
        );

        expect(milestone.title.value, 'フロントエンド構築');
        expect(milestone.deadline.value.day, tomorrow.day);
        expect(milestone.goalId.value, goalId);
      });

      test('ID は一意に生成されること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const goalId = 'goal-123';

        final milestone1 = await useCase.call(
          title: 'マイルストーン1',
          deadline: tomorrow,
          goalId: goalId,
        );

        final milestone2 = await useCase.call(
          title: 'マイルストーン2',
          deadline: tomorrow,
          goalId: goalId,
        );

        expect(milestone1.itemId, isNot(equals(milestone2.itemId)));
      });

      test('無効なタイトル（101文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidTitle = 'a' * 101;
        const goalId = 'goal-123';

        expect(
          () => useCase.call(
            title: invalidTitle,
            deadline: tomorrow,
            goalId: goalId,
          ),
          throwsArgumentError,
        );
      });

      test('本日以前の期限でもマイルストーンが作成できること', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        const goalId = 'goal-123';

        expect(
          () =>
              useCase.call(title: 'タイトル', deadline: yesterday, goalId: goalId),
          returnsNormally,
        );
      });

      test('空白のみのタイトルでエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const goalId = 'goal-123';

        expect(
          () => useCase.call(title: '   ', deadline: tomorrow, goalId: goalId),
          throwsArgumentError,
        );
      });

      test('空の goalId でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(
          () => useCase.call(title: 'タイトル', deadline: tomorrow, goalId: ''),
          throwsArgumentError,
        );
      });

      test('1文字のタイトルでマイルストーンが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const goalId = 'goal-123';

        final milestone = await useCase.call(
          title: 'a',
          deadline: tomorrow,
          goalId: goalId,
        );

        expect(milestone.title.value, 'a');
      });

      test('100文字のタイトルでマイルストーンが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxTitle = 'a' * 100;
        const goalId = 'goal-123';

        final milestone = await useCase.call(
          title: maxTitle,
          deadline: tomorrow,
          goalId: goalId,
        );

        expect(milestone.title.value, maxTitle);
      });
    });
  });
}
