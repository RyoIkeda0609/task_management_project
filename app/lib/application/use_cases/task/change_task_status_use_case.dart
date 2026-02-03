import 'package:app/domain/entities/task.dart';
import 'package:app/infrastructure/repositories/task_repository.dart';

/// ChangeTaskStatusUseCase - タスクのステータスを変更する
///
/// 要件: 状態変更はユーザー操作でのみ行われる
/// 状態遷移: Todo → Doing → Done → Todo（循環）
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
      throw ArgumentError('taskId must not be empty');
    }

    // 既存タスクを取得
    final existingTask = await _taskRepository.getTaskById(taskId);
    if (existingTask == null) {
      throw ArgumentError('Task with id $taskId not found');
    }

    // ステータスを次の状態に遷移（Todo→Doing→Done→Todo）
    final updatedTask = existingTask.cycleStatus();

    await _taskRepository.saveTask(updatedTask);
    return updatedTask;
  }
}
