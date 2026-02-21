import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

void main() {
  group('TaskStatus - 状態遷移の厳密性テスト', () {
    group('循環遷移の順序', () {
      test('Taskの状態遷移はTodo → Doing → Done → Todoの循環であること', () {
        // Arrange
        final status = TaskStatus.todo();

        // Act & Assert
        expect(status.isTodo, true, reason: '初期状態: Todo');

        final doingStatus = status.nextStatus();
        expect(doingStatus.isDoing, true, reason: '1回目の遷移: Doing');

        final doneStatus = doingStatus.nextStatus();
        expect(doneStatus.isDone, true, reason: '2回目の遷移: Done');

        final todoAgain = doneStatus.nextStatus();
        expect(todoAgain.isTodo, true, reason: '3回目の遷移: Todo（循環）');

        // 循環が正しく機能していることを確認
        final doingAgain = todoAgain.nextStatus();
        expect(doingAgain.isDoing, true, reason: '4回目の遷移: Doing（再度）');
      });

      test('状態遷移でステップをスキップできないこと（複数回の遷移が必要）', () {
        // Arrange
        final todoStatus = TaskStatus.todo();

        // Act
        final step1 = todoStatus.nextStatus();
        final step2 = step1.nextStatus();
        final step3 = step2.nextStatus();

        // Assert - Todo → Doing → Done に到達するには3ステップ必要
        expect(todoStatus.isTodo, true, reason: 'Step 0: Todo');
        expect(step1.isDoing, true, reason: 'Step 1: Doing');
        expect(step2.isDone, true, reason: 'Step 2: Done');
        expect(step3.isTodo, true, reason: 'Step 3: Todo（循環）');

        // スキップは不可能（直接Done にはなれない）
        // TODO のまま Done にはならない（必ず Doing を経由する必要がある）
        expect(todoStatus.isDone, false, reason: 'Todo からは直接Done にはなれない');
      });

      test('DoneからTodoへの直接遷移は不可能でありDone→Todoは循環のみであること', () {
        // Arrange
        final doneStatus = TaskStatus.done();

        // Act - Done からの遷移
        final nextStatus = doneStatus.nextStatus();

        // Assert - Done の次は必ず Todo（循環）
        expect(nextStatus.isTodo, true, reason: 'Done → Todo（循環のみ。直接遷移ではなく）');

        // Done が直接 Doing や Todo に戻ることはない
        expect(doneStatus.isDoing, false, reason: 'Done のまま Doing ではない');
        expect(doneStatus.isTodo, false, reason: 'Done のまま Todo ではない');
      });
    });

    group('各状態の不変性', () {
      test('同じ状態は常に等しいこと', () {
        // Arrange
        final status1 = TaskStatus.todo();
        final status2 = TaskStatus.todo();
        final status3 = TaskStatus.doing();

        // Act & Assert
        expect(status1, equals(status2), reason: '同じ Todo は等しい');
        expect(status1, isNot(equals(status3)), reason: 'Todo と Doing は異なる');
        expect(status1.hashCode, status2.hashCode, reason: '等しい状態は同じハッシュコード');
      });

      test('nextStatus()を呼び出しても元の状態は変わらないこと（イミュータブル）', () {
        // Arrange
        final originalStatus = TaskStatus.todo();

        // Act
        final newStatus = originalStatus.nextStatus();

        // Assert
        expect(originalStatus.isTodo, true, reason: '元の状態は変わらない（イミュータブル）');
        expect(newStatus.isDoing, true, reason: '新しい状態が返される');
        expect(
          originalStatus,
          isNot(equals(newStatus)),
          reason: '元の状態と新しい状態は異なる',
        );
      });
    });

    group('状態値の一貫性', () {
      test('各ステータスのprogress値が一定であること', () {
        // Arrange
        final todoStatus = TaskStatus.todo();
        final doingStatus = TaskStatus.doing();
        final doneStatus = TaskStatus.done();

        // Act & Assert
        expect(todoStatus.progress, 0, reason: 'Todo = 0%');
        expect(doingStatus.progress, 50, reason: 'Doing = 50%');
        expect(doneStatus.progress, 100, reason: 'Done = 100%');

        // 複数回呼び出しても値は変わらない
        expect(todoStatus.progress, 0);
        expect(todoStatus.progress, 0);
        expect(todoStatus.progress, 0);
      });

      test('有効なファクトリで生成されたTaskStatusは必ず有効なステータス値を持つこと', () {
        // Arrange
        final validStates = [
          TaskStatus.todo(),
          TaskStatus.doing(),
          TaskStatus.done(),
        ];

        final validValues = [
          TaskStatus.statusTodo,
          TaskStatus.statusDoing,
          TaskStatus.statusDone,
        ];

        // Act & Assert
        expect(
          validStates.every((s) => validValues.contains(s.value)),
          true,
          reason: 'すべての TaskStatus が有効な値である',
        );
      });
    });

    group('状態遷移グラフの完全性', () {
      test('3つの状態がすべて相互に到達可能であること', () {
        // Arrange
        var currentStatus = TaskStatus.todo();
        final visitedStates = <String>{};

        // Act - 完全な循環を1周する
        for (int i = 0; i < 3; i++) {
          visitedStates.add(currentStatus.value);
          currentStatus = currentStatus.nextStatus();
        }

        // Assert - 3ステップで3つの状態をすべて訪問した
        expect(visitedStates.length, 3, reason: '3つの状態すべてに到達可能');
        expect(visitedStates.contains('todo'), true);
        expect(visitedStates.contains('doing'), true);
        expect(visitedStates.contains('done'), true);

        // 元の状態に戻っている（循環）
        expect(currentStatus.isTodo, true, reason: '3ステップで元の状態に戻る');
      });

      test('状態遷移が常に有効な次の状態を生成すること（100回繰り返し）', () {
        // Arrange
        var status = TaskStatus.todo();

        // Act - 複数回の遷移を実行
        for (int i = 0; i < 100; i++) {
          status = status.nextStatus();

          // Assert - 各ステップで有効な状態である
          final isValid = status.isTodo || status.isDoing || status.isDone;
          expect(isValid, true, reason: 'ステップ $i で有効な状態を保つ');
        }
      });
    });
  });
}
