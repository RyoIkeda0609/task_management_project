import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';

/// CreateGoalUseCase - ゴールを作成する
abstract class CreateGoalUseCase {
  Future<Goal> call({
    required String title,
    required String category,
    required String reason,
    required DateTime deadline,
  });
}

/// CreateGoalUseCaseImpl - CreateGoalUseCase の実装
class CreateGoalUseCaseImpl implements CreateGoalUseCase {
  final GoalRepository _goalRepository;

  CreateGoalUseCaseImpl(this._goalRepository);

  @override
  Future<Goal> call({
    required String title,
    required String category,
    required String reason,
    required DateTime deadline,
  }) async {
    // Validate
    final goalTitle = GoalTitle(title);
    final goalCategory = GoalCategory(category);
    final goalReason = GoalReason(reason);
    final goalDeadline = GoalDeadline(deadline);

    // Execute
    final goal = Goal(
      id: GoalId.generate(),
      title: goalTitle,
      category: goalCategory,
      reason: goalReason,
      deadline: goalDeadline,
    );

    // Save
    await _goalRepository.saveGoal(goal);

    return goal;
  }
}
