import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:flutter/foundation.dart';

/// DeleteGoalUseCase - ゴールを削除する
abstract class DeleteGoalUseCase {
  Future<void> call(String goalId);
}

/// DeleteGoalUseCaseImpl - DeleteGoalUseCase の実装
class DeleteGoalUseCaseImpl implements DeleteGoalUseCase {
  final GoalRepository _goalRepository;
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;

  DeleteGoalUseCaseImpl(
    this._goalRepository,
    this._milestoneRepository,
    this._taskRepository,
  );

  @override
  Future<void> call(String goalId) async {
    if (goalId.isEmpty) {
      throw ArgumentError('ゴールIDが正しくありません');
    }

    // Load
    final goal = await _goalRepository.getGoalById(goalId);
    if (goal == null) {
      throw ArgumentError('対象のゴールが見つかりません');
    }

    // Execute: カスケード削除 (Goal → Milestone → Task の順序で削除)
    // 1. 削除対象のMilestoneをすべて取得
    final milestonesToDelete = await _milestoneRepository.getMilestonesByGoalId(
      goalId,
    );
    debugPrint(
      '[DeleteGoalUseCase] Goal ID: $goalId, Milestones to delete: ${milestonesToDelete.length}',
    );

    // 2. 各MilestoneのIDでTaskをすべて削除
    for (final milestone in milestonesToDelete) {
      debugPrint(
        '[DeleteGoalUseCase] Deleting tasks for Milestone ID: ${milestone.id.value}',
      );
      await _taskRepository.deleteTasksByMilestoneId(milestone.id.value);
    }

    // 3. MilestoneをすべてGoalIDで削除
    debugPrint('[DeleteGoalUseCase] Deleting milestones for Goal ID: $goalId');
    await _milestoneRepository.deleteMilestonesByGoalId(goalId);

    // 4. Goalを削除
    debugPrint('[DeleteGoalUseCase] Deleting goal ID: $goalId');
    await _goalRepository.deleteGoal(goalId);

    debugPrint(
      '[DeleteGoalUseCase] Cascade deletion completed for Goal ID: $goalId',
    );
  }
}
