import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';

void main() {
  group('MilestoneId', () {
    group('コンストラクタ', () {
      test('UUID形式の文字列で MilestoneId が生成できること', () {
        final uuidString = '550e8400-e29b-41d4-a716-446655440000';
        final milestoneId = MilestoneId(uuidString);
        expect(milestoneId.value, uuidString);
      });

      test('新しい MilestoneId を生成できること（UUID自動生成）', () {
        final milestoneId = MilestoneId.generate();
        expect(milestoneId.value.isNotEmpty, true);
        expect(milestoneId.value.split('-').length, 5);
      });
    });

    group('等価性', () {
      test('同じ ID の MilestoneId は等しいこと', () {
        final id = '550e8400-e29b-41d4-a716-446655440000';
        final milestoneId1 = MilestoneId(id);
        final milestoneId2 = MilestoneId(id);
        expect(milestoneId1, equals(milestoneId2));
      });

      test('異なる ID の MilestoneId は等しくないこと', () {
        final milestoneId1 = MilestoneId.generate();
        final milestoneId2 = MilestoneId.generate();
        expect(milestoneId1, isNot(equals(milestoneId2)));
      });

      test('同じ ID の MilestoneId は同じハッシュコードを持つこと', () {
        final id = '550e8400-e29b-41d4-a716-446655440000';
        final milestoneId1 = MilestoneId(id);
        final milestoneId2 = MilestoneId(id);
        expect(milestoneId1.hashCode, equals(milestoneId2.hashCode));
      });
    });
  });
}
