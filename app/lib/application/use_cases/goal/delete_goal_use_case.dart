import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';

/// DeleteGoalUseCase - ゴールを削除する
abstract class DeleteGoalUseCase {
  Future<void> call(String goalId);
}

/// DeleteGoalUseCaseImpl - DeleteGoalUseCase の実装
class DeleteGoalUseCaseImpl implements DeleteGoalUseCase {
  final GoalRepository _goalRepository;
  final MilestoneRepository _milestoneRepository;

  DeleteGoalUseCaseImpl(this._goalRepository, this._milestoneRepository);

  @override
  Future<void> call(String goalId) async {
    if (goalId.isEmpty) {
      throw ArgumentError('Goal ID is required');
    }

    // Load
    final goal = await _goalRepository.getGoalById(goalId);
    if (goal == null) {
      throw ArgumentError('Goal not found');
    }

    // Execute
    await _milestoneRepository.deleteMilestonesByGoalId(goalId);
    await _goalRepository.deleteGoal(goalId);
  }
}
