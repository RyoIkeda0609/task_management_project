import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

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
  final MilestoneRepository _milestoneRepository;

  CreateTaskUseCaseImpl(this._taskRepository, this._milestoneRepository);

  @override
  Future<Task> call({
    required String title,
    required String description,
    required DateTime deadline,
    required String milestoneId,
  }) async {
    // Validate
    final itemTitle = ItemTitle(title);

    // Description: 任意フィールド、空文字許容、ただし500文字制限
    if (description.trim().isNotEmpty && description.length > 500) {
      throw ArgumentError('説明は500文字以下で入力してください');
    }
    final itemDescription = ItemDescription(description);

    final itemDeadline = ItemDeadline(deadline);

    if (milestoneId.isEmpty) {
      throw ArgumentError('マイルストーンが正しくありません');
    }

    // Check parent existence (Referential Integrity)
    final milestone = await _milestoneRepository.getMilestoneById(milestoneId);
    if (milestone == null) {
      throw ArgumentError('指定されたマイルストーンが見つかりません');
    }

    // Execute
    final task = Task(
      itemId: ItemId.generate(),
      title: itemTitle,
      description: itemDescription,
      deadline: itemDeadline,
      status: TaskStatus.todo(),
      milestoneId: ItemId(milestoneId),
    );

    // Save
    await _taskRepository.saveTask(task);

    return task;
  }
}
