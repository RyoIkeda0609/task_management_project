import 'package:app/domain/value_objects/shared/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/milestone/update_milestone_use_case.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/services/milestone_completion_service.dart';

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
  Future<void> saveMilestone(Milestone milestone) async {
    _milestones.removeWhere((m) => m.itemId.value == milestone.itemId.value);
    _milestones.add(milestone);
  }

  @override
  Future<void> deleteMilestone(String id) async =>
      _milestones.removeWhere((m) => m.itemId.value == id);

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async =>
      _milestones.removeWhere((m) => m.goalId.value == goalId);

  @override
  Future<int> getMilestoneCount() async => _milestones.length;
}

class MockMilestoneCompletionService implements MilestoneCompletionService {
  @override
  Future<bool> isMilestoneCompleted(String milestoneId) async {
    // For testing: by default, no milestone is marked as completed
    return false;
  }

  @override
  Future<Progress> calculateMilestoneProgress(String milestoneId) async {
    return Progress(0);
  }
}

void main() {
  group('UpdateMilestoneUseCase', () {
    late UpdateMilestoneUseCase useCase;
    late MockMilestoneRepository mockRepository;
    late MockMilestoneCompletionService mockCompletionService;

    setUp(() {
      mockRepository = MockMilestoneRepository();
      mockCompletionService = MockMilestoneCompletionService();
      useCase = UpdateMilestoneUseCaseImpl(
        mockRepository,
        mockCompletionService,
      );
    });

    group('マイルストーン更新', () {
      test('マイルストーンを更新できること', () async {
        // Arrange
        final original = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('元のタイトル'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('milestone-1'),
        );
        await mockRepository.saveMilestone(original);

        final newDeadline = DateTime.now().add(const Duration(days: 120));

        // Act
        final updated = await useCase(
          milestoneId: original.itemId.value,
          title: '新しいタイトル',
          description: '',
          deadline: newDeadline,
        );

        // Assert
        expect(updated.title.value, '新しいタイトル');
        expect(updated.deadline.value.day, newDeadline.day);
        expect(updated.itemId.value, original.itemId.value);
      });

      test('マイルストーンのタイトルのみを更新できること', () async {
        // Arrange
        final original = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('元のタイトル'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('milestone-1'),
        );
        await mockRepository.saveMilestone(original);

        // Act
        final updated = await useCase(
          milestoneId: original.itemId.value,
          title: '更新後のタイトル',
          description: '',
          deadline: original.deadline.value,
        );

        // Assert
        expect(updated.title.value, '更新後のタイトル');
      });

      test('マイルストーンのデッドラインのみを更新できること', () async {
        // Arrange
        final original = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('タイトル'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('milestone-1'),
        );
        await mockRepository.saveMilestone(original);

        final newDeadline = DateTime.now().add(const Duration(days: 120));

        // Act
        final updated = await useCase(
          milestoneId: original.itemId.value,
          title: original.title.value,
          description: '',
          deadline: newDeadline,
        );

        // Assert
        expect(updated.title.value, original.title.value);
        expect(updated.deadline.value.day, newDeadline.day);
      });

      test('複数のマイルストーンの更新が独立していること', () async {
        // Arrange
        final ms1 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('milestone-1'),
        );
        final ms2 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS2'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 180))),
          goalId: ItemId('milestone-1'),
        );
        await mockRepository.saveMilestone(ms1);
        await mockRepository.saveMilestone(ms2);

        // Act
        await useCase(
          milestoneId: ms1.itemId.value,
          title: '更新後のMS1',
          description: '',
          deadline: ms1.deadline.value,
        );

        // Assert
        final unchanged = await mockRepository.getMilestoneById(
          ms2.itemId.value,
        );
        expect(unchanged?.title.value, 'MS2');
      });
    });

    group('入力値検証', () {
      test('無効なタイトル（空文字）で更新がエラーになること', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('タイトル'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('milestone-1'),
        );
        await mockRepository.saveMilestone(milestone);

        // Act & Assert
        expect(
          () => useCase(
            milestoneId: milestone.itemId.value,
            title: '',
            description: '',
            deadline: milestone.deadline.value,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('タイトルが100文字を超える場合はエラーになること', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('タイトル'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('milestone-1'),
        );
        await mockRepository.saveMilestone(milestone);

        // Act & Assert
        expect(
          () => useCase(
            milestoneId: milestone.itemId.value,
            title: 'a' * 101,
            description: '',
            deadline: milestone.deadline.value,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('デッドラインが過去の日付でも更新できること', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('タイトル'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('milestone-1'),
        );
        await mockRepository.saveMilestone(milestone);

        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        expect(
          () => useCase(
            milestoneId: milestone.itemId.value,
            title: milestone.title.value,
            description: '',
            deadline: yesterday,
          ),
          returnsNormally,
        );
      });
    });

    group('エラーハンドリング', () {
      test('存在しないマイルストーン ID での更新でエラーが発生すること', () async {
        // Act & Assert
        expect(
          () => useCase(
            milestoneId: 'non-existent-id',
            title: 'タイトル',
            description: '',
            deadline: DateTime.now().add(const Duration(days: 90)),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('空のマイルストーン ID でエラーが発生すること', () async {
        // Act & Assert
        expect(
          () => useCase(
            milestoneId: '',
            title: 'タイトル',
            description: '',
            deadline: DateTime.now().add(const Duration(days: 90)),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
