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
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/repositories/milestone_repository.dart';






/// MockGoalRepository - ゴールを管理
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
  Future<List<Milestone>> getMilestonesByItemId(String goalId) async =>
      _milestones.where((m) => m.goalId == goalId).toList();

  @override
  Future<void> saveMilestone(Milestone milestone) async =>
      _milestones.add(milestone);

  @override
  Future<void> deleteMilestone(String id) async =>
      _milestones.removeWhere((m) => m.itemId.value == id);

  @override
  Future<void> deleteMilestonesByItemId(String goalId) async =>
      _milestones.removeWhere((m) => m.goalId == goalId);

  @override
  Future<int> getMilestoneCount() async => _milestones.length;
}

void main() {
  group('CreateMilestoneUseCase - 不正な親への追加テスト', () {
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

      // Pre-populate goal-1 for tests
      mockGoalRepository.saveGoal(
        Goal(
          itemId: ItemId('goal-1'),
          title: ItemTitle('テストゴール'),
          category: GoalCategory('ビジネス'),
          description: ItemDescription('テスト用のゴール'),
          deadline: ItemDeadline(DateTime(2026, 12, 31)),
        ),
      );
    });

    test('マイルストーンは ValueObject のバリデーションで作成できる', () async {
      final milestone = await useCase.call(
        title: 'テストマイルストーン',
        deadline: DateTime(2026, 12, 31),
        goalId: ItemId('\'),
      );

      expect(milestone.title.value, 'テストマイルストーン');
      expect(milestone.goalId.value, 'goal-1');
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
          goalId: ItemId('\'),
        ),
        returnsNormally,
      );
    });

    /// NOTE: Phase 3 参照整合性検証（実装完了）
    /// CreateMilestoneUseCase が GoalRepository を注入されて
    /// 存在しないゴール ID のチェックを実装完了
    test('存在しないゴール ID でマイルストーンを作成しようとするとエラー', () async {
      expect(
        () async => await useCase.call(
          title: 'マイルストーン',
          deadline: DateTime(2026, 12, 31),
          goalId: ItemId('\'),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}





