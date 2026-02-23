import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// GetTaskByIdUseCase - ID からタスクを取得する
///
/// タスク詳細画面で使用される
abstract class GetTaskByIdUseCase {
  Future<Task?> call(String taskId);
}

/// GetTaskByIdUseCaseImpl - GetTaskByIdUseCase の実装
class GetTaskByIdUseCaseImpl implements GetTaskByIdUseCase {
  final TaskRepository _taskRepository;

  GetTaskByIdUseCaseImpl(this._taskRepository);

  @override
  Future<Task?> call(String taskId) async {
    if (taskId.isEmpty) {
      throw ArgumentError('タスクIDが正しくありません');
    }
    return await _taskRepository.getTaskById(taskId);
  }
}
