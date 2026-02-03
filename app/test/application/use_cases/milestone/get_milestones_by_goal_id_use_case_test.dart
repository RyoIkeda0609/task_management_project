import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/milestone/get_milestones_by_goal_id_use_case.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';

class MockMilestoneRepository implements MilestoneRepository {
  final List<Milestone> _milestones = [];

  @override
  Future<List<Milestone>> getAllMilestones() async => _milestones;

  @override
  Future<Milestone?> getMilestoneById(String id) async {
    try {
      return _milestones.firstWhere((m) => m.id.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async =>
      _milestones.where((m) => m.goalId == goalId).toList();

  @override
  Future<void> saveMilestone(Milestone milestone) async =>
      _milestones.add(milestone);

  @override
  Future<void> deleteMilestone(String id) async =>
      _milestones.removeWhere((m) => m.id.value == id);

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async =>
      _milestones.removeWhere((m) => m.goalId == goalId);

  @override
  Future<int> getMilestoneCount() async => _milestones.length;
}

void main() {
  group('GetMilestonesByGoalIdUseCase', () {
    late GetMilestonesByGoalIdUseCase useCase;
    late MockMilestoneRepository mockRepository;

    setUp(() {
      mockRepository = MockMilestoneRepository();
      useCase = GetMilestonesByGoalIdUseCaseImpl(mockRepository);
    });

    group('マイルストーン取得', () {
      test('ゴール ID でマイルストーンを取得できること', () async {
        // Arrange
        const goalId = 'goal-123';
        final ms1 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('Q1計画'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: goalId,
        );
        final ms2 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('Q2計画'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 180)),
          ),
          goalId: goalId,
        );
        await mockRepository.saveMilestone(ms1);
        await mockRepository.saveMilestone(ms2);

        // Act
        final result = await useCase(goalId);

        // Assert
        expect(result.length, 2);
        expect(
          result.map((m) => m.id.value),
          containsAll([ms1.id.value, ms2.id.value]),
        );
        expect(result.every((m) => m.goalId == goalId), true);
      });

      test('マイルストーンなしのゴール ID で空リストが返されること', () async {
        // Arrange
        const goalId = 'goal-no-milestones';

        // Act
        final result = await useCase(goalId);

        // Assert
        expect(result, isEmpty);
      });

      test('複数ゴール間のマイルストーン独立性を確認できること', () async {
        // Arrange
        const goalId1 = 'goal-1';
        const goalId2 = 'goal-2';

        final ms1 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('Goal1-MS'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: goalId1,
        );
        final ms2 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('Goal2-MS'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: goalId2,
        );
        await mockRepository.saveMilestone(ms1);
        await mockRepository.saveMilestone(ms2);

        // Act
        final result1 = await useCase(goalId1);
        final result2 = await useCase(goalId2);

        // Assert
        expect(result1.length, 1);
        expect(result2.length, 1);
        expect(result1.first.id.value, ms1.id.value);
        expect(result2.first.id.value, ms2.id.value);
      });

      test('複数マイルストーンを持つゴールをすべて取得できること', () async {
        // Arrange
        const goalId = 'goal-multi-ms';
        final milestones = <Milestone>[];
        for (int i = 1; i <= 5; i++) {
          milestones.add(
            Milestone(
              id: MilestoneId.generate(),
              title: MilestoneTitle('MS$i'),
              deadline: MilestoneDeadline(
                DateTime.now().add(Duration(days: 30 * i)),
              ),
              goalId: goalId,
            ),
          );
        }
        for (final ms in milestones) {
          await mockRepository.saveMilestone(ms);
        }

        // Act
        final result = await useCase(goalId);

        // Assert
        expect(result.length, 5);
        expect(
          result.map((m) => m.id.value),
          containsAll(milestones.map((m) => m.id.value)),
        );
      });
    });

    group('エラーハンドリング', () {
      test('空の Goal ID でエラーが発生すること', () async {
        // Act & Assert
        expect(() => useCase(''), throwsA(isA<ArgumentError>()));
      });
    });
  });
}
