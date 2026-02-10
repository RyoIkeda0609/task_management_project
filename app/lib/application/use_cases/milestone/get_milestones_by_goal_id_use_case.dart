import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/milestone_repository.dart';

/// GetMilestonesByGoalIdUseCase - ゴール配下のマイルストーンをすべて取得する
///
/// ゴール詳細画面で使用される
abstract class GetMilestonesByGoalIdUseCase {
  Future<List<Milestone>> call(String goalId);
}

/// GetMilestonesByGoalIdUseCaseImpl - GetMilestonesByGoalIdUseCase の実装
class GetMilestonesByGoalIdUseCaseImpl implements GetMilestonesByGoalIdUseCase {
  final MilestoneRepository _milestoneRepository;

  GetMilestonesByGoalIdUseCaseImpl(this._milestoneRepository);

  @override
  Future<List<Milestone>> call(String goalId) async {
    if (goalId.isEmpty) {
      throw ArgumentError('ゴールIDが正しくありません');
    }
    return await _milestoneRepository.getMilestonesByGoalId(goalId);
  }
}
