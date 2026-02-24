import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/milestone/get_milestones_by_goal_id_use_case.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import '../../../helpers/mock_repositories.dart';

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
          itemId: ItemId.generate(),
          title: ItemTitle('Q1計画'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId(goalId),
        );
        final ms2 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('Q2\u8a08\u753b'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 180))),
          goalId: ItemId(goalId),
        );
        await mockRepository.saveMilestone(ms1);
        await mockRepository.saveMilestone(ms2);

        // Act
        final result = await useCase(goalId);

        // Assert
        expect(result.length, 2);
        expect(
          result.map((m) => m.itemId.value),
          containsAll([ms1.itemId.value, ms2.itemId.value]),
        );
        expect(result.every((m) => m.goalId.value == goalId), true);
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
          itemId: ItemId.generate(),
          title: ItemTitle('Goal1-MS'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId(goalId1),
        );
        final ms2 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('Goal2-MS'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId(goalId2),
        );
        await mockRepository.saveMilestone(ms1);
        await mockRepository.saveMilestone(ms2);

        // Act
        final result1 = await useCase(goalId1);
        final result2 = await useCase(goalId2);

        // Assert
        expect(result1.length, 1);
        expect(result2.length, 1);
        expect(result1.first.itemId.value, ms1.itemId.value);
        expect(result2.first.itemId.value, ms2.itemId.value);
      });

      test('複数マイルストーンを持つゴールをすべて取得できること', () async {
        // Arrange
        const goalId = 'goal-multi-ms';
        final milestones = <Milestone>[];
        for (int i = 1; i <= 5; i++) {
          milestones.add(
            Milestone(
              itemId: ItemId.generate(),
              title: ItemTitle('MS$i'),
              description: ItemDescription(''),
              deadline: ItemDeadline(
                DateTime.now().add(Duration(days: 30 * i)),
              ),
              goalId: ItemId(goalId),
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
          result.map((m) => m.itemId.value),
          containsAll(milestones.map((m) => m.itemId.value)),
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
