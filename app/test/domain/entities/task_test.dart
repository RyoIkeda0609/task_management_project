import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/value_objects/shared/progress.dart';

void main() {
  group('Task Entity', () {
    late Task task;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      task = Task(
        itemId: ItemId('task-1'),
        title: ItemTitle('変数を学ぶ'),
        description: ItemDescription('Dartの変数の型と使い方を学ぶ'),
        deadline: ItemDeadline(tomorrow),
        status: TaskStatus.todo(),
        milestoneId: ItemId('milestone-1'),
      );
    });

    group('初期化', () {
      test('タスクが正しく初期化できること', () {
        expect(task.itemId.value, 'task-1');
        expect(task.title.value, '変数を学ぶ');
        expect(task.description.value, 'Dartの変数の型と使い方を学ぶ');
        expect(task.status.value, 'todo');
        expect(task.milestoneId.value, 'milestone-1');
      });

      test('milestoneIdが正しく設定されること', () {
        expect(task.milestoneId.value, 'milestone-1');
      });
    });

    group('getProgress', () {
      test('ステータスがTodoの場合、Progress(0)を返すこと', () {
        final todoTask = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('テスト'),
          description: ItemDescription('テスト'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );
        final progress = todoTask.getProgress();
        expect(progress.value, 0);
      });

      test('ステータスがDoingの場合、Progress(50)を返すこと', () {
        final doingTask = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('テスト'),
          description: ItemDescription('テスト'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.doing(),
          milestoneId: ItemId('milestone-1'),
        );
        final progress = doingTask.getProgress();
        expect(progress.value, 50);
      });

      test('ステータスがDoneの場合、Progress(100)を返すこと', () {
        final doneTask = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('テスト'),
          description: ItemDescription('テスト'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.done(),
          milestoneId: ItemId('milestone-1'),
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
          itemId: ItemId('task-1'),
          title: ItemTitle('テスト'),
          description: ItemDescription('テスト'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.doing(),
          milestoneId: ItemId('milestone-1'),
        );
        final cycled = doingTask.cycleStatus();
        expect(cycled.status.value, 'done');
      });

      test('DoneからTodoに遷移できること（循環）', () {
        final doneTask = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('テスト'),
          description: ItemDescription('テスト'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.done(),
          milestoneId: ItemId('milestone-1'),
        );
        final cycled = doneTask.cycleStatus();
        expect(cycled.status.value, 'todo');
      });

      test('cycleStatusは他のプロパティを保持すること', () {
        final cycled = task.cycleStatus();
        expect(cycled.itemId, task.itemId);
        expect(cycled.title, task.title);
        expect(cycled.description, task.description);
        expect(cycled.deadline, task.deadline);
        expect(cycled.milestoneId, task.milestoneId);
      });
    });

    group('等号演算子とhashCode', () {
      test('同じフィールドを持つTaskは等価であること', () {
        final task2 = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('変数を学ぶ'),
          description: ItemDescription('Dartの変数の型と使い方を学ぶ'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );
        expect(task, task2);
      });

      test('異なるIDを持つTaskは等価でないこと', () {
        final task2 = Task(
          itemId: ItemId('task-2'),
          title: ItemTitle('変数を学ぶ'),
          description: ItemDescription('Dartの変数の型と使い方を学ぶ'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );
        expect(task, isNot(task2));
      });

      test('異なるステータスを持つTaskは等価でないこと', () {
        final task2 = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('変数を学ぶ'),
          description: ItemDescription('Dartの変数の型と使い方を学ぶ'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.doing(),
          milestoneId: ItemId('milestone-1'),
        );
        expect(task, isNot(task2));
      });

      test('同じTaskはHashCodeが同じであること', () {
        final task2 = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('変数を学ぶ'),
          description: ItemDescription('Dartの変数の型と使い方を学ぶ'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
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
      });
    });
  });
}
