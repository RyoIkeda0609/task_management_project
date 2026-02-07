import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

void main() {
  group('Task - ステータス遷移と進捗計算テスト', () {
    test('Task の初期ステータスは todo', () {
      final task = Task(
        id: TaskId('task-1'),
        title: TaskTitle('テストタスク'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.todo(),
        milestoneId: 'milestone-1',
      );

      expect(task.status.value, 'todo');
      expect(task.getProgress().value, 0);
    });

    test('Task のステータスが doing の場合、進捗は 50%', () {
      final task = Task(
        id: TaskId('task-1'),
        title: TaskTitle('テストタスク'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.doing(),
        milestoneId: 'milestone-1',
      );

      expect(task.status.value, 'doing');
      expect(task.getProgress().value, 50);
    });

    test('Task のステータスが done の場合、進捗は 100%', () {
      final task = Task(
        id: TaskId('task-1'),
        title: TaskTitle('テストタスク'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.done(),
        milestoneId: 'milestone-1',
      );

      expect(task.status.value, 'done');
      expect(task.getProgress().value, 100);
    });

    test('Task のステータスは todo から doing に遷移できる', () {
      final task = Task(
        id: TaskId('task-1'),
        title: TaskTitle('テストタスク'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.todo(),
        milestoneId: 'milestone-1',
      );

      final updatedTask = task.cycleStatus();

      expect(updatedTask.status.value, 'doing');
      expect(updatedTask.getProgress().value, 50);
    });

    test('Task のステータスは doing から done に遷移できる', () {
      final task = Task(
        id: TaskId('task-1'),
        title: TaskTitle('テストタスク'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.doing(),
        milestoneId: 'milestone-1',
      );

      final updatedTask = task.cycleStatus();

      expect(updatedTask.status.value, 'done');
      expect(updatedTask.getProgress().value, 100);
    });

    test('Task のステータスは done から todo に循環遷移', () {
      final task = Task(
        id: TaskId('task-1'),
        title: TaskTitle('テストタスク'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.done(),
        milestoneId: 'milestone-1',
      );

      final updatedTask = task.cycleStatus();

      expect(updatedTask.status.value, 'todo');
      expect(updatedTask.getProgress().value, 0);
    });

    test('Task の進捗は完全に自動計算される', () {
      final statuses = [
        TaskStatus.todo(),
        TaskStatus.doing(),
        TaskStatus.done(),
      ];
      final expectedProgress = [0, 50, 100];

      for (int i = 0; i < statuses.length; i++) {
        final task = Task(
          id: TaskId('task-$i'),
          title: TaskTitle('テストタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          status: statuses[i],
          milestoneId: 'milestone-1',
        );

        expect(
          task.getProgress().value,
          expectedProgress[i],
          reason:
              'Status ${statuses[i].value} should have progress ${expectedProgress[i]}%',
        );
      }
    });

    test('複数の Task インスタンスは独立している', () {
      final task1 = Task(
        id: TaskId('task-1'),
        title: TaskTitle('タスク1'),
        description: TaskDescription('説明1'),
        deadline: TaskDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.todo(),
        milestoneId: 'milestone-1',
      );

      final task2 = Task(
        id: TaskId('task-2'),
        title: TaskTitle('タスク2'),
        description: TaskDescription('説明2'),
        deadline: TaskDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.doing(),
        milestoneId: 'milestone-1',
      );

      expect(task1.getProgress().value, 0);
      expect(task2.getProgress().value, 50);
    });

    test('Task の親 milestoneId は不変である', () {
      final task = Task(
        id: TaskId('task-1'),
        title: TaskTitle('テストタスク'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.todo(),
        milestoneId: 'milestone-1',
      );

      final updatedTask = task.cycleStatus();

      // milestoneId は変わらない
      expect(updatedTask.milestoneId, 'milestone-1');
    });

    test('Task の id は不変である', () {
      final task = Task(
        id: TaskId('task-1'),
        title: TaskTitle('テストタスク'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(DateTime(2026, 12, 31)),
        status: TaskStatus.todo(),
        milestoneId: 'milestone-1',
      );

      final updatedTask = task.cycleStatus();

      // ID は変わらない
      expect(updatedTask.id.value, 'task-1');
    });
  });
}
