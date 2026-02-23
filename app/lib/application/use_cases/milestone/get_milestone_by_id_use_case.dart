import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/milestone_repository.dart';

/// GetMilestoneByIdUseCase - ID からマイルストーンを取得する
///
/// マイルストーン詳細画面で使用される
abstract class GetMilestoneByIdUseCase {
  Future<Milestone?> call(String milestoneId);
}

/// GetMilestoneByIdUseCaseImpl - GetMilestoneByIdUseCase の実装
class GetMilestoneByIdUseCaseImpl implements GetMilestoneByIdUseCase {
  final MilestoneRepository _milestoneRepository;

  GetMilestoneByIdUseCaseImpl(this._milestoneRepository);

  @override
  Future<Milestone?> call(String milestoneId) async {
    if (milestoneId.isEmpty) {
      throw ArgumentError('マイルストーンIDが正しくありません');
    }
    return await _milestoneRepository.getMilestoneById(milestoneId);
  }
}
