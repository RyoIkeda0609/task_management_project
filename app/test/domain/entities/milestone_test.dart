import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

void main() {
  group('Milestone Entity', () {
    late Milestone milestone;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      milestone = Milestone(
        itemId: ItemId('milestone-1'),
        title: ItemTitle('基本文法習得'),
        description: ItemDescription('Dart文法を学ぶ'),
        deadline: ItemDeadline(tomorrow),
        goalId: ItemId('goal-1'),
      );
    });

    group('初期化', () {
      test('マイルストーンが正しく初期化できること', () {
        expect(milestone.itemId.value, 'milestone-1');
        expect(milestone.title.value, '基本文法習得');
        expect(milestone.goalId.value, 'goal-1');
      });

      test('goalIdが正しく設定されること', () {
        expect(milestone.goalId.value, 'goal-1');
      });
    });

    group('等号演算子とhashCode', () {
      test('同じフィールドを持つMilestoneは等価であること', () {
        final milestone2 = Milestone(
          itemId: ItemId('milestone-1'),
          title: ItemTitle('基本文法習得'),
          description: ItemDescription('Dart文法を学ぶ'),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('goal-1'),
        );
        expect(milestone, milestone2);
      });

      test('異なるIDを持つMilestoneは等価でないこと', () {
        final milestone2 = Milestone(
          itemId: ItemId('milestone-2'),
          title: ItemTitle('基本文法習得'),
          description: ItemDescription('Dart文法を学ぶ'),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('goal-1'),
        );
        expect(milestone, isNot(milestone2));
      });

      test('異なるgoalIdを持つMilestoneは等価でないこと', () {
        final milestone2 = Milestone(
          itemId: ItemId('milestone-1'),
          title: ItemTitle('基本文法習得'),
          description: ItemDescription('Dart文法を学ぶ'),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('goal-2'),
        );
        expect(milestone, isNot(milestone2));
      });

      test('同じMilestoneはHashCodeが同じであること', () {
        final milestone2 = Milestone(
          itemId: ItemId('milestone-1'),
          title: ItemTitle('基本文法習得'),
          description: ItemDescription('Dart文法を学ぶ'),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('goal-1'),
        );
        expect(milestone.hashCode, milestone2.hashCode);
      });
    });

    group('toString', () {
      test('toStringが適切な文字列を返すこと', () {
        final string = milestone.toString();
        expect(string, contains('Milestone'));
        expect(string, contains('milestone-1'));
        expect(string, contains('基本文法習得'));
      });
    });
  });
}
