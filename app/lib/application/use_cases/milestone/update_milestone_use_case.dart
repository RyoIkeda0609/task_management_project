import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';

/// UpdateMilestoneUseCase - マイルストーンを更新する
abstract class UpdateMilestoneUseCase {
  Future<Milestone> call({
    required String milestoneId,
    required String title,
    required DateTime deadline,
  });
}

/// UpdateMilestoneUseCaseImpl - UpdateMilestoneUseCase の実装
class UpdateMilestoneUseCaseImpl implements UpdateMilestoneUseCase {
  final MilestoneRepository _milestoneRepository;

  UpdateMilestoneUseCaseImpl(this._milestoneRepository);

  @override
  Future<Milestone> call({
    required String milestoneId,
    required String title,
    required DateTime deadline,
  }) async {
    // Load
    final existingMilestone = await _milestoneRepository.getMilestoneById(
      milestoneId,
    );
    if (existingMilestone == null) {
      throw ArgumentError('Milestone not found');
    }

    // Validate
    final milestoneTitle = MilestoneTitle(title);
    final milestoneDeadline = MilestoneDeadline(deadline);

    // Execute
    final updatedMilestone = Milestone(
      id: existingMilestone.id,
      title: milestoneTitle,
      deadline: milestoneDeadline,
      goalId: existingMilestone.goalId,
    );

    // Save
    await _milestoneRepository.saveMilestone(updatedMilestone);

    return updatedMilestone;
  }
}
