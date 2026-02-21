import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

void main() {
  group('TaskStatus', () {
    group('コンストラクタ', () {
      test('StatusがtodoのTaskStatusが生成できること', () {
        final status = TaskStatus.todo();
        expect(status.value, 'todo');
      });

      test('StatusがdoingのTaskStatusが生成できること', () {
        final status = TaskStatus.doing();
        expect(status.value, 'doing');
      });

      test('StatusがdoneのTaskStatusが生成できること', () {
        final status = TaskStatus.done();
        expect(status.value, 'done');
      });
    });

    group('等しいこと', () {
      test('同じステータスのTaskStatusは等しいこと', () {
        final status1 = TaskStatus.todo();
        final status2 = TaskStatus.todo();
        expect(status1, equals(status2));
      });

      test('異なるステータスのTaskStatusは等しくないこと', () {
        final status1 = TaskStatus.todo();
        final status2 = TaskStatus.doing();
        expect(status1, isNot(equals(status2)));
      });

      test('同じステータスのTaskStatusは同じハッシュコードを持つこと', () {
        final status1 = TaskStatus.todo();
        final status2 = TaskStatus.todo();
        expect(status1.hashCode, equals(status2.hashCode));
      });
    });

    group('nextStatus', () {
      test('TodoからDoingに遷移できること', () {
        final status = TaskStatus.todo();
        expect(status.nextStatus(), TaskStatus.doing());
      });

      test('DoingからDoneに遷移できること', () {
        final status = TaskStatus.doing();
        expect(status.nextStatus(), TaskStatus.done());
      });

      test('DoneからTodoに遷移できること', () {
        final status = TaskStatus.done();
        expect(status.nextStatus(), TaskStatus.todo());
      });
    });

    group('isTodo', () {
      test('ステータスがtodoのときtrueを返すこと', () {
        final status = TaskStatus.todo();
        expect(status.isTodo, true);
      });

      test('ステータスがtodo以外のときfalseを返すこと', () {
        final status = TaskStatus.doing();
        expect(status.isTodo, false);
      });
    });

    group('isDoing', () {
      test('ステータスがdoingのときtrueを返すこと', () {
        final status = TaskStatus.doing();
        expect(status.isDoing, true);
      });

      test('ステータスがdoing以外のときfalseを返すこと', () {
        final status = TaskStatus.todo();
        expect(status.isDoing, false);
      });
    });

    group('isDone', () {
      test('ステータスがdoneのときtrueを返すこと', () {
        final status = TaskStatus.done();
        expect(status.isDone, true);
      });

      test('ステータスがdone以外のときfalseを返すこと', () {
        final status = TaskStatus.todo();
        expect(status.isDone, false);
      });
    });

    group('progress', () {
      test('ステータスがtodoのとき0を返すこと', () {
        final status = TaskStatus.todo();
        expect(status.progress, 0);
      });

      test('ステータスがdoingのとき50を返すこと', () {
        final status = TaskStatus.doing();
        expect(status.progress, 50);
      });

      test('ステータスがdoneのとき100を返すこと', () {
        final status = TaskStatus.done();
        expect(status.progress, 100);
      });
    });

    group('不正なステータス値', () {
      test('不正なステータス値でnextStatusを呼ぶとArgumentErrorが発生すること', () {
        final invalidStatus = TaskStatus('invalid_value');
        expect(() => invalidStatus.nextStatus(), throwsArgumentError);
      });
    });
  });
}
