import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_title.dart';

/// UpdateTaskUseCase - タスクを更新する
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
    // Load
    final existingTask = await _taskRepository.getTaskById(taskId);
    if (existingTask == null) {
      throw ArgumentError('Task not found');
    }

    // Validate
    final taskTitle = TaskTitle(title);
    final taskDescription = TaskDescription(description);
    final taskDeadline = TaskDeadline(deadline);

    // Execute
    final updatedTask = Task(
      id: existingTask.id,
      title: taskTitle,
      description: taskDescription,
      deadline: taskDeadline,
      status: existingTask.status,
      milestoneId: existingTask.milestoneId,
    );

    // Save
    await _taskRepository.saveTask(updatedTask);

    return updatedTask;
  }
}
