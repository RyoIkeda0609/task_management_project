import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// DeleteMilestoneUseCase - マイルストーンを削除する
abstract class DeleteMilestoneUseCase {
  Future<void> call(String milestoneId);
}

/// DeleteMilestoneUseCaseImpl - DeleteMilestoneUseCase の実装
class DeleteMilestoneUseCaseImpl implements DeleteMilestoneUseCase {
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;

  DeleteMilestoneUseCaseImpl(this._milestoneRepository, this._taskRepository);

  @override
  Future<void> call(String milestoneId) async {
    if (milestoneId.isEmpty) {
      throw ArgumentError('マイルストーンIDが正しくありません');
    }

    // Load
    final milestone = await _milestoneRepository.getMilestoneById(milestoneId);
    if (milestone == null) {
      throw ArgumentError('対象のマイルストーンが見つかりません');
    }

    // Execute
    await _taskRepository.deleteTasksByMilestoneId(milestoneId);
    await _milestoneRepository.deleteMilestone(milestoneId);
  }
}
