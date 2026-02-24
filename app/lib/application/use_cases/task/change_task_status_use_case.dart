import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/application/exceptions/use_case_exception.dart';

/// ChangeTaskStatusUseCase - タスクのステータスを変更する
abstract class ChangeTaskStatusUseCase {
  Future<Task> call(String taskId);
}

/// ChangeTaskStatusUseCaseImpl - ChangeTaskStatusUseCase の実装
class ChangeTaskStatusUseCaseImpl implements ChangeTaskStatusUseCase {
  ChangeTaskStatusUseCaseImpl(this._taskRepository);
  final TaskRepository _taskRepository;

  @override
  Future<Task> call(String taskId) async {
    if (taskId.isEmpty) {
      throw ValidationException('タスクIDが正しくありません');
    }

    final existingTask = await _taskRepository.getTaskById(taskId);
    if (existingTask == null) {
      throw NotFoundException('対象のタスクが見つかりません');
    }

    final updatedTask = existingTask.cycleStatus();
    await _taskRepository.saveTask(updatedTask);

    return updatedTask;
  }
}
