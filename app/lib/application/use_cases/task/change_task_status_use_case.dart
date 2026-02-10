import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// ChangeTaskStatusUseCase - タスクのステータスを変更する
abstract class ChangeTaskStatusUseCase {
  Future<Task> call(String taskId);
}

/// ChangeTaskStatusUseCaseImpl - ChangeTaskStatusUseCase の実装
class ChangeTaskStatusUseCaseImpl implements ChangeTaskStatusUseCase {
  final TaskRepository _taskRepository;

  ChangeTaskStatusUseCaseImpl(this._taskRepository);

  @override
  Future<Task> call(String taskId) async {
    if (taskId.isEmpty) {
      throw ArgumentError('タスクIDが無効です');
    }

    // Load
    final existingTask = await _taskRepository.getTaskById(taskId);
    if (existingTask == null) {
      throw ArgumentError('対象のタスクが見つかりません');
    }

    // Execute
    final updatedTask = existingTask.cycleStatus();

    // Save
    await _taskRepository.saveTask(updatedTask);

    return updatedTask;
  }
}
