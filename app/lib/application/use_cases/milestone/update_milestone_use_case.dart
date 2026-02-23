import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/services/milestone_completion_service.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

/// UpdateMilestoneUseCase - マイルストーンを更新する
abstract class UpdateMilestoneUseCase {
  Future<Milestone> call({
    required String milestoneId,
    required String title,
    required String description,
    required DateTime deadline,
  });
}

/// UpdateMilestoneUseCaseImpl - UpdateMilestoneUseCase の実装
class UpdateMilestoneUseCaseImpl implements UpdateMilestoneUseCase {
  final MilestoneRepository _milestoneRepository;
  final MilestoneCompletionService _milestoneCompletionService;

  UpdateMilestoneUseCaseImpl(
    this._milestoneRepository,
    this._milestoneCompletionService,
  );

  @override
  Future<Milestone> call({
    required String milestoneId,
    required String title,
    required String description,
    required DateTime deadline,
  }) async {
    final existingMilestone = await _milestoneRepository.getMilestoneById(
      milestoneId,
    );
    if (existingMilestone == null) {
      throw ArgumentError('対象のマイルストーンが見つかりません');
    }

    if (await _milestoneCompletionService.isMilestoneCompleted(milestoneId)) {
      throw ArgumentError('完了したマイルストーンは更新できません');
    }

    final itemTitle = ItemTitle(title);
    final itemDescription = ItemDescription(description);
    final itemDeadline = ItemDeadline(deadline);

    final updatedMilestone = Milestone(
      itemId: existingMilestone.itemId,
      title: itemTitle,
      description: itemDescription,
      deadline: itemDeadline,
      goalId: existingMilestone.goalId,
    );

    await _milestoneRepository.saveMilestone(updatedMilestone);

    return updatedMilestone;
  }
}
