import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/value_objects/task/task_title.dart';

/// CreateTaskUseCase - タスクを新規作成する
abstract class CreateTaskUseCase {
  Future<Task> call({
    required String title,
    required String description,
    required DateTime deadline,
    required String milestoneId,
  });
}

/// CreateTaskUseCaseImpl - CreateTaskUseCase の実装
class CreateTaskUseCaseImpl implements CreateTaskUseCase {
  final TaskRepository _taskRepository;

  CreateTaskUseCaseImpl(this._taskRepository);

  @override
  Future<Task> call({
    required String title,
    required String description,
    required DateTime deadline,
    required String milestoneId,
  }) async {
    // Validate
    final taskTitle = TaskTitle(title);

    // Description: 任意フィールド、空文字許容、ただし500文字制限
    if (description.trim().isNotEmpty && description.length > 500) {
      throw ArgumentError('説明は500文字以下で入力してください');
    }
    final taskDescription = TaskDescription(description);

    final taskDeadline = TaskDeadline(deadline);

    if (milestoneId.isEmpty) {
      throw ArgumentError('マイルストーンが無効です');
    }

    // Execute
    final task = Task(
      id: TaskId.generate(),
      title: taskTitle,
      description: taskDescription,
      deadline: taskDeadline,
      status: TaskStatus.todo(),
      milestoneId: milestoneId,
    );

    // Save
    await _taskRepository.saveTask(task);

    return task;
  }
}
