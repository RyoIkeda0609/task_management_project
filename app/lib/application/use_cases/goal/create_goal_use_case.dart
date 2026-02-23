import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

/// CreateGoalUseCase - ゴールを作成する
abstract class CreateGoalUseCase {
  Future<Goal> call({
    required String title,
    required String category,
    required String description,
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
    required String description,
    required DateTime deadline,
  }) async {
    final itemTitle = ItemTitle(title);
    final goalCategory = GoalCategory(category);
    final itemDescription = ItemDescription(description);
    final itemDeadline = ItemDeadline(deadline);

    final goal = Goal(
      itemId: ItemId.generate(),
      title: itemTitle,
      category: goalCategory,
      description: itemDescription,
      deadline: itemDeadline,
    );

    await _goalRepository.saveGoal(goal);

    return goal;
  }
}
