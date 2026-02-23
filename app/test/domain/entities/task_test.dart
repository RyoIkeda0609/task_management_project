import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

void main() {
  group('Task Entity (Refactored with Item)', () {
    late Task task;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      task = Task(
        itemId: ItemId('task-1'),
        title: ItemTitle('ウィジェット学習'),
        description: ItemDescription('StatefulWidget と StatelessWidget の差を学ぶ'),
        deadline: ItemDeadline(tomorrow),
        status: TaskStatus.todo,
        milestoneId: ItemId('milestone-1'),
      );
    });

    group('初期化', () {
      test('全フィールドが正しく設定されること', () {
        expect(task.itemId.value, 'task-1');
        expect(task.title.value, 'ウィジェット学習');
        expect(
          task.description.value,
          'StatefulWidget と StatelessWidget の差を学ぶ',
        );
        expect(task.status.isTodo, true);
        expect(task.milestoneId.value, 'milestone-1');
      });

      test('ItemId.generate()でTaskが生成できること', () {
        final taskWithGeneratedId = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('New Task'),
          description: ItemDescription('Description'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.doing,
          milestoneId: ItemId('milestone-x'),
        );
        expect(taskWithGeneratedId.itemId.value.isNotEmpty, true);
      });

      test('空の説明文でTaskが生成できること', () {
        final taskEmptyDesc = Task(
          itemId: ItemId('task-2'),
          title: ItemTitle('Task'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.done,
          milestoneId: ItemId('milestone-1'),
        );
        expect(taskEmptyDesc.description.value, '');
      });
    });

    group('getProgress', () {
      test('Todoステータスの場合0%を返すこと', () {
        final todoTask = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('Test'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-1'),
        );
        final progress = todoTask.getProgress();
        expect(progress.value, 0);
      });

      test('Doingステータスの場合50%を返すこと', () {
        final doingTask = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('Test'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.doing,
          milestoneId: ItemId('milestone-1'),
        );
        final progress = doingTask.getProgress();
        expect(progress.value, 50);
      });

      test('Doneステータスの場合100%を返すこと', () {
        final doneTask = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('Test'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.done,
          milestoneId: ItemId('milestone-1'),
        );
        final progress = doneTask.getProgress();
        expect(progress.value, 100);
      });
    });

    group('cycleStatus', () {
      test('Todo → Doingに遷移できること', () {
        final updated = task.cycleStatus();
        expect(updated.status.isDoing, true);
      });

      test('Doing → Doneに遷移できること', () {
        final doingTask = task.cycleStatus();
        final updated = doingTask.cycleStatus();
        expect(updated.status.isDone, true);
      });

      test('Done → Todoに遷移できること（循環）', () {
        final doingTask = task.cycleStatus();
        final doneTask = doingTask.cycleStatus();
        final cycledTask = doneTask.cycleStatus();
        expect(cycledTask.status.isTodo, true);
      });

      test('cycleStatusは他のフィールドを保持すること', () {
        final updated = task.cycleStatus();
        expect(updated.itemId, task.itemId);
        expect(updated.title, task.title);
        expect(updated.description, task.description);
        expect(updated.deadline, task.deadline);
        expect(updated.milestoneId, task.milestoneId);
      });
    });

    group('等価性とハッシュコード', () {
      test('同じフィールドを持つTaskは等しいこと', () {
        final task2 = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('ウィジェット学習'),
          description: ItemDescription(
            'StatefulWidget と StatelessWidget の差を学ぶ',
          ),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-1'),
        );
        expect(task, task2);
      });

      test('異なるitemIdを持つTaskは等しくないこと', () {
        final task2 = Task(
          itemId: ItemId('task-2'),
          title: ItemTitle('ウィジェット学習'),
          description: ItemDescription(
            'StatefulWidget と StatelessWidget の差を学ぶ',
          ),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-1'),
        );
        expect(task, isNot(task2));
      });

      test('等しいTaskは同じハッシュコードを持つこと', () {
        final task2 = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('ウィジェット学習'),
          description: ItemDescription(
            'StatefulWidget と StatelessWidget の差を学ぶ',
          ),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-1'),
        );
        expect(task.hashCode, task2.hashCode);
      });
    });

    group('JSONシリアライズ', () {
      test('toJsonで全フィールドが含まれること', () {
        final json = task.toJson();
        expect(json['itemId'], 'task-1');
        expect(json['title'], 'ウィジェット学習');
        expect(json['description'], 'StatefulWidget と StatelessWidget の差を学ぶ');
        expect(json['status'], 'todo');
        expect(json['milestoneId'], 'milestone-1');
        expect(json['deadline'], isNotNull);
      });

      test('fromJsonでTaskが正しく復元できること', () {
        final json = task.toJson();
        final restored = Task.fromJson(json);
        expect(restored, task);
      });

      test('fromJsonで全フィールドが正しく復元できること', () {
        final json = {
          'itemId': 'task-123',
          'title': 'テストタスク',
          'description': 'テスト説明',
          'deadline': tomorrow.toIso8601String(),
          'status': 'doing',
          'milestoneId': 'milestone-123',
        };
        final restored = Task.fromJson(json);
        expect(restored.itemId.value, 'task-123');
        expect(restored.title.value, 'テストタスク');
        expect(restored.description.value, 'テスト説明');
        expect(restored.status.isDoing, true);
        expect(restored.milestoneId.value, 'milestone-123');
      });
    });

    group('toString', () {
      test('toStringがTaskとitemIdとtitleを含む文字列を返すこと', () {
        final str = task.toString();
        expect(str, contains('Task'));
        expect(str, contains('task-1'));
        expect(str, contains('ウィジェット学習'));
      });
    });
  });
}
