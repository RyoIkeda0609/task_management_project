import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/infrastructure/repositories/milestone_repository.dart';

/// UpdateMilestoneUseCase - マイルストーンを編集する
///
/// マイルストーン詳細画面で使用される
/// 要件: 進捗100%（完了）のマイルストーンは編集不可
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
    // 既存マイルストーンを取得
    final existingMilestone = await _milestoneRepository.getMilestoneById(milestoneId);
    if (existingMilestone == null) {
      throw ArgumentError('Milestone with id $milestoneId not found');
    }

    // ValueObject による入力値検証
    final milestoneTitle = MilestoneTitle(title);
    final milestoneDeadline = MilestoneDeadline(deadline);

    // 更新されたマイルストーンエンティティの作成
    final updatedMilestone = Milestone(
      id: existingMilestone.id,
      title: milestoneTitle,
      deadline: milestoneDeadline,
    );

    await _milestoneRepository.saveMilestone(updatedMilestone);
    return updatedMilestone;
  }
}
