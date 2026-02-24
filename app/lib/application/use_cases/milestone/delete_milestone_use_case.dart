import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/application/exceptions/use_case_exception.dart';

/// DeleteMilestoneUseCase - マイルストーンを削除する
abstract class DeleteMilestoneUseCase {
  Future<void> call(String milestoneId);
}

/// DeleteMilestoneUseCaseImpl - DeleteMilestoneUseCase の実装
class DeleteMilestoneUseCaseImpl implements DeleteMilestoneUseCase {
  DeleteMilestoneUseCaseImpl(this._milestoneRepository, this._taskRepository);
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;

  @override
  Future<void> call(String milestoneId) async {
    if (milestoneId.isEmpty) {
      throw ValidationException('マイルストーンIDが正しくありません');
    }

    final milestone = await _milestoneRepository.getMilestoneById(milestoneId);
    if (milestone == null) {
      throw NotFoundException('対象のマイルストーンが見つかりません');
    }

    await _taskRepository.deleteTasksByMilestoneId(milestoneId);
    await _milestoneRepository.deleteMilestone(milestoneId);
  }
}
