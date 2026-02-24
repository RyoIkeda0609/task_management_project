import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/application/exceptions/use_case_exception.dart';

/// GetTasksByMilestoneIdUseCase - マイルストーン配下のタスクをすべて取得する
///
/// マイルストーン詳細画面で使用される
abstract class GetTasksByMilestoneIdUseCase {
  Future<List<Task>> call(String milestoneId);
}

/// GetTasksByMilestoneIdUseCaseImpl - GetTasksByMilestoneIdUseCase の実装
class GetTasksByMilestoneIdUseCaseImpl implements GetTasksByMilestoneIdUseCase {
  GetTasksByMilestoneIdUseCaseImpl(this._taskRepository);
  final TaskRepository _taskRepository;

  @override
  Future<List<Task>> call(String milestoneId) async {
    if (milestoneId.isEmpty) {
      throw ValidationException('マイルストーンIDが正しくありません');
    }
    return await _taskRepository.getTasksByMilestoneId(milestoneId);
  }
}
