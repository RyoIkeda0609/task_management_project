import 'package:app/domain/value_objects/shared/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/milestone/update_milestone_use_case.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/services/milestone_completion_service.dart';
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
  Future<void> saveMilestone(Milestone milestone) async {
    _milestones.removeWhere((m) => m.id.value == milestone.id.value);
    _milestones.add(milestone);
  }

  @override
  Future<void> deleteMilestone(String id) async =>
      _milestones.removeWhere((m) => m.id.value == id);

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async =>
      _milestones.removeWhere((m) => m.goalId == goalId);

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
          id: MilestoneId.generate(),
          title: MilestoneTitle('元のタイトル'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: 'goal-123',
        );
        await mockRepository.saveMilestone(original);

        final newDeadline = DateTime.now().add(const Duration(days: 120));

        // Act
        final updated = await useCase(
          milestoneId: original.id.value,
          title: '新しいタイトル',
          deadline: newDeadline,
        );

        // Assert
        expect(updated.title.value, '新しいタイトル');
        expect(updated.deadline.value.day, newDeadline.day);
        expect(updated.id.value, original.id.value);
      });

      test('マイルストーンのタイトルのみを更新できること', () async {
        // Arrange
        final original = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('元のタイトル'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: 'goal-123',
        );
        await mockRepository.saveMilestone(original);

        // Act
        final updated = await useCase(
          milestoneId: original.id.value,
          title: '更新後のタイトル',
          deadline: original.deadline.value,
        );

        // Assert
        expect(updated.title.value, '更新後のタイトル');
      });

      test('マイルストーンのデッドラインのみを更新できること', () async {
        // Arrange
        final original = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('タイトル'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: 'goal-123',
        );
        await mockRepository.saveMilestone(original);

        final newDeadline = DateTime.now().add(const Duration(days: 120));

        // Act
        final updated = await useCase(
          milestoneId: original.id.value,
          title: original.title.value,
          deadline: newDeadline,
        );

        // Assert
        expect(updated.title.value, original.title.value);
        expect(updated.deadline.value.day, newDeadline.day);
      });

      test('複数のマイルストーンの更新が独立していること', () async {
        // Arrange
        final ms1 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS1'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: 'goal-123',
        );
        final ms2 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS2'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 180)),
          ),
          goalId: 'goal-123',
        );
        await mockRepository.saveMilestone(ms1);
        await mockRepository.saveMilestone(ms2);

        // Act
        await useCase(
          milestoneId: ms1.id.value,
          title: '更新後のMS1',
          deadline: ms1.deadline.value,
        );

        // Assert
        final unchanged = await mockRepository.getMilestoneById(ms2.id.value);
        expect(unchanged?.title.value, 'MS2');
      });
    });

    group('入力値検証', () {
      test('無効なタイトル（空文字）で更新がエラーになること', () async {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('タイトル'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: 'goal-123',
        );
        await mockRepository.saveMilestone(milestone);

        // Act & Assert
        expect(
          () => useCase(
            milestoneId: milestone.id.value,
            title: '',
            deadline: milestone.deadline.value,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('タイトルが100文字を超える場合はエラーになること', () async {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('タイトル'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: 'goal-123',
        );
        await mockRepository.saveMilestone(milestone);

        // Act & Assert
        expect(
          () => useCase(
            milestoneId: milestone.id.value,
            title: 'a' * 101,
            deadline: milestone.deadline.value,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('デッドラインが過去の日付でも更新できること', () async {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('タイトル'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: 'goal-123',
        );
        await mockRepository.saveMilestone(milestone);

        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        expect(
          () => useCase(
            milestoneId: milestone.id.value,
            title: milestone.title.value,
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
            deadline: DateTime.now().add(const Duration(days: 90)),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
