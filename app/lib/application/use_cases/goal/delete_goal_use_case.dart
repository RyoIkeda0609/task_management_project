import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';

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

    final goal = await _goalRepository.getGoalById(goalId);
    if (goal == null) {
      throw ArgumentError('対象のゴールが見つかりません');
    }

    final milestonesToDelete = await _milestoneRepository.getMilestonesByGoalId(
      goalId,
    );

    for (final milestone in milestonesToDelete) {
      await _taskRepository.deleteTasksByMilestoneId(milestone.itemId.value);
    }

    await _milestoneRepository.deleteMilestonesByGoalId(goalId);
    await _goalRepository.deleteGoal(goalId);
  }
}
