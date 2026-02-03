import 'package:app/infrastructure/repositories/goal_repository.dart';
import 'package:app/infrastructure/repositories/milestone_repository.dart';

/// DeleteGoalUseCase - ゴールを削除する
///
/// 要件: 削除時は配下のマイルストーン・タスクをすべて削除（カスケード）
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
      throw ArgumentError('goalId must not be empty');
    }

    // ゴールが存在することを確認
    final goal = await _goalRepository.getGoalById(goalId);
    if (goal == null) {
      throw ArgumentError('Goal with id $goalId not found');
    }

    // 配下のマイルストーン・タスクをすべて削除（カスケード）
    await _milestoneRepository.deleteMilestonesByGoalId(goalId);

    // ゴールを削除
    await _goalRepository.deleteGoal(goalId);
  }
}
