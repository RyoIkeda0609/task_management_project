import 'package:app/domain/repositories/task_repository.dart';

/// DeleteTaskUseCase - タスクを削除する
abstract class DeleteTaskUseCase {
  Future<void> call(String taskId);
}

/// DeleteTaskUseCaseImpl - DeleteTaskUseCase の実装
class DeleteTaskUseCaseImpl implements DeleteTaskUseCase {
  final TaskRepository _taskRepository;

  DeleteTaskUseCaseImpl(this._taskRepository);

  @override
  Future<void> call(String taskId) async {
    if (taskId.isEmpty) {
      throw ArgumentError('Task ID is required');
    }

    // Load
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw ArgumentError('Task not found');
    }

    // Execute
    await _taskRepository.deleteTask(taskId);
  }
}
