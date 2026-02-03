import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// DeleteMilestoneUseCase - マイルストーンを削除する
///
/// 要件: 削除時は配下タスクをすべて削除（カスケード）
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
      throw ArgumentError('milestoneId must not be empty');
    }

    // マイルストーンが存在することを確認
    final milestone = await _milestoneRepository.getMilestoneById(milestoneId);
    if (milestone == null) {
      throw ArgumentError('Milestone with id $milestoneId not found');
    }

    // 配下のタスクをすべて削除（カスケード）
    await _taskRepository.deleteTasksByMilestoneId(milestoneId);

    // マイルストーンを削除
    await _milestoneRepository.deleteMilestone(milestoneId);
  }
}
