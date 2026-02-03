import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/infrastructure/repositories/goal_repository.dart';
import 'package:app/infrastructure/repositories/milestone_repository.dart';
import 'package:app/infrastructure/repositories/task_repository.dart';

/// UpdateGoalUseCase - ゴールを編集する
///
/// ゴール詳細画面で使用される
/// 要件: 進捗100%（完了）のゴールは編集不可
abstract class UpdateGoalUseCase {
  Future<Goal> call({
    required String goalId,
    required String title,
    required String category,
    required String reason,
    required DateTime deadline,
  });
}

/// UpdateGoalUseCaseImpl - UpdateGoalUseCase の実装
class UpdateGoalUseCaseImpl implements UpdateGoalUseCase {
  final GoalRepository _goalRepository;
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;

  UpdateGoalUseCaseImpl(
    this._goalRepository,
    this._milestoneRepository,
    this._taskRepository,
  );

  @override
  Future<Goal> call({
    required String goalId,
    required String title,
    required String category,
    required String reason,
    required DateTime deadline,
  }) async {
    // 既存ゴールを取得
    final existingGoal = await _goalRepository.getGoalById(goalId);
    if (existingGoal == null) {
      throw ArgumentError('Goal with id $goalId not found');
    }

    // ゴール進捗を計算 - 完了（100%）の場合は編集不可
    final milestones = await _milestoneRepository.getMilestonesByGoalId(goalId);

    if (milestones.isNotEmpty) {
      // マイルストーンが存在する場合、各マイルストーンの進捗を計算
      int completedMilestoneCount = 0;
      for (final milestone in milestones) {
        final tasks = await _taskRepository.getTasksByMilestoneId(
          milestone.id.value,
        );

        if (tasks.isEmpty) {
          // タスクが0個のマイルストーン：進捗 0%
          continue;
        }

        // 全タスクが Done なら、このマイルストーンは完了
        final allTasksDone = tasks.every((task) => task.status.isDone);
        if (allTasksDone) {
          completedMilestoneCount++;
        }
      }

      // ゴールの進捗計算：すべてのマイルストーンが完了 = ゴール完了
      final goalProgress = (completedMilestoneCount == milestones.length)
          ? 100
          : 0;

      if (goalProgress == 100) {
        throw ArgumentError('完了したゴール（進捗100%）は編集できません');
      }
    }

    // ValueObject による入力値検証
    final goalTitle = GoalTitle(title);
    final goalCategory = GoalCategory(category);
    final goalReason = GoalReason(reason);
    final goalDeadline = GoalDeadline(deadline);

    // 更新されたゴールエンティティの作成
    final updatedGoal = Goal(
      id: existingGoal.id,
      title: goalTitle,
      category: goalCategory,
      reason: goalReason,
      deadline: goalDeadline,
    );

    await _goalRepository.saveGoal(updatedGoal);
    return updatedGoal;
  }
}
