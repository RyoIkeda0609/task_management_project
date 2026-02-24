import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/application/exceptions/use_case_exception.dart';

/// GetMilestoneByIdUseCase - ID からマイルストーンを取得する
///
/// マイルストーン詳細画面で使用される
abstract class GetMilestoneByIdUseCase {
  Future<Milestone?> call(String milestoneId);
}

/// GetMilestoneByIdUseCaseImpl - GetMilestoneByIdUseCase の実装
class GetMilestoneByIdUseCaseImpl implements GetMilestoneByIdUseCase {
  GetMilestoneByIdUseCaseImpl(this._milestoneRepository);
  final MilestoneRepository _milestoneRepository;

  @override
  Future<Milestone?> call(String milestoneId) async {
    if (milestoneId.isEmpty) {
      throw ValidationException('マイルストーンIDが正しくありません');
    }
    return await _milestoneRepository.getMilestoneById(milestoneId);
  }
}
