import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';

/// CreateMilestoneUseCase - マイルストーンを作成する
abstract class CreateMilestoneUseCase {
  Future<Milestone> call({
    required String title,
    required DateTime deadline,
    required String goalId,
  });
}

/// CreateMilestoneUseCaseImpl - CreateMilestoneUseCase の実装
class CreateMilestoneUseCaseImpl implements CreateMilestoneUseCase {
  final MilestoneRepository _milestoneRepository;

  CreateMilestoneUseCaseImpl(this._milestoneRepository);

  @override
  Future<Milestone> call({
    required String title,
    required DateTime deadline,
    required String goalId,
  }) async {
    // Validate
    final milestoneTitle = MilestoneTitle(title);
    final milestoneDeadline = MilestoneDeadline(deadline);

    if (goalId.isEmpty) {
      throw ArgumentError('ゴールIDが無効です');
    }

    // Execute
    final milestone = Milestone(
      id: MilestoneId.generate(),
      title: milestoneTitle,
      deadline: milestoneDeadline,
      goalId: goalId,
    );

    // Save
    await _milestoneRepository.saveMilestone(milestone);

    return milestone;
  }
}
