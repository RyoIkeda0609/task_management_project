import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

void main() {
  group('Task Entity', () {
    late Task task;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      task = Task(
        id: TaskId('task-1'),
        title: TaskTitle('変数を学ぶ'),
        description: TaskDescription('Dartの変数の型と使い方を学ぶ'),
        deadline: TaskDeadline(tomorrow),
        status: TaskStatus.todo(),
        milestoneId: 'milestone-1',
      );
    });

    group('初期化', () {
      test('タスクが正しく初期化できること', () {
        expect(task.id.value, 'task-1');
        expect(task.title.value, '変数を学ぶ');
        expect(task.description.value, 'Dartの変数の型と使い方を学ぶ');
        expect(task.status.value, 'todo');
        expect(task.milestoneId, 'milestone-1');
      });

      test('milestoneIdが正しく設定されること', () {
        expect(task.milestoneId, 'milestone-1');
      });
    });

    group('getProgress', () {
      test('ステータスがTodoの場合、Progress(0)を返すこと', () {
        final todoTask = Task(
          id: TaskId('task-1'),
          title: TaskTitle('テスト'),
          description: TaskDescription('テスト'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-1',
        );
        final progress = todoTask.getProgress();
        expect(progress.value, 0);
      });

      test('ステータスがDoingの場合、Progress(50)を返すこと', () {
        final doingTask = Task(
          id: TaskId('task-1'),
          title: TaskTitle('テスト'),
          description: TaskDescription('テスト'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.doing(),
          milestoneId: 'milestone-1',
        );
        final progress = doingTask.getProgress();
        expect(progress.value, 50);
      });

      test('ステータスがDoneの場合、Progress(100)を返すこと', () {
        final doneTask = Task(
          id: TaskId('task-1'),
          title: TaskTitle('テスト'),
          description: TaskDescription('テスト'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.done(),
          milestoneId: 'milestone-1',
        );
        final progress = doneTask.getProgress();
        expect(progress.value, 100);
      });
    });

    group('cycleStatus', () {
      test('TodoからDoingに遷移できること', () {
        final cycled = task.cycleStatus();
        expect(cycled.status.value, 'doing');
      });

      test('DoingからDoneに遷移できること', () {
        final doingTask = Task(
          id: TaskId('task-1'),
          title: TaskTitle('テスト'),
          description: TaskDescription('テスト'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.doing(),
          milestoneId: 'milestone-1',
        );
        final cycled = doingTask.cycleStatus();
        expect(cycled.status.value, 'done');
      });

      test('DoneからTodoに遷移できること（循環）', () {
        final doneTask = Task(
          id: TaskId('task-1'),
          title: TaskTitle('テスト'),
          description: TaskDescription('テスト'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.done(),
          milestoneId: 'milestone-1',
        );
        final cycled = doneTask.cycleStatus();
        expect(cycled.status.value, 'todo');
      });

      test('cycleStatusで他のフィールドが変わらないこと', () {
        final cycled = task.cycleStatus();
        expect(cycled.id, task.id);
        expect(cycled.title, task.title);
        expect(cycled.description, task.description);
        expect(cycled.deadline, task.deadline);
        expect(cycled.milestoneId, task.milestoneId);
      });

      test('複数回cycleStatusを呼び出すと循環すること', () {
        var cycled = task.cycleStatus(); // todo -> doing
        expect(cycled.status.value, 'doing');

        cycled = cycled.cycleStatus(); // doing -> done
        expect(cycled.status.value, 'done');

        cycled = cycled.cycleStatus(); // done -> todo
        expect(cycled.status.value, 'todo');
      });
    });

    group('等号演算子とhashCode', () {
      test('同じフィールドを持つTaskは等価であること', () {
        final task2 = Task(
          id: TaskId('task-1'),
          title: TaskTitle('変数を学ぶ'),
          description: TaskDescription('Dartの変数の型と使い方を学ぶ'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-1',
        );
        expect(task, task2);
      });

      test('異なるIDを持つTaskは等価でないこと', () {
        final task2 = Task(
          id: TaskId('task-2'),
          title: TaskTitle('変数を学ぶ'),
          description: TaskDescription('Dartの変数の型と使い方を学ぶ'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-1',
        );
        expect(task, isNot(task2));
      });

      test('異なるステータスを持つTaskは等価でないこと', () {
        final task2 = Task(
          id: TaskId('task-1'),
          title: TaskTitle('変数を学ぶ'),
          description: TaskDescription('Dartの変数の型と使い方を学ぶ'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.doing(),
          milestoneId: 'milestone-1',
        );
        expect(task, isNot(task2));
      });

      test('異なるmilestoneIdを持つTaskは等価でないこと', () {
        final task2 = Task(
          id: TaskId('task-1'),
          title: TaskTitle('変数を学ぶ'),
          description: TaskDescription('Dartの変数の型と使い方を学ぶ'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-2',
        );
        expect(task, isNot(task2));
      });

      test('同じTaskはHashCodeが同じであること', () {
        final task2 = Task(
          id: TaskId('task-1'),
          title: TaskTitle('変数を学ぶ'),
          description: TaskDescription('Dartの変数の型と使い方を学ぶ'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-1',
        );
        expect(task.hashCode, task2.hashCode);
      });
    });

    group('toString', () {
      test('toStringが適切な文字列を返すこと', () {
        final string = task.toString();
        expect(string, contains('Task'));
        expect(string, contains('task-1'));
        expect(string, contains('変数を学ぶ'));
        expect(string, contains('todo'));
      });
    });
  });
}
