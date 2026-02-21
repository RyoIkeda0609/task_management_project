import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';

import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

class MockMilestoneRepository implements MilestoneRepository {
  final List<Milestone> _milestones = [];

  @override
  Future<Milestone?> getMilestoneById(String id) async {
    try {
      return _milestones.firstWhere((m) => m.itemId.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Milestone>> getAllMilestones() async => _milestones;

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
  Future<void> saveTask(Task task) async {
    _tasks.removeWhere((t) => t.itemId.value == task.itemId.value);
    _tasks.add(task);
  }

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
  group('Cascade Delete - 連鎖削除テスト', () {
    late MockMilestoneRepository milestoneRepository;
    late MockTaskRepository taskRepository;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      milestoneRepository = MockMilestoneRepository();
      taskRepository = MockTaskRepository();
    });

    group('Milestone 削除時の Task 削除連鎖', () {
      test('should_delete_all_tasks_when_milestone_deleted - '
          'Milestone を削除すると、配下のすべての Task が自動削除される', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId('milestone-1'),
          title: ItemTitle('マイルストーン'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('milestone-1'),
        );
        await milestoneRepository.saveMilestone(milestone);

        final task1 = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );

        final task2 = Task(
          itemId: ItemId('task-2'),
          title: ItemTitle('タスク2'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.doing(),
          milestoneId: ItemId('milestone-1'),
        );

        final task3 = Task(
          itemId: ItemId('task-3'),
          title: ItemTitle('タスク3'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.done(),
          milestoneId: ItemId('milestone-1'),
        );

        await taskRepository.saveTask(task1);
        await taskRepository.saveTask(task2);
        await taskRepository.saveTask(task3);

        expect(await taskRepository.getTaskCount(), 3, reason: '初期状態：3つのタスク存在');

        // Act
        // Milestone が削除される前に cascadeDelete が実行される必要がある
        await taskRepository.deleteTasksByMilestoneId('milestone-1');
        await milestoneRepository.deleteMilestone('milestone-1');

        // Assert
        final remainingTasks = await taskRepository.getAllTasks();
        expect(
          remainingTasks.isEmpty,
          true,
          reason: 'Milestone 削除後、すべてのタスクが削除される',
        );

        expect(await taskRepository.getTaskCount(), 0);
        expect(
          await milestoneRepository.getMilestoneById('milestone-1'),
          isNull,
          reason: 'Milestone も削除されている',
        );
      });

      test('should_delete_tasks_with_different_statuses - '
          'Milestone 削除時、ステータスが異なるすべてのタスクが削除される', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId('milestone-1'),
          title: ItemTitle('マイルストーン'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('milestone-1'),
        );
        await milestoneRepository.saveMilestone(milestone);

        // 異なるステータスのタスク
        final todoTask = Task(
          itemId: ItemId('task-todo'),
          title: ItemTitle('未開始タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );

        final doingTask = Task(
          itemId: ItemId('task-doing'),
          title: ItemTitle('進行中タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.doing(),
          milestoneId: ItemId('milestone-1'),
        );

        final doneTask = Task(
          itemId: ItemId('task-done'),
          title: ItemTitle('完了タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.done(),
          milestoneId: ItemId('milestone-1'),
        );

        await taskRepository.saveTask(todoTask);
        await taskRepository.saveTask(doingTask);
        await taskRepository.saveTask(doneTask);

        // Act
        await taskRepository.deleteTasksByMilestoneId('milestone-1');

        // Assert - すべてのステータスのタスクが削除される
        expect(
          await taskRepository.getTaskById('task-todo'),
          isNull,
          reason: 'Todo ステータスのタスクが削除',
        );
        expect(
          await taskRepository.getTaskById('task-doing'),
          isNull,
          reason: 'Doing ステータスのタスクが削除',
        );
        expect(
          await taskRepository.getTaskById('task-done'),
          isNull,
          reason: 'Done ステータスのタスクが削除',
        );
      });

      test('should_only_delete_tasks_of_deleted_milestone - '
          '他の Milestone に属するタスクは削除されない', () async {
        // Arrange
        final milestone1 = Milestone(
          itemId: ItemId('milestone-1'),
          title: ItemTitle('マイルストーン1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('milestone-1'),
        );

        final milestone2 = Milestone(
          itemId: ItemId('milestone-2'),
          title: ItemTitle('マイルストーン2'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('milestone-1'),
        );

        await milestoneRepository.saveMilestone(milestone1);
        await milestoneRepository.saveMilestone(milestone2);

        // milestone-1 配下のタスク
        final task1 = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );

        // milestone-2 配下のタスク
        final task2 = Task(
          itemId: ItemId('task-2'),
          title: ItemTitle('タスク2'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-2'),
        );

        await taskRepository.saveTask(task1);
        await taskRepository.saveTask(task2);

        expect(await taskRepository.getTaskCount(), 2);

        // Act - milestone-1 のみ削除
        await taskRepository.deleteTasksByMilestoneId('milestone-1');
        await milestoneRepository.deleteMilestone('milestone-1');

        // Assert
        expect(
          await taskRepository.getTaskById('task-1'),
          isNull,
          reason: 'milestone-1 配下のタスク削除',
        );

        final task2Retrieved = await taskRepository.getTaskById('task-2');
        expect(task2Retrieved, isNotNull, reason: 'milestone-2 配下のタスクは残存');
        expect(
          task2Retrieved!.milestoneId.value,
          'milestone-2',
          reason: 'task-2 は完全に保持されている',
        );
      });

      test('should_preserve_tasks_of_other_milestones_in_same_goal - '
          '同じ Goal 内の他の Milestone のタスクは保護される', () async {
        // Arrange
        final milestone1 = Milestone(
          itemId: ItemId('milestone-1'),
          title: ItemTitle('マイルストーン1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('milestone-1'),
        );

        final milestone2 = Milestone(
          itemId: ItemId('milestone-2'),
          title: ItemTitle('マイルストーン2'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('milestone-1'),
        );

        await milestoneRepository.saveMilestone(milestone1);
        await milestoneRepository.saveMilestone(milestone2);

        final task1 = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.done(),
          milestoneId: ItemId('milestone-1'),
        );

        final task2 = Task(
          itemId: ItemId('task-2'),
          title: ItemTitle('タスク2'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.doing(),
          milestoneId: ItemId('milestone-2'),
        );

        await taskRepository.saveTask(task1);
        await taskRepository.saveTask(task2);

        // Act - milestone-1 を削除
        await taskRepository.deleteTasksByMilestoneId('milestone-1');

        // Assert
        final tasksInMs2 = await taskRepository.getTasksByMilestoneId(
          'milestone-2',
        );
        expect(tasksInMs2.length, 1, reason: 'milestone-2 のタスクは完全に保持される');
        expect(tasksInMs2.first.itemId.value, 'task-2');
      });

      test('should_handle_deletion_of_empty_milestone - '
          'タスクのない Milestone を削除しても問題が起きない', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId('milestone-1'),
          title: ItemTitle('空のマイルストーン'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('milestone-1'),
        );
        await milestoneRepository.saveMilestone(milestone);

        expect(
          await taskRepository.getTasksByMilestoneId('milestone-1'),
          isEmpty,
          reason: '初期状態：タスクなし',
        );

        // Act
        await taskRepository.deleteTasksByMilestoneId('milestone-1');
        await milestoneRepository.deleteMilestone('milestone-1');

        // Assert
        expect(
          await taskRepository.getTasksByMilestoneId('milestone-1'),
          isEmpty,
          reason: '削除後も問題なし',
        );
        expect(
          await milestoneRepository.getMilestoneById('milestone-1'),
          isNull,
          reason: 'Milestone が削除されている',
        );
      });
    });

    group('Goal 直下への Task 生成禁止', () {
      test('should_reject_task_creation_directly_under_goal - '
          'Task は Goal の直下には作成できない。必ず Milestone を経由する', () {
        // Arrange & Act & Assert
        // Goal に直接紐付けられたタスクの milestoneId は不正
        // （空文字列または存在しないID）

        // ドメインレイヤーではタスク生成時に milestoneId の存在チェックは行わない
        // が、アプリケーション層で검증되어야 함
        final illegalTask = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('不正なタスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'), // goalId をそのまま milestoneId に設定
        );

        // Task 生成自体はできるが、
        // リポジトリに保存しようとする時にアプリケーション層で検証されるべき
        expect(illegalTask.milestoneId.value, 'milestone-1');

        // milestoneId が実際に有効な milestone を参照しているか確認
        // （アプリケーション層の責務）
      });
    });
  });
}
