import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';

/// CreateMilestoneUseCase - 新しいマイルストーンを作成する
///
/// ビジネスロジック：
/// - マイルストーン ID は自動生成される
/// - 期限は本日より後の日付のみ許可
/// - すべての入力値は ValueObject でバリデーションされる
abstract class CreateMilestoneUseCase {
  Future<Milestone> call({required String title, required DateTime deadline});
}

/// CreateMilestoneUseCaseImpl - CreateMilestoneUseCase の実装
class CreateMilestoneUseCaseImpl implements CreateMilestoneUseCase {
  @override
  Future<Milestone> call({
    required String title,
    required DateTime deadline,
  }) async {
    // ValueObject による入力値検証
    final milestoneTitle = MilestoneTitle(title);
    final milestoneDeadline = MilestoneDeadline(deadline);

    // Milestone エンティティの作成
    final milestone = Milestone(
      id: MilestoneId.generate(),
      title: milestoneTitle,
      deadline: milestoneDeadline,
    );

    return milestone;
  }
}
