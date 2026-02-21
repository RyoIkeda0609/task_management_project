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

    group('initialization', () {
      test('Milestone should be initialized with all fields', () {
        expect(milestone.itemId.value, 'milestone-1');
        expect(milestone.title.value, '基本文法習得');
        expect(milestone.description.value, 'Dart文法を完全に習得');
        expect(milestone.goalId.value, 'goal-1');
      });

      test('Milestone can use ItemId.generate()', () {
        final milestoneWithGeneratedId = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('New Milestone'),
          description: ItemDescription('Description'),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('goal-x'),
        );
        expect(milestoneWithGeneratedId.itemId.value.isNotEmpty, true);
      });

      test('Milestone can accept empty description', () {
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

    group('equality and hashCode', () {
      test('Milestones with same fields should be equal', () {
        final milestone2 = Milestone(
          itemId: ItemId('milestone-1'),
          title: ItemTitle('基本文法習得'),
          description: ItemDescription('Dart文法を完全に習得'),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('goal-1'),
        );
        expect(milestone, milestone2);
      });

      test('Milestones with different itemId should not be equal', () {
        final milestone2 = Milestone(
          itemId: ItemId('milestone-2'),
          title: ItemTitle('基本文法習得'),
          description: ItemDescription('Dart文法を完全に習得'),
          deadline: ItemDeadline(tomorrow),
          goalId: ItemId('goal-1'),
        );
        expect(milestone, isNot(milestone2));
      });

      test('equal Milestones should have same hashCode', () {
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

    group('JSON serialization', () {
      test('toJson should include all fields', () {
        final json = milestone.toJson();
        expect(json['itemId'], 'milestone-1');
        expect(json['title'], '基本文法習得');
        expect(json['description'], 'Dart文法を完全に習得');
        expect(json['goalId'], 'goal-1');
        expect(json['deadline'], isNotNull);
      });

      test('fromJson should restore Milestone correctly', () {
        final json = milestone.toJson();
        final restored = Milestone.fromJson(json);
        expect(restored, milestone);
      });

      test('fromJson should handle all fields', () {
        final json = {
          'itemId': 'milestone-123',
          'title': 'Test Milestone',
          'description': 'Test Description',
          'deadline': tomorrow.toIso8601String(),
          'goalId': 'goal-123',
        };
        final restored = Milestone.fromJson(json);
        expect(restored.itemId.value, 'milestone-123');
        expect(restored.title.value, 'Test Milestone');
        expect(restored.description.value, 'Test Description');
        expect(restored.goalId.value, 'goal-123');
      });
    });

    group('toString', () {
      test('toString should include itemId and title', () {
        final str = milestone.toString();
        expect(str, contains('Milestone'));
        expect(str, contains('milestone-1'));
        expect(str, contains('基本文法習得'));
      });
    });
  });
}
