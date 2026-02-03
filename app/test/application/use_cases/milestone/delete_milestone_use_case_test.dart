import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/milestone/delete_milestone_use_case.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

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

class MockTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAllTasks() async => _tasks;

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.id.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async =>
      _tasks.where((t) => t.milestoneId == milestoneId).toList();

  @override
  Future<void> saveTask(Task task) async => _tasks.add(task);

  @override
  Future<void> deleteTask(String id) async =>
      _tasks.removeWhere((t) => t.id.value == id);

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async =>
      _tasks.removeWhere((t) => t.milestoneId == milestoneId);

  @override
  Future<int> getTaskCount() async => _tasks.length;
}

void main() {
  group('DeleteMilestoneUseCase', () {
    late DeleteMilestoneUseCase useCase;
    late MockMilestoneRepository mockMilestoneRepository;
    late MockTaskRepository mockTaskRepository;

    setUp(() {
      mockMilestoneRepository = MockMilestoneRepository();
      mockTaskRepository = MockTaskRepository();
      useCase = DeleteMilestoneUseCaseImpl(
        mockMilestoneRepository,
        mockTaskRepository,
      );
    });

    group('マイルストーン削除', () {
      test('マイルストーンが削除できること', () async {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('削除対象MS'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: 'goal-123',
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        // Act
        await useCase(milestone.id.value);

        // Assert
        final deleted = await mockMilestoneRepository.getMilestoneById(
          milestone.id.value,
        );
        expect(deleted, isNull);
      });

      test('複数マイルストーン中、指定したマイルストーンだけが削除されること', () async {
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
        await mockMilestoneRepository.saveMilestone(ms1);
        await mockMilestoneRepository.saveMilestone(ms2);

        // Act
        await useCase(ms1.id.value);

        // Assert
        expect(
          await mockMilestoneRepository.getMilestoneById(ms1.id.value),
          isNull,
        );
        expect(
          await mockMilestoneRepository.getMilestoneById(ms2.id.value),
          isNotNull,
        );
      });
    });

    group('カスケード削除：配下タスク削除', () {
      test('マイルストーン削除時、配下のタスクがすべて削除されること', () async {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: 'goal-123',
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        final task1 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo(),
          milestoneId: milestone.id.value,
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.doing(),
          milestoneId: milestone.id.value,
        );
        await mockTaskRepository.saveTask(task1);
        await mockTaskRepository.saveTask(task2);

        // Act
        await useCase(milestone.id.value);

        // Assert
        final remainingTasks = await mockTaskRepository.getTasksByMilestoneId(
          milestone.id.value,
        );
        expect(remainingTasks, isEmpty);
      });

      test('複数マイルストーンのうち、1つ削除時に他方のタスクは保護されること', () async {
        // Arrange
        const goalId = 'goal-123';
        final ms1 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS1'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: goalId,
        );
        final ms2 = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS2'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 180)),
          ),
          goalId: goalId,
        );
        await mockMilestoneRepository.saveMilestone(ms1);
        await mockMilestoneRepository.saveMilestone(ms2);

        final task1 = Task(
          id: TaskId.generate(),
          title: TaskTitle('MS1タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo(),
          milestoneId: ms1.id.value,
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('MS2タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 100))),
          status: TaskStatus.todo(),
          milestoneId: ms2.id.value,
        );
        await mockTaskRepository.saveTask(task1);
        await mockTaskRepository.saveTask(task2);

        // Act
        await useCase(ms1.id.value);

        // Assert
        expect(
          await mockTaskRepository.getTasksByMilestoneId(ms1.id.value),
          isEmpty,
        );
        final ms2Tasks = await mockTaskRepository.getTasksByMilestoneId(
          ms2.id.value,
        );
        expect(ms2Tasks.length, 1);
        expect(ms2Tasks.first.id.value, task2.id.value);
      });

      test('複数タスク（複数ステータス）を一括削除できること', () async {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('MS'),
          deadline: MilestoneDeadline(
            DateTime.now().add(const Duration(days: 90)),
          ),
          goalId: 'goal-123',
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        final todoTask = Task(
          id: TaskId.generate(),
          title: TaskTitle('未開始'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo(),
          milestoneId: milestone.id.value,
        );
        final doingTask = Task(
          id: TaskId.generate(),
          title: TaskTitle('進行中'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.doing(),
          milestoneId: milestone.id.value,
        );
        final doneTask = Task(
          id: TaskId.generate(),
          title: TaskTitle('完了'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done(),
          milestoneId: milestone.id.value,
        );
        await mockTaskRepository.saveTask(todoTask);
        await mockTaskRepository.saveTask(doingTask);
        await mockTaskRepository.saveTask(doneTask);

        // Act
        await useCase(milestone.id.value);

        // Assert
        final remaining = await mockTaskRepository.getTasksByMilestoneId(
          milestone.id.value,
        );
        expect(remaining, isEmpty);
      });
    });

    group('エラーハンドリング', () {
      test('存在しないマイルストーン ID での削除でエラーが発生すること', () async {
        // Act & Assert
        expect(() => useCase('non-existent-id'), throwsA(isA<ArgumentError>()));
      });

      test('空のマイルストーン ID でエラーが発生すること', () async {
        // Act & Assert
        expect(() => useCase(''), throwsA(isA<ArgumentError>()));
      });
    });
  });
}
