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
        status: TaskStatus.todo(),
        milestoneId: ItemId('milestone-1'),
      );
    });

    group('initialization', () {
      test('Task should be initialized with all fields', () {
        expect(task.itemId.value, 'task-1');
        expect(task.title.value, 'ウィジェット学習');
        expect(
          task.description.value,
          'StatefulWidget と StatelessWidget の差を学ぶ',
        );
        expect(task.status.isTodo, true);
        expect(task.milestoneId.value, 'milestone-1');
      });

      test('Task can use ItemId.generate()', () {
        final taskWithGeneratedId = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('New Task'),
          description: ItemDescription('Description'),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.doing(),
          milestoneId: ItemId('milestone-x'),
        );
        expect(taskWithGeneratedId.itemId.value.isNotEmpty, true);
      });

      test('Task can accept empty description', () {
        final taskEmptyDesc = Task(
          itemId: ItemId('task-2'),
          title: ItemTitle('Task'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.done(),
          milestoneId: ItemId('milestone-1'),
        );
        expect(taskEmptyDesc.description.value, '');
      });
    });

    group('getProgress', () {
      test('getProgress should return 0% for Todo status', () {
        final todoTask = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('Test'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );
        final progress = todoTask.getProgress();
        expect(progress.value, 0);
      });

      test('getProgress should return 50% for Doing status', () {
        final doingTask = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('Test'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.doing(),
          milestoneId: ItemId('milestone-1'),
        );
        final progress = doingTask.getProgress();
        expect(progress.value, 50);
      });

      test('getProgress should return 100% for Done status', () {
        final doneTask = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('Test'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.done(),
          milestoneId: ItemId('milestone-1'),
        );
        final progress = doneTask.getProgress();
        expect(progress.value, 100);
      });
    });

    group('cycleStatus', () {
      test('cycleStatus should transition Todo -> Doing', () {
        final updated = task.cycleStatus();
        expect(updated.status.isDoing, true);
      });

      test('cycleStatus should transition Doing -> Done', () {
        final doingTask = task.cycleStatus();
        final updated = doingTask.cycleStatus();
        expect(updated.status.isDone, true);
      });

      test('cycleStatus should transition Done -> Todo (循環)', () {
        final doingTask = task.cycleStatus();
        final doneTask = doingTask.cycleStatus();
        final cycledTask = doneTask.cycleStatus();
        expect(cycledTask.status.isTodo, true);
      });

      test('cycleStatus should preserve other fields', () {
        final updated = task.cycleStatus();
        expect(updated.itemId, task.itemId);
        expect(updated.title, task.title);
        expect(updated.description, task.description);
        expect(updated.deadline, task.deadline);
        expect(updated.milestoneId, task.milestoneId);
      });
    });

    group('equality and hashCode', () {
      test('Tasks with same fields should be equal', () {
        final task2 = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('ウィジェット学習'),
          description: ItemDescription(
            'StatefulWidget と StatelessWidget の差を学ぶ',
          ),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );
        expect(task, task2);
      });

      test('Tasks with different itemId should not be equal', () {
        final task2 = Task(
          itemId: ItemId('task-2'),
          title: ItemTitle('ウィジェット学習'),
          description: ItemDescription(
            'StatefulWidget と StatelessWidget の差を学ぶ',
          ),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );
        expect(task, isNot(task2));
      });

      test('equal Tasks should have same hashCode', () {
        final task2 = Task(
          itemId: ItemId('task-1'),
          title: ItemTitle('ウィジェット学習'),
          description: ItemDescription(
            'StatefulWidget と StatelessWidget の差を学ぶ',
          ),
          deadline: ItemDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );
        expect(task.hashCode, task2.hashCode);
      });
    });

    group('JSON serialization', () {
      test('toJson should include all fields', () {
        final json = task.toJson();
        expect(json['itemId'], 'task-1');
        expect(json['title'], 'ウィジェット学習');
        expect(json['description'], 'StatefulWidget と StatelessWidget の差を学ぶ');
        expect(json['status'], 'todo');
        expect(json['milestoneId'], 'milestone-1');
        expect(json['deadline'], isNotNull);
      });

      test('fromJson should restore Task correctly', () {
        final json = task.toJson();
        final restored = Task.fromJson(json);
        expect(restored, task);
      });

      test('fromJson should handle all fields', () {
        final json = {
          'itemId': 'task-123',
          'title': 'Test Task',
          'description': 'Test Description',
          'deadline': tomorrow.toIso8601String(),
          'status': 'doing',
          'milestoneId': 'milestone-123',
        };
        final restored = Task.fromJson(json);
        expect(restored.itemId.value, 'task-123');
        expect(restored.title.value, 'Test Task');
        expect(restored.description.value, 'Test Description');
        expect(restored.status.isDoing, true);
        expect(restored.milestoneId.value, 'milestone-123');
      });
    });

    group('toString', () {
      test('toString should include itemId and title', () {
        final str = task.toString();
        expect(str, contains('Task'));
        expect(str, contains('task-1'));
        expect(str, contains('ウィジェット学習'));
      });
    });
  });
}
