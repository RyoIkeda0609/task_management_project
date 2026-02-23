/// Domain 不変条件パラノイアテスト
///
/// Phase 1§2: 不正状態遷移, 二重更新, 同一ID衝突, 空値境界, 期限境界
/// Phase 5: 異常系40%, 境界値20%
/// Phase 6⑤: State immutability 保証
import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';

void main() {
  // ────────────────────────────────────────────
  // ヘルパー
  // ────────────────────────────────────────────
  Task _makeTask({
    String id = 'task-1',
    TaskStatus status = TaskStatus.todo,
    String milestoneId = 'ms-1',
    String title = 'テスト',
  }) {
    return Task(
      itemId: ItemId(id),
      title: ItemTitle(title),
      description: ItemDescription('desc'),
      deadline: ItemDeadline(DateTime(2025, 12, 31)),
      status: status,
      milestoneId: ItemId(milestoneId),
    );
  }

  Goal _makeGoal({String id = 'goal-1', String category = '仕事'}) {
    return Goal(
      itemId: ItemId(id),
      title: ItemTitle('ゴール'),
      description: ItemDescription('desc'),
      deadline: ItemDeadline(DateTime(2025, 12, 31)),
      category: GoalCategory(category),
    );
  }

  Milestone _makeMilestone({String id = 'ms-1', String goalId = 'goal-1'}) {
    return Milestone(
      itemId: ItemId(id),
      title: ItemTitle('マイルストーン'),
      description: ItemDescription('desc'),
      deadline: ItemDeadline(DateTime(2025, 12, 31)),
      goalId: ItemId(goalId),
    );
  }

  // ────────────────────────────────────────────
  // §1 不正状態遷移
  // ────────────────────────────────────────────
  group('不正状態遷移', () {
    test('TaskStatus.fromString: 大文字は拒否される', () {
      expect(() => TaskStatus.fromString('Todo'), throwsArgumentError);
      expect(() => TaskStatus.fromString('TODO'), throwsArgumentError);
      expect(() => TaskStatus.fromString('DONE'), throwsArgumentError);
    });

    test('TaskStatus.fromString: 前後空白は拒否される', () {
      expect(() => TaskStatus.fromString(' todo '), throwsArgumentError);
      expect(() => TaskStatus.fromString(' doing'), throwsArgumentError);
      expect(() => TaskStatus.fromString('done '), throwsArgumentError);
    });

    test('TaskStatus.fromString: 空文字列は拒否される', () {
      expect(() => TaskStatus.fromString(''), throwsArgumentError);
    });

    test('TaskStatus.fromString: null類似文字列は拒否される', () {
      expect(() => TaskStatus.fromString('null'), throwsArgumentError);
      expect(() => TaskStatus.fromString('undefined'), throwsArgumentError);
    });

    test('Task.fromJson: 不正なstatus文字列で例外', () {
      final json = {
        'itemId': 'task-1',
        'title': 'test',
        'description': 'desc',
        'deadline': '2025-12-31T00:00:00.000',
        'status': 'invalid',
        'milestoneId': 'ms-1',
      };
      expect(() => Task.fromJson(json), throwsArgumentError);
    });

    test('Task.fromJson: 空status文字列で例外', () {
      final json = {
        'itemId': 'task-1',
        'title': 'test',
        'description': 'desc',
        'deadline': '2025-12-31T00:00:00.000',
        'status': '',
        'milestoneId': 'ms-1',
      };
      expect(() => Task.fromJson(json), throwsArgumentError);
    });

    test('Goal.fromJson: 必須フィールド欠落で例外', () {
      final json = {'itemId': 'g-1'}; // title, description等が欠落
      expect(() => Goal.fromJson(json), throwsA(isA<Error>()));
    });

    test('Milestone.fromJson: 必須フィールド欠落で例外', () {
      final json = {'itemId': 'ms-1'};
      expect(() => Milestone.fromJson(json), throwsA(isA<Error>()));
    });

    test('Task.fromJson: 不正な日付文字列で例外', () {
      final json = {
        'itemId': 'task-1',
        'title': 'test',
        'description': 'desc',
        'deadline': 'not-a-date',
        'status': 'todo',
        'milestoneId': 'ms-1',
      };
      expect(() => Task.fromJson(json), throwsFormatException);
    });
  });

  // ────────────────────────────────────────────
  // §2 二重更新 / 不変性保証
  // ────────────────────────────────────────────
  group('二重更新・不変性保証', () {
    test('cycleStatus は元のTaskを変更しない（不変性）', () {
      final original = _makeTask(status: TaskStatus.todo);
      final cycled = original.cycleStatus();

      expect(original.status, TaskStatus.todo, reason: '元オブジェクトは変わらない');
      expect(cycled.status, TaskStatus.doing, reason: '新オブジェクトは遷移済み');
    });

    test('cycleStatus はステータス以外のフィールドを保持する', () {
      final original = _makeTask(
        id: 'task-99',
        title: '重要タスク',
        milestoneId: 'ms-77',
      );
      final cycled = original.cycleStatus();

      expect(cycled.itemId, original.itemId);
      expect(cycled.title, original.title);
      expect(cycled.description, original.description);
      expect(cycled.deadline, original.deadline);
      expect(cycled.milestoneId, original.milestoneId);
    });

    test('cycleStatus 3回で元のステータスに戻る（冪等性）', () {
      final original = _makeTask(status: TaskStatus.todo);
      final afterThreeCycles = original
          .cycleStatus()
          .cycleStatus()
          .cycleStatus();

      expect(afterThreeCycles.status, original.status);
    });

    test('cycleStatus 6回で元のステータスに戻る（二重循環）', () {
      final original = _makeTask(status: TaskStatus.doing);
      var task = original;
      for (int i = 0; i < 6; i++) {
        task = task.cycleStatus();
      }
      expect(task.status, original.status);
    });

    test('同一引数で生成した2つのEntityは等価', () {
      final task1 = _makeTask(id: 'same-id');
      final task2 = _makeTask(id: 'same-id');
      expect(task1, equals(task2));
      expect(task1.hashCode, equals(task2.hashCode));
    });
  });

  // ────────────────────────────────────────────
  // §3 同一ID衝突 / ID境界
  // ────────────────────────────────────────────
  group('同一ID衝突・ID境界', () {
    test('ItemId.generate() は100回生成で全ユニーク', () {
      final ids = List.generate(100, (_) => ItemId.generate().value);
      expect(ids.toSet().length, 100);
    });

    test('同一IDでも異なるEntity型は不等価', () {
      final goal = _makeGoal(id: 'shared-id');
      final milestone = _makeMilestone(id: 'shared-id');
      // runtimeType が異なるため != になるべき
      expect(goal == milestone, isFalse);
    });

    test('Goal: カテゴリのみ異なれば不等価', () {
      final g1 = _makeGoal(id: 'id', category: '仕事');
      final g2 = _makeGoal(id: 'id', category: '趣味');
      expect(g1, isNot(equals(g2)));
    });

    test('Milestone: goalIdのみ異なれば不等価', () {
      final m1 = _makeMilestone(id: 'id', goalId: 'g-1');
      final m2 = _makeMilestone(id: 'id', goalId: 'g-2');
      expect(m1, isNot(equals(m2)));
    });

    test('Task: statusのみ異なれば不等価', () {
      final t1 = _makeTask(id: 'id', status: TaskStatus.todo);
      final t2 = _makeTask(id: 'id', status: TaskStatus.done);
      expect(t1, isNot(equals(t2)));
    });

    test('Task: milestoneIdのみ異なれば不等価', () {
      final t1 = _makeTask(id: 'id', milestoneId: 'ms-1');
      final t2 = _makeTask(id: 'id', milestoneId: 'ms-2');
      expect(t1, isNot(equals(t2)));
    });

    test('不等なオブジェクトのhashCodeが異なる確率が高い', () {
      final t1 = _makeTask(id: 'a');
      final t2 = _makeTask(id: 'b');
      // hashCode衝突は理論上あり得るが、このケースでは異なるべき
      expect(t1.hashCode, isNot(equals(t2.hashCode)));
    });
  });

  // ────────────────────────────────────────────
  // §4 空値境界
  // ────────────────────────────────────────────
  group('空値境界', () {
    test('ItemTitle: 1文字は許容（最小境界）', () {
      expect(() => ItemTitle('a'), returnsNormally);
    });

    test('ItemTitle: 100文字は許容（最大境界）', () {
      expect(() => ItemTitle('a' * 100), returnsNormally);
    });

    test('ItemTitle: 101文字は拒否', () {
      expect(() => ItemTitle('a' * 101), throwsArgumentError);
    });

    test('ItemTitle: 空文字列は拒否', () {
      expect(() => ItemTitle(''), throwsArgumentError);
    });

    test('ItemTitle: 空白のみは拒否', () {
      expect(() => ItemTitle('   '), throwsArgumentError);
    });

    test('ItemDescription: 500文字は許容（最大境界）', () {
      expect(() => ItemDescription('a' * 500), returnsNormally);
    });

    test('ItemDescription: 501文字は拒否', () {
      expect(() => ItemDescription('a' * 501), throwsArgumentError);
    });

    test('ItemDescription: 空文字列は許容', () {
      final desc = ItemDescription('');
      expect(desc.value, '');
    });

    test('GoalCategory: 空文字列は拒否', () {
      expect(() => GoalCategory(''), throwsArgumentError);
    });

    test('GoalCategory: 空白のみは拒否', () {
      expect(() => GoalCategory('   '), throwsArgumentError);
    });

    test('GoalCategory: 101文字は拒否', () {
      expect(() => GoalCategory('a' * 101), throwsArgumentError);
    });
  });

  // ────────────────────────────────────────────
  // §5 期限境界
  // ────────────────────────────────────────────
  group('期限境界', () {
    test('遠い未来の日付は正常に扱える', () {
      final deadline = ItemDeadline(DateTime(9999, 12, 31));
      expect(deadline.value, DateTime(9999, 12, 31));
    });

    test('遠い過去の日付は正常に扱える', () {
      final deadline = ItemDeadline(DateTime(1, 1, 1));
      expect(deadline.value, DateTime(1, 1, 1));
    });

    test('閏年2月29日は正常に扱える', () {
      final deadline = ItemDeadline(DateTime(2024, 2, 29));
      expect(deadline.value.month, 2);
      expect(deadline.value.day, 29);
    });

    test('時刻は00:00:00に正規化される', () {
      final deadline = ItemDeadline(DateTime(2025, 6, 15, 23, 59, 59));
      expect(deadline.value.hour, 0);
      expect(deadline.value.minute, 0);
      expect(deadline.value.second, 0);
    });

    test('同じ日付の異なる時刻は等価', () {
      final d1 = ItemDeadline(DateTime(2025, 6, 15, 10, 30));
      final d2 = ItemDeadline(DateTime(2025, 6, 15, 22, 45));
      expect(d1, equals(d2));
    });

    test('年末と年始は異なる', () {
      final dec31 = ItemDeadline(DateTime(2025, 12, 31));
      final jan1 = ItemDeadline(DateTime(2026, 1, 1));
      expect(dec31, isNot(equals(jan1)));
      expect(dec31.isBefore(jan1), isTrue);
    });

    test('デフォルトコンストラクタは今日を返す', () {
      final deadline = ItemDeadline();
      final today = DateTime.now();
      expect(deadline.value.year, today.year);
      expect(deadline.value.month, today.month);
      expect(deadline.value.day, today.day);
    });
  });

  // ────────────────────────────────────────────
  // §6 JSON roundtrip 堅牢性
  // ────────────────────────────────────────────
  group('JSON roundtrip 堅牢性', () {
    test('Task: toJson → fromJson で完全復元', () {
      final original = _makeTask(
        id: 'roundtrip-task',
        status: TaskStatus.doing,
      );
      final json = original.toJson();
      final restored = Task.fromJson(json);
      expect(restored, equals(original));
    });

    test('Goal: toJson → fromJson で完全復元', () {
      final original = _makeGoal(id: 'roundtrip-goal', category: 'テスト用');
      final json = original.toJson();
      final restored = Goal.fromJson(json);
      expect(restored, equals(original));
    });

    test('Milestone: toJson → fromJson で完全復元', () {
      final original = _makeMilestone(id: 'roundtrip-ms', goalId: 'g-99');
      final json = original.toJson();
      final restored = Milestone.fromJson(json);
      expect(restored, equals(original));
    });

    test('特殊文字を含むtitleのroundtrip', () {
      final task = Task(
        itemId: ItemId('special-chars'),
        title: ItemTitle('タスク<>&"'),
        description: ItemDescription('改行\nタブ\t含む'),
        deadline: ItemDeadline(DateTime(2025, 12, 31)),
        status: TaskStatus.todo,
        milestoneId: ItemId('ms-1'),
      );
      final restored = Task.fromJson(task.toJson());
      expect(restored.title.value, 'タスク<>&"');
      expect(restored.description.value, '改行\nタブ\t含む');
    });

    test('Unicode絵文字を含むtitleのroundtrip', () {
      final task = Task(
        itemId: ItemId('emoji-task'),
        title: ItemTitle('🎯ゴール達成'),
        description: ItemDescription('🔥頑張る💪'),
        deadline: ItemDeadline(DateTime(2025, 12, 31)),
        status: TaskStatus.todo,
        milestoneId: ItemId('ms-1'),
      );
      final restored = Task.fromJson(task.toJson());
      expect(restored.title.value, '🎯ゴール達成');
      expect(restored.description.value, '🔥頑張る💪');
    });

    test('fromJson: 余分なフィールドは無害', () {
      final json = {
        'itemId': 'task-1',
        'title': 'test',
        'description': 'desc',
        'deadline': '2025-12-31T00:00:00.000',
        'status': 'todo',
        'milestoneId': 'ms-1',
        'extraField': 'should be ignored',
        'anotherExtra': 42,
      };
      expect(() => Task.fromJson(json), returnsNormally);
    });
  });

  // ────────────────────────────────────────────
  // §7 TaskStatus enum 網羅性
  // ────────────────────────────────────────────
  group('TaskStatus enum 網羅性', () {
    test('enum値は正確に3つ', () {
      expect(TaskStatus.values.length, 3);
    });

    test('全enum値のvalue/progress/isXxx が一致', () {
      expect(TaskStatus.todo.value, 'todo');
      expect(TaskStatus.todo.progress, 0);
      expect(TaskStatus.todo.isTodo, isTrue);
      expect(TaskStatus.todo.isDoing, isFalse);
      expect(TaskStatus.todo.isDone, isFalse);

      expect(TaskStatus.doing.value, 'doing');
      expect(TaskStatus.doing.progress, 50);
      expect(TaskStatus.doing.isTodo, isFalse);
      expect(TaskStatus.doing.isDoing, isTrue);
      expect(TaskStatus.doing.isDone, isFalse);

      expect(TaskStatus.done.value, 'done');
      expect(TaskStatus.done.progress, 100);
      expect(TaskStatus.done.isTodo, isFalse);
      expect(TaskStatus.done.isDoing, isFalse);
      expect(TaskStatus.done.isDone, isTrue);
    });

    test('fromString は全有効値を正しく復元', () {
      for (final status in TaskStatus.values) {
        expect(TaskStatus.fromString(status.value), status);
      }
    });

    test('nextStatus は全値で循環が閉じている', () {
      for (final status in TaskStatus.values) {
        final next = status.nextStatus();
        expect(TaskStatus.values.contains(next), isTrue);
      }
    });

    test('progress定数が正しい', () {
      expect(TaskStatus.progressTodo, 0);
      expect(TaskStatus.progressDoing, 50);
      expect(TaskStatus.progressDone, 100);
    });
  });

  // ────────────────────────────────────────────
  // §8 Entity toString 一貫性
  // ────────────────────────────────────────────
  group('Entity toString 一貫性', () {
    test('Goal.toString にitemIdとtitleが含まれる', () {
      final goal = _makeGoal(id: 'g-1');
      expect(goal.toString(), contains('g-1'));
      expect(goal.toString(), contains('ゴール'));
    });

    test('Milestone.toString にitemIdとtitleが含まれる', () {
      final ms = _makeMilestone(id: 'ms-1');
      expect(ms.toString(), contains('ms-1'));
      expect(ms.toString(), contains('マイルストーン'));
    });

    test('Task.toString にitemIdとtitleとstatusが含まれる', () {
      final task = _makeTask(id: 'task-1', status: TaskStatus.doing);
      expect(task.toString(), contains('task-1'));
      expect(task.toString(), contains('テスト'));
      expect(task.toString(), contains('doing'));
    });
  });
}
