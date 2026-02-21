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

    // 2. 各MilestoneのIDでTaskをすべて削除
    for (final milestone in milestonesToDelete) {
      await _taskRepository.deleteTasksByMilestoneId(milestone.itemId.value);
    }

    // 3. MilestoneをすべてGoalIDで削除
    await _milestoneRepository.deleteMilestonesByGoalId(goalId);

    // 4. Goalを削除
    await _goalRepository.deleteGoal(goalId);
  }
}
