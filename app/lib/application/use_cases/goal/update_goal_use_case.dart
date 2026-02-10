import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/services/goal_completion_service.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';

/// UpdateGoalUseCase - ゴールを更新する
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
  final GoalCompletionService _goalCompletionService;

  UpdateGoalUseCaseImpl(this._goalRepository, this._goalCompletionService);

  @override
  Future<Goal> call({
    required String goalId,
    required String title,
    required String category,
    required String reason,
    required DateTime deadline,
  }) async {
    // Load
    final existingGoal = await _goalRepository.getGoalById(goalId);
    if (existingGoal == null) {
      throw ArgumentError('対象のゴールが見つかりません');
    }

    if (await _goalCompletionService.isGoalCompleted(goalId)) {
      throw ArgumentError('完了したゴールは更新できません');
    }

    // Validate
    final goalTitle = GoalTitle(title);
    final goalCategory = GoalCategory(category);
    final goalReason = GoalReason(reason);
    final goalDeadline = GoalDeadline(deadline);

    // Execute
    final updatedGoal = Goal(
      id: existingGoal.id,
      title: goalTitle,
      category: goalCategory,
      reason: goalReason,
      deadline: goalDeadline,
    );

    // Save
    await _goalRepository.saveGoal(updatedGoal);

    return updatedGoal;
  }
}
