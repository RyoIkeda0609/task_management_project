import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/services/task_completion_service.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/application/exceptions/use_case_exception.dart';

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
  UpdateTaskUseCaseImpl(this._taskRepository, this._taskCompletionService);
  final TaskRepository _taskRepository;
  final TaskCompletionService _taskCompletionService;

  @override
  Future<Task> call({
    required String taskId,
    required String title,
    required String description,
    required DateTime deadline,
  }) async {
    final existingTask = await _taskRepository.getTaskById(taskId);
    if (existingTask == null) {
      throw NotFoundException('対象のタスクが見つかりません');
    }

    if (await _taskCompletionService.isTaskCompleted(taskId)) {
      throw BusinessRuleException('完了したタスクは更新できません');
    }

    final itemTitle = ItemTitle(title);
    final itemDescription = ItemDescription(description);

    final itemDeadline = ItemDeadline(deadline);

    final updatedTask = Task(
      itemId: existingTask.itemId,
      title: itemTitle,
      description: itemDescription,
      deadline: itemDeadline,
      status: existingTask.status,
      milestoneId: existingTask.milestoneId,
    );

    await _taskRepository.saveTask(updatedTask);

    return updatedTask;
  }
}
