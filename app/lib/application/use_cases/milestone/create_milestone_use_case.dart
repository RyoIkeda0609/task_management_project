import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/application/exceptions/use_case_exception.dart';

/// CreateMilestoneUseCase - マイルストーンを作成する
abstract class CreateMilestoneUseCase {
  Future<Milestone> call({
    required String title,
    required String description,
    required DateTime deadline,
    required String goalId,
  });
}

/// CreateMilestoneUseCaseImpl - CreateMilestoneUseCase の実装
class CreateMilestoneUseCaseImpl implements CreateMilestoneUseCase {
  CreateMilestoneUseCaseImpl(this._milestoneRepository, this._goalRepository);
  final MilestoneRepository _milestoneRepository;
  final GoalRepository _goalRepository;

  @override
  Future<Milestone> call({
    required String title,
    required String description,
    required DateTime deadline,
    required String goalId,
  }) async {
    final itemTitle = ItemTitle(title);
    final itemDescription = ItemDescription(description);
    final itemDeadline = ItemDeadline(deadline);

    if (goalId.isEmpty) {
      throw ValidationException('ゴールIDが正しくありません');
    }

    final goal = await _goalRepository.getGoalById(goalId);
    if (goal == null) {
      throw NotFoundException('指定されたゴールが見つかりません');
    }

    final milestone = Milestone(
      itemId: ItemId.generate(),
      title: itemTitle,
      description: itemDescription,
      deadline: itemDeadline,
      goalId: ItemId(goalId),
    );

    await _milestoneRepository.saveMilestone(milestone);

    return milestone;
  }
}
