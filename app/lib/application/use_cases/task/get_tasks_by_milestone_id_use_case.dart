import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// GetTasksByMilestoneIdUseCase - マイルストーン配下のタスクをすべて取得する
///
/// マイルストーン詳細画面で使用される
abstract class GetTasksByMilestoneIdUseCase {
  Future<List<Task>> call(String milestoneId);
}

/// GetTasksByMilestoneIdUseCaseImpl - GetTasksByMilestoneIdUseCase の実装
class GetTasksByMilestoneIdUseCaseImpl implements GetTasksByMilestoneIdUseCase {
  final TaskRepository _taskRepository;

  GetTasksByMilestoneIdUseCaseImpl(this._taskRepository);

  @override
  Future<List<Task>> call(String milestoneId) async {
    if (milestoneId.isEmpty) {
      throw ArgumentError('マイルストーンIDが正しくありません');
    }
    return await _taskRepository.getTasksByMilestoneId(milestoneId);
  }
}
