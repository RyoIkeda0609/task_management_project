import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/infrastructure/repositories/task_repository.dart';

/// UpdateTaskUseCase - タスクを編集する
///
/// タスク詳細画面で使用される
abstract class UpdateTaskUseCase {
  Future<Task> call({
    required String taskId,
    required String title,
    required String description,
    required DateTime deadline,
  });
}

/// UpdateTaskUseCaseImpl - UpdateTaskUseCase の実装
class UpdateTaskUseCaseImpl implements UpdateTaskUseCase {
  final TaskRepository _taskRepository;

  UpdateTaskUseCaseImpl(this._taskRepository);

  @override
  Future<Task> call({
    required String taskId,
    required String title,
    required String description,
    required DateTime deadline,
  }) async {
    // 既存タスクを取得
    final existingTask = await _taskRepository.getTaskById(taskId);
    if (existingTask == null) {
      throw ArgumentError('Task with id $taskId not found');
    }

    // ValueObject による入力値検証
    final taskTitle = TaskTitle(title);
    final taskDescription = TaskDescription(description);
    final taskDeadline = TaskDeadline(deadline);

    // 更新されたタスクエンティティの作成（ステータスは変更しない）
    final updatedTask = Task(
      id: existingTask.id,
      title: taskTitle,
      description: taskDescription,
      deadline: taskDeadline,
      status: existingTask.status,
      milestoneId: existingTask.milestoneId,
    );

    await _taskRepository.saveTask(updatedTask);
    return updatedTask;
  }
}
