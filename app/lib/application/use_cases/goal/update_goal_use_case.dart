import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/services/goal_completion_service.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/application/exceptions/use_case_exception.dart';

/// UpdateGoalUseCase - ゴールを更新する
abstract class UpdateGoalUseCase {
  Future<Goal> call({
    required String goalId,
    required String title,
    required String category,
    required String description,
    required DateTime deadline,
  });
}

/// UpdateGoalUseCaseImpl - UpdateGoalUseCase の実装
class UpdateGoalUseCaseImpl implements UpdateGoalUseCase {
  UpdateGoalUseCaseImpl(this._goalRepository, this._goalCompletionService);
  final GoalRepository _goalRepository;
  final GoalCompletionService _goalCompletionService;

  @override
  Future<Goal> call({
    required String goalId,
    required String title,
    required String category,
    required String description,
    required DateTime deadline,
  }) async {
    final existingGoal = await _goalRepository.getGoalById(goalId);
    if (existingGoal == null) {
      throw NotFoundException('対象のゴールが見つかりません');
    }

    if (await _goalCompletionService.isGoalCompleted(goalId)) {
      throw BusinessRuleException('完了したゴールは更新できません');
    }

    final itemTitle = ItemTitle(title);
    final goalCategory = GoalCategory(category);
    final itemDescription = ItemDescription(description);
    final itemDeadline = ItemDeadline(deadline);

    final updatedGoal = Goal(
      itemId: existingGoal.itemId,
      title: itemTitle,
      category: goalCategory,
      description: itemDescription,
      deadline: itemDeadline,
    );

    await _goalRepository.saveGoal(updatedGoal);

    return updatedGoal;
  }
}
