import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';

void main() {
  group('GoalId', () {
    group('コンストラクタ', () {
      test('UUID形式の文字列で GoalId が生成できること', () {
        final uuidString = '550e8400-e29b-41d4-a716-446655440000';
        final goalId = GoalId(uuidString);
        expect(goalId.value, uuidString);
      });

      test('新しい GoalId を生成できること（UUID自動生成）', () {
        final goalId = GoalId.generate();
        expect(goalId.value.isNotEmpty, true);
        // UUIDのフォーマットチェック（簡易版）
        expect(goalId.value.split('-').length, 5);
      });
    });

    group('等価性', () {
      test('同じ ID の GoalId は等しいこと', () {
        final id = '550e8400-e29b-41d4-a716-446655440000';
        final goalId1 = GoalId(id);
        final goalId2 = GoalId(id);
        expect(goalId1, equals(goalId2));
      });

      test('異なる ID の GoalId は等しくないこと', () {
        final goalId1 = GoalId.generate();
        final goalId2 = GoalId.generate();
        expect(goalId1, isNot(equals(goalId2)));
      });

      test('同じ ID の GoalId は同じハッシュコードを持つこと', () {
        final id = '550e8400-e29b-41d4-a716-446655440000';
        final goalId1 = GoalId(id);
        final goalId2 = GoalId(id);
        expect(goalId1.hashCode, equals(goalId2.hashCode));
      });
    });
  });
}
