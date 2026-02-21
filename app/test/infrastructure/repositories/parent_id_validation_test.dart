import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

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

  Future<List<Task>> getTasksByDeadline(DateTime deadline) async =>
      _tasks.where((t) => t.deadline.value.day == deadline.day).toList();
}

void main() {
  group('存在しないID への操作テスト - 構造違反検出', () {
    late MockMilestoneRepository milestoneRepository;
    late MockTaskRepository taskRepository;

    setUp(() {
      milestoneRepository = MockMilestoneRepository();
      taskRepository = MockTaskRepository();
    });

    test('存在しないマイルストーン ID でタスクを検索すると空リスト', () async {
      final tasks = await taskRepository.getTasksByMilestoneId(
        'nonexistent-milestone-id',
      );
      expect(tasks, isEmpty);
    });

    test('存在しないタスク ID を削除してもエラーが発生しない', () async {
      expect(
        () async => await taskRepository.deleteTask('nonexistent-task-id'),
        returnsNormally,
      );
    });

    test('存在しないマイルストーン ID で関連タスクを削除してもエラーが発生しない', () async {
      expect(
        () async => await taskRepository.deleteTasksByMilestoneId(
          'nonexistent-milestone-id',
        ),
        returnsNormally,
      );
    });

    test('タスクを保存し、その後に削除できる', () async {
      final task = Task(
        itemId: ItemId('task-1'),
        title: ItemTitle('テストタスク'),
        description: ItemDescription('説明'),
        deadline: ItemDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.todo(),
        milestoneId: ItemId('milestone-1'),
      );

      await taskRepository.saveTask(task);
      var retrieved = await taskRepository.getTaskById('task-1');
      expect(retrieved, isNotNull);

      await taskRepository.deleteTask('task-1');
      retrieved = await taskRepository.getTaskById('task-1');
      expect(retrieved, isNull);
    });

    test('存在しないマイルストーン ID の取得は null を返す', () async {
      final milestone = await milestoneRepository.getMilestoneById(
        'nonexistent-milestone-id',
      );
      expect(milestone, isNull);
    });

    test('マイルストーンを保存し、その後に削除できる', () async {
      final milestone = Milestone(
        itemId: ItemId('milestone-1'),
        title: ItemTitle('テストマイルストーン'),
        description: ItemDescription(''),
        deadline: ItemDeadline(DateTime(2026, 12, 31)),
        goalId: ItemId('goal-1'),
      );

      await milestoneRepository.saveMilestone(milestone);
      var retrieved = await milestoneRepository.getMilestoneById('milestone-1');
      expect(retrieved, isNotNull);

      await milestoneRepository.deleteMilestone('milestone-1');
      retrieved = await milestoneRepository.getMilestoneById('milestone-1');
      expect(retrieved, isNull);
    });

    test('複数のタスクを保存し、マイルストーン ID で フィルタリングできる', () async {
      final task1 = Task(
        itemId: ItemId('task-1'),
        title: ItemTitle('タスク1'),
        description: ItemDescription('説明1'),
        deadline: ItemDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.todo(),
        milestoneId: ItemId('milestone-1'),
      );

      final task2 = Task(
        itemId: ItemId('task-2'),
        title: ItemTitle('タスク2'),
        description: ItemDescription('説明2'),
        deadline: ItemDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.todo(),
        milestoneId: ItemId('milestone-2'),
      );

      await taskRepository.saveTask(task1);
      await taskRepository.saveTask(task2);

      final tasksForMilestone1 = await taskRepository.getTasksByMilestoneId(
        'milestone-1',
      );
      final tasksForMilestone2 = await taskRepository.getTasksByMilestoneId(
        'milestone-2',
      );

      expect(tasksForMilestone1, hasLength(1));
      expect(tasksForMilestone2, hasLength(1));
      expect(tasksForMilestone1.first.itemId.value, 'task-1');
      expect(tasksForMilestone2.first.itemId.value, 'task-2');
    });

    test('複数のマイルストーンを保存し、ゴール ID で フィルタリングできる', () async {
      final milestone1 = Milestone(
        itemId: ItemId('milestone-1'),
        title: ItemTitle('マイルストーン1'),
        description: ItemDescription(''),
        deadline: ItemDeadline(DateTime(2026, 12, 31)),
        goalId: ItemId('goal-1'),
      );

      final milestone2 = Milestone(
        itemId: ItemId('milestone-2'),
        title: ItemTitle('マイルストーン2'),
        description: ItemDescription(''),
        deadline: ItemDeadline(DateTime(2026, 12, 31)),
        goalId: ItemId('goal-2'),
      );

      await milestoneRepository.saveMilestone(milestone1);
      await milestoneRepository.saveMilestone(milestone2);

      final milestonesForGoal1 = await milestoneRepository
          .getMilestonesByGoalId('goal-1');
      final milestonesForGoal2 = await milestoneRepository
          .getMilestonesByGoalId('goal-2');

      expect(milestonesForGoal1, hasLength(1));
      expect(milestonesForGoal2, hasLength(1));
      expect(milestonesForGoal1.first.itemId.value, 'milestone-1');
      expect(milestonesForGoal2.first.itemId.value, 'milestone-2');
    });
  });
}
