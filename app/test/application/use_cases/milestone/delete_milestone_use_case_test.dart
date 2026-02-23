import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/milestone/delete_milestone_use_case.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';

import 'package:app/domain/value_objects/task/task_status.dart';

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

class MockTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAllTasks() async => _tasks;

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.itemId.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async =>
      _tasks.where((t) => t.milestoneId.value == milestoneId).toList();

  @override
  Future<void> saveTask(Task task) async => _tasks.add(task);

  @override
  Future<void> deleteTask(String id) async =>
      _tasks.removeWhere((t) => t.itemId.value == id);

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async =>
      _tasks.removeWhere((t) => t.milestoneId.value == milestoneId);

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
          itemId: ItemId.generate(),
          title: ItemTitle('削除対象MS'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('milestone-1'),
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        // Act
        await useCase(milestone.itemId.value);

        // Assert
        final deleted = await mockMilestoneRepository.getMilestoneById(
          milestone.itemId.value,
        );
        expect(deleted, isNull);
      });

      test('複数マイルストーン中、指定したマイルストーンだけが削除されること', () async {
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
        await mockMilestoneRepository.saveMilestone(ms1);
        await mockMilestoneRepository.saveMilestone(ms2);

        // Act
        await useCase(ms1.itemId.value);

        // Assert
        expect(
          await mockMilestoneRepository.getMilestoneById(ms1.itemId.value),
          isNull,
        );
        expect(
          await mockMilestoneRepository.getMilestoneById(ms2.itemId.value),
          isNotNull,
        );
      });
    });

    group('カスケード削除：配下タスク削除', () {
      test('マイルストーン削除時、配下のタスクがすべて削除されること', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('milestone-1'),
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        final task1 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo,
          milestoneId: milestone.itemId,
        );
        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク2'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.doing,
          milestoneId: milestone.itemId,
        );
        await mockTaskRepository.saveTask(task1);
        await mockTaskRepository.saveTask(task2);

        // Act
        await useCase(milestone.itemId.value);

        // Assert
        final remainingTasks = await mockTaskRepository.getTasksByMilestoneId(
          milestone.itemId.value,
        );
        expect(remainingTasks, isEmpty);
      });

      test('複数マイルストーンのうち、1つ削除時に他方のタスクは保護されること', () async {
        // Arrange
        const goalId = 'goal-123';
        final ms1 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId(goalId),
        );
        final ms2 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS2'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 180))),
          goalId: ItemId(goalId),
        );
        await mockMilestoneRepository.saveMilestone(ms1);
        await mockMilestoneRepository.saveMilestone(ms2);

        final task1 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('MS1タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo,
          milestoneId: ms1.itemId,
        );
        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('MS2タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 100))),
          status: TaskStatus.todo,
          milestoneId: ms2.itemId,
        );
        await mockTaskRepository.saveTask(task1);
        await mockTaskRepository.saveTask(task2);

        // Act
        await useCase(ms1.itemId.value);

        // Assert
        expect(
          await mockTaskRepository.getTasksByMilestoneId(ms1.itemId.value),
          isEmpty,
        );
        final ms2Tasks = await mockTaskRepository.getTasksByMilestoneId(
          ms2.itemId.value,
        );
        expect(ms2Tasks.length, 1);
        expect(ms2Tasks.first.itemId.value, task2.itemId.value);
      });

      test('複数タスク（複数ステータス）を一括削除できること', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('milestone-1'),
        );
        await mockMilestoneRepository.saveMilestone(milestone);

        final todoTask = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('未開始'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.todo,
          milestoneId: milestone.itemId,
        );
        final doingTask = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('進行中'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.doing,
          milestoneId: milestone.itemId,
        );
        final doneTask = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('完了'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 50))),
          status: TaskStatus.done,
          milestoneId: milestone.itemId,
        );
        await mockTaskRepository.saveTask(todoTask);
        await mockTaskRepository.saveTask(doingTask);
        await mockTaskRepository.saveTask(doneTask);

        // Act
        await useCase(milestone.itemId.value);

        // Assert
        final remaining = await mockTaskRepository.getTasksByMilestoneId(
          milestone.itemId.value,
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
