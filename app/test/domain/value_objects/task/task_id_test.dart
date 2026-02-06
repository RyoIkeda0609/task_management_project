import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/task/task_id.dart';

void main() {
  group('TaskId', () {
    group('コンストラクタ', () {
      test('UUID形式の文字列で TaskId が生成できること', () {
        final uuidString = '550e8400-e29b-41d4-a716-446655440000';
        final taskId = TaskId(uuidString);
        expect(taskId.value, uuidString);
      });

      test('新しい TaskId を生成できること（UUID自動生成）', () {
        final taskId = TaskId.generate();
        expect(taskId.value.isNotEmpty, true);
        expect(taskId.value.split('-').length, 5);
      });
    });

    group('等価性', () {
      test('同じ ID の TaskId は等しいこと', () {
        final id = '550e8400-e29b-41d4-a716-446655440000';
        final taskId1 = TaskId(id);
        final taskId2 = TaskId(id);
        expect(taskId1, equals(taskId2));
      });

      test('異なる ID の TaskId は等しくないこと', () {
        final taskId1 = TaskId.generate();
        final taskId2 = TaskId.generate();
        expect(taskId1, isNot(equals(taskId2)));
      });

      test('同じ ID の TaskId は同じハッシュコードを持つこと', () {
        final id = '550e8400-e29b-41d4-a716-446655440000';
        final taskId1 = TaskId(id);
        final taskId2 = TaskId(id);
        expect(taskId1.hashCode, equals(taskId2.hashCode));
      });
    });
  });
}
