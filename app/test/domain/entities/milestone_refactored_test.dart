import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

void main() {
  group('Milestone Entity (Refactored with Item)', () {
    late Milestone milestone;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      milestone = Milestone(
        itemId: ItemId('milestone-1'),
        title: ItemTitle('基本文法習得'),
        description: ItemDescription('Dart文法を完全に習得'),
        deadline: ItemDeadline(tomorrow),
        goalId: ItemId('goal-1'),
      );
    });

    group('初期化', () {
      test('全フィールドが正しく設定されること', () {
        expect(milestone.itemId.value, 'milestone-1');
        expect(milestone.title.value, '基本文法習得');
        expect(milestone.description.value, 'Dart文法を完全に習得');
        expect(milestone.goalId.value, 'goal-1');
      });

      test('ItemId.generate()でMilestoneが生成できること', () {
        final milestoneWithGeneratedId = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('New Milestone'),
          description: ItemDescription('Description'),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('goal-x'),
        );
        expect(milestoneWithGeneratedId.itemId.value.isNotEmpty, true);
      });

      test('空の説明文でMilestoneが生成できること', () {
        final milestoneEmptyDesc = Milestone(
          itemId: ItemId('milestone-2'),
          title: ItemTitle('Milestone'),
          description: ItemDescription(''),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('goal-1'),
        );
        expect(milestoneEmptyDesc.description.value, '');
      });
    });

    group('等価性とハッシュコード', () {
      test('同じフィールドを持つMilestoneは等しいこと', () {
        final milestone2 = Milestone(
          itemId: ItemId('milestone-1'),
          title: ItemTitle('基本文法習得'),
          description: ItemDescription('Dart文法を完全に習得'),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('goal-1'),
        );
        expect(milestone, milestone2);
      });

      test('異なるitemIdを持つMilestoneは等しくないこと', () {
        final milestone2 = Milestone(
          itemId: ItemId('milestone-2'),
          title: ItemTitle('基本文法習得'),
          description: ItemDescription('Dart文法を完全に習得'),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('goal-1'),
        );
        expect(milestone, isNot(milestone2));
      });

      test('等しいMilestoneは同じハッシュコードを持つこと', () {
        final milestone2 = Milestone(
          itemId: ItemId('milestone-1'),
          title: ItemTitle('基本文法習得'),
          description: ItemDescription('Dart文法を完全に習得'),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('goal-1'),
        );
        expect(milestone.hashCode, milestone2.hashCode);
      });
    });

    group('JSONシリアライズ', () {
      test('toJsonで全フィールドが含まれること', () {
        final json = milestone.toJson();
        expect(json['itemId'], 'milestone-1');
        expect(json['title'], '基本文法習得');
        expect(json['description'], 'Dart文法を完全に習得');
        expect(json['goalId'], 'goal-1');
        expect(json['deadline'], isNotNull);
      });

      test('fromJsonでMilestoneが正しく復元できること', () {
        final json = milestone.toJson();
        final restored = Milestone.fromJson(json);
        expect(restored, milestone);
      });

      test('fromJsonで全フィールドが正しく復元できること', () {
        final json = {
          'itemId': 'milestone-123',
          'title': 'テストマイルストーン',
          'description': 'テスト説明',
          'deadline': tomorrow.toIso8601String(),
          'goalId': 'goal-123',
        };
        final restored = Milestone.fromJson(json);
        expect(restored.itemId.value, 'milestone-123');
        expect(restored.title.value, 'テストマイルストーン');
        expect(restored.description.value, 'テスト説明');
        expect(restored.goalId.value, 'goal-123');
      });
    });

    group('toString', () {
      test('toStringがMilestoneとitemIdとtitleを含む文字列を返すこと', () {
        final str = milestone.toString();
        expect(str, contains('Milestone'));
        expect(str, contains('milestone-1'));
        expect(str, contains('基本文法習得'));
      });
    });
  });
}
