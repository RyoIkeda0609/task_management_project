import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/repositories/milestone_repository.dart';

/// CreateMilestoneUseCase - 新しいマイルストーンを作成する
///
/// ビジネスロジック：
/// - マイルストーン ID は自動生成される
/// - すべての入力値は ValueObject でバリデーションされる
/// - 親ゴール ID が必須
/// - Domain を作成してから Repository に保存する
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
    // ValueObject による入力値検証
    final milestoneTitle = MilestoneTitle(title);
    final milestoneDeadline = MilestoneDeadline(deadline);

    // goalId の検証（空文字列でないかチェック）
    if (goalId.isEmpty) {
      throw ArgumentError('goalId cannot be empty');
    }

    // Milestone エンティティの作成
    final milestone = Milestone(
      id: MilestoneId.generate(),
      title: milestoneTitle,
      deadline: milestoneDeadline,
      goalId: goalId,
    );

    // Repository に保存
    await _milestoneRepository.saveMilestone(milestone);

    return milestone;
  }
}
