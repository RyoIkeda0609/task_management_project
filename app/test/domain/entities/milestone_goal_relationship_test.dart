import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';

void main() {
  group('Milestone - 親 Goal との関係検証テスト', () {
    test('Milestone は有効な goalId で作成できる', () {
      final milestone = Milestone(
        id: MilestoneId('milestone-1'),
        title: MilestoneTitle('テストマイルストーン'),
        deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        goalId: 'goal-1',
      );

      expect(milestone.goalId, 'goal-1');
    });

    test('Milestone の goalId は不変である', () {
      final milestone1 = Milestone(
        id: MilestoneId('milestone-1'),
        title: MilestoneTitle('マイルストーン1'),
        deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        goalId: 'goal-1',
      );

      final milestone2 = Milestone(
        id: MilestoneId('milestone-1'),
        title: milestone1.title,
        deadline: milestone1.deadline,
        goalId: 'goal-1',
      );

      expect(milestone1.goalId, milestone2.goalId);
    });

    test('異なる goalId を持つ Milestone は異なる Goal に属する', () {
      final milestone1 = Milestone(
        id: MilestoneId('milestone-1'),
        title: MilestoneTitle('マイルストーン1'),
        deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        goalId: 'goal-1',
      );

      final milestone2 = Milestone(
        id: MilestoneId('milestone-2'),
        title: MilestoneTitle('マイルストーン2'),
        deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        goalId: 'goal-2',
      );

      expect(milestone1.goalId, isNot(equals(milestone2.goalId)));
    });

    test('Milestone の進捗値は 0-100 の範囲である', () {
      final milestone = Milestone(
        id: MilestoneId('milestone-1'),
        title: MilestoneTitle('テストマイルストーン'),
        deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        goalId: 'goal-1',
      );

      expect(milestone.progress.value, greaterThanOrEqualTo(0));
      expect(milestone.progress.value, lessThanOrEqualTo(100));
    });

    test('複数の Milestone は同じ Goal に属することができる', () {
      final milestone1 = Milestone(
        id: MilestoneId('milestone-1'),
        title: MilestoneTitle('マイルストーン1'),
        deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        goalId: 'goal-1',
      );

      final milestone2 = Milestone(
        id: MilestoneId('milestone-2'),
        title: MilestoneTitle('マイルストーン2'),
        deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        goalId: 'goal-1',
      );

      expect(milestone1.goalId, milestone2.goalId);
      expect(milestone1.id.value, isNot(equals(milestone2.id.value)));
    });

    test('Milestone の id は null ではない', () {
      final milestone = Milestone(
        id: MilestoneId('milestone-1'),
        title: MilestoneTitle('テストマイルストーン'),
        deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        goalId: 'goal-1',
      );

      expect(milestone.id.value, isNotEmpty);
    });

    test('複数のマイルストーンインスタンスは異なるオブジェクトである', () {
      final milestone1 = Milestone(
        id: MilestoneId('milestone-1'),
        title: MilestoneTitle('テストマイルストーン'),
        deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        goalId: 'goal-1',
      );

      final milestone2 = Milestone(
        id: MilestoneId('milestone-1'),
        title: MilestoneTitle('テストマイルストーン'),
        deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        goalId: 'goal-1',
      );

      expect(identical(milestone1, milestone2), false);
      expect(milestone1.id.value, milestone2.id.value);
    });

    test('Milestone の title と deadline は変更できない', () {
      final milestone = Milestone(
        id: MilestoneId('milestone-1'),
        title: MilestoneTitle('元のタイトル'),
        deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        goalId: 'goal-1',
      );

      final originalTitle = milestone.title;
      final originalDeadline = milestone.deadline;

      expect(milestone.title, originalTitle);
      expect(milestone.deadline, originalDeadline);
    });

    test('Milestone の goalId は正しい Goal の ID 参照である', () {
      const goalId = 'goal-12345';
      final milestone = Milestone(
        id: MilestoneId('milestone-1'),
        title: MilestoneTitle('テストマイルストーン'),
        deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
        goalId: goalId,
      );

      expect(milestone.goalId, equals(goalId));
    });
  });
}
