import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/domain/value_objects/shared/progress.dart';

void main() {
  group('Progress - 進捗計算の境界値テスト', () {
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    group('Task ステータスと Progress の自動計算', () {
      test('should_return_0_progress_when_task_is_todo - '
          'タスクが Todo の時、進捗が 0% である', () {
        // Arrange & Act
        final task = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-1',
        );

        // Assert
        expect(
          task.getProgress().value,
          0,
          reason: 'Todo status = 0% progress',
        );
      });

      test('should_return_50_progress_when_task_is_doing - '
          'タスクが Doing の時、進捗が 50% である', () {
        // Arrange & Act
        final task = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.doing(),
          milestoneId: 'milestone-1',
        );

        // Assert
        expect(
          task.getProgress().value,
          50,
          reason: 'Doing status = 50% progress',
        );
      });

      test('should_return_100_progress_when_task_is_done - '
          'タスクが Done の時、進捗が 100% である', () {
        // Arrange & Act
        final task = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.done(),
          milestoneId: 'milestone-1',
        );

        // Assert
        expect(
          task.getProgress().value,
          100,
          reason: 'Done status = 100% progress',
        );
      });
    });

    group('Milestone 進捗計算 - 子タスクなし', () {
      test('should_return_0_progress_when_milestone_has_no_tasks - '
          'マイルストーンにタスクがない場合、進捗が 0% である', () {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('マイルストーン'),
          deadline: MilestoneDeadline(tomorrow),
          goalId: 'goal-1',
        );

        // Act
        final progress = milestone.calculateProgress([]);

        // Assert
        expect(progress.value, 0, reason: 'No tasks = 0% progress');
      });
    });

    group('Milestone 進捗計算 - 複数タスク', () {
      test('should_calculate_average_progress_with_single_task - '
          'マイルストーンに1つのタスクがある場合、そのタスクの進捗を返す', () {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('マイルストーン'),
          deadline: MilestoneDeadline(tomorrow),
          goalId: 'goal-1',
        );

        // Act
        final progress = milestone.calculateProgress([Progress(50)]);

        // Assert
        expect(progress.value, 50, reason: 'Single task progress');
      });

      test('should_calculate_average_progress_with_multiple_tasks - '
          'マイルストーンに複数タスクがある場合、その平均進捗を返す', () {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('マイルストーン'),
          deadline: MilestoneDeadline(tomorrow),
          goalId: 'goal-1',
        );

        // Act - (0 + 50 + 100) / 3 = 50
        final progress = milestone.calculateProgress([
          Progress(0),
          Progress(50),
          Progress(100),
        ]);

        // Assert
        expect(progress.value, 50, reason: 'Average of [0, 50, 100] = 50');
      });

      test('should_return_100_when_all_tasks_completed - '
          'すべてのタスクが完了している場合、進捗が 100% である', () {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('マイルストーン'),
          deadline: MilestoneDeadline(tomorrow),
          goalId: 'goal-1',
        );

        // Act
        final progress = milestone.calculateProgress([
          Progress(100),
          Progress(100),
          Progress(100),
        ]);

        // Assert
        expect(progress.value, 100, reason: 'All tasks completed = 100%');
      });

      test('should_return_0_when_all_tasks_not_started - '
          'すべてのタスクが未開始の場合、進捗が 0% である', () {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('マイルストーン'),
          deadline: MilestoneDeadline(tomorrow),
          goalId: 'goal-1',
        );

        // Act
        final progress = milestone.calculateProgress([
          Progress(0),
          Progress(0),
          Progress(0),
        ]);

        // Assert
        expect(progress.value, 0, reason: 'No tasks started = 0%');
      });

      test('should_return_integer_average_when_dividing_evenly - '
          '平均が整数で割り切れる場合、正確に計算される', () {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('マイルストーン'),
          deadline: MilestoneDeadline(tomorrow),
          goalId: 'goal-1',
        );

        // Act - (25 + 75) / 2 = 50
        final progress = milestone.calculateProgress([
          Progress(25),
          Progress(75),
        ]);

        // Assert
        expect(progress.value, 50, reason: '(25 + 75) / 2 = 50');
      });

      test('should_floor_fractional_progress - '
          '平均が小数の場合、床関数（ 下限）で丸める', () {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('マイルストーン'),
          deadline: MilestoneDeadline(tomorrow),
          goalId: 'goal-1',
        );

        // Act - (0 + 0 + 50) / 3 = 16.666... → 16
        final progress = milestone.calculateProgress([
          Progress(0),
          Progress(0),
          Progress(50),
        ]);

        // Assert
        expect(progress.value, 16, reason: '(0 + 0 + 50) / 3 = 16 (floor)');
      });

      test('should_handle_large_number_of_tasks - '
          '大量のタスク（100個以上）でも正確に計算される', () {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('マイルストーン'),
          deadline: MilestoneDeadline(tomorrow),
          goalId: 'goal-1',
        );

        // Act - 100個のタスク、それぞれ進捗 1%
        final progresses = List.generate(100, (_) => Progress(1));
        final progress = milestone.calculateProgress(progresses);

        // Assert - (1 + 1 + ... + 1) / 100 = 1
        expect(progress.value, 1, reason: '100 tasks with 1% each = 1%');
      });

      test('should_handle_mixed_progress_values - '
          'さまざまな進捗値が混在している場合、正確に計算される', () {
        // Arrange
        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('マイルストーン'),
          deadline: MilestoneDeadline(tomorrow),
          goalId: 'goal-1',
        );

        // Act - (0 + 25 + 50 + 75 + 100) / 5 = 50
        final progress = milestone.calculateProgress([
          Progress(0),
          Progress(25),
          Progress(50),
          Progress(75),
          Progress(100),
        ]);

        // Assert
        expect(
          progress.value,
          50,
          reason: 'Mixed values: (0 + 25 + 50 + 75 + 100) / 5 = 50',
        );
      });
    });

    group('Goal 進捗計算 - マイルストーンなし', () {
      test('should_return_0_progress_when_goal_has_no_milestones - '
          'ゴールにマイルストーンがない場合、進捗が 0% である', () {
        // Arrange
        final goal = Goal(
          id: GoalId.generate(),
          title: GoalTitle('ゴール'),
          category: GoalCategory('カテゴリ'),
          reason: GoalReason('理由'),
          deadline: GoalDeadline(tomorrow),
        );

        // Act
        final progress = goal.calculateProgress([]);

        // Assert
        expect(progress.value, 0, reason: 'No milestones = 0% progress');
      });
    });

    group('Goal 進捗計算 - 複数マイルストーン', () {
      test('should_calculate_average_progress_with_multiple_milestones - '
          'ゴールに複数マイルストーンがある場合、その平均進捗を返す', () {
        // Arrange
        final goal = Goal(
          id: GoalId.generate(),
          title: GoalTitle('ゴール'),
          category: GoalCategory('カテゴリ'),
          reason: GoalReason('理由'),
          deadline: GoalDeadline(tomorrow),
        );

        // Act - (0 + 50 + 100) / 3 = 50
        final progress = goal.calculateProgress([
          Progress(0),
          Progress(50),
          Progress(100),
        ]);

        // Assert
        expect(progress.value, 50, reason: 'Average milestone progress');
      });

      test('should_return_100_when_all_milestones_completed - '
          'すべてのマイルストーンが完了している場合、進捗が 100% である', () {
        // Arrange
        final goal = Goal(
          id: GoalId.generate(),
          title: GoalTitle('ゴール'),
          category: GoalCategory('カテゴリ'),
          reason: GoalReason('理由'),
          deadline: GoalDeadline(tomorrow),
        );

        // Act
        final progress = goal.calculateProgress([
          Progress(100),
          Progress(100),
          Progress(100),
        ]);

        // Assert
        expect(progress.value, 100, reason: 'All milestones completed = 100%');
      });
    });

    group('進捗の段階的変化', () {
      test('should_show_progress_change_when_single_task_completes - '
          '単一タスクが完了すると、マイルストーン進捗が 50% から 100% に変わる', () {
        // Arrange
        final taskInitial = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(tomorrow),
          status: TaskStatus.doing(), // 50%
          milestoneId: 'milestone-1',
        );

        final milestone = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('マイルストーン'),
          deadline: MilestoneDeadline(tomorrow),
          goalId: 'goal-1',
        );

        // Act - Initial progress
        final initialProgress = milestone.calculateProgress([
          taskInitial.getProgress(),
        ]);

        // タスク完了後
        final taskCompleted = taskInitial.cycleStatus(); // Doing → Done
        final completedProgress = milestone.calculateProgress([
          taskCompleted.getProgress(),
        ]);

        // Assert
        expect(initialProgress.value, 50, reason: 'Doing task = 50%');
        expect(completedProgress.value, 100, reason: 'Done task = 100%');
      });

      test('should_show_progress_change_when_one_of_three_tasks_completes - '
          '3つのタスク中1つが完了すると、進捗が段階的に増加する', () {
        // Arrange
        final milestoneProgress = Milestone(
          id: MilestoneId.generate(),
          title: MilestoneTitle('マイルストーン'),
          deadline: MilestoneDeadline(tomorrow),
          goalId: 'goal-1',
        );

        // Act
        // すべて Todo (0%) の場合
        final allTodo = milestoneProgress.calculateProgress([
          Progress(0),
          Progress(0),
          Progress(0),
        ]);

        // 1つが Done (100%), 残り Todo の場合
        final oneCompleted = milestoneProgress.calculateProgress([
          Progress(100),
          Progress(0),
          Progress(0),
        ]);

        // すべてが Done の場合
        final allCompleted = milestoneProgress.calculateProgress([
          Progress(100),
          Progress(100),
          Progress(100),
        ]);

        // Assert
        expect(allTodo.value, 0, reason: 'All Todo = 0%');
        expect(
          oneCompleted.value,
          33,
          reason: '(100 + 0 + 0) / 3 = 33 (floor)',
        );
        expect(allCompleted.value, 100, reason: 'All Done = 100%');
      });
    });
  });
}
