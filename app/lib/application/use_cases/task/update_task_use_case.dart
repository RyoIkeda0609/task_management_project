import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/services/task_completion_service.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

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
  final TaskCompletionService _taskCompletionService;

  UpdateTaskUseCaseImpl(this._taskRepository, this._taskCompletionService);

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
      throw ArgumentError('対象のタスクが見つかりません');
    }

    // Check if task is completed (Done) - if so, cannot be edited
    if (await _taskCompletionService.isTaskCompleted(taskId)) {
      throw ArgumentError('完了したタスクは更新できません');
    }

    // Validate
    final itemTitle = ItemTitle(title);

    // Description: 任意フィールド、空文字許容、ただし500文字制限
    if (description.trim().isNotEmpty && description.length > 500) {
      throw ArgumentError('説明は500文字以下で入力してください');
    }
    final itemDescription = ItemDescription(description);

    final itemDeadline = ItemDeadline(deadline);

    // Execute
    final updatedTask = Task(
      itemId: existingTask.itemId,
      title: itemTitle,
      description: itemDescription,
      deadline: itemDeadline,
      status: existingTask.status,
      milestoneId: existingTask.milestoneId,
    );

    // Save
    await _taskRepository.saveTask(updatedTask);

    return updatedTask;
  }
}
