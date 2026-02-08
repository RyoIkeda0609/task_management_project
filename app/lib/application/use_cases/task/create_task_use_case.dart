import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// CreateTaskUseCase - 新しいタスクを作成する
///
/// ビジネスロジック：
/// - タスク ID は自動生成される
/// - ステータスは常に Todo で開始される
/// - すべての入力値は ValueObject でバリデーションされる
/// - 親マイルストーン ID が必須
/// - Domain を作成してから Repository に保存する
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
    // ValueObject による入力値検証
    final taskTitle = TaskTitle(title);
    final taskDescription = TaskDescription(description);
    final taskDeadline = TaskDeadline(deadline);

    // milestoneId の検証（空文字列でないかチェック）
    if (milestoneId.isEmpty) {
      throw ArgumentError('milestoneId cannot be empty');
    }

    // Task エンティティの作成（ステータスは Todo で開始）
    final task = Task(
      id: TaskId.generate(),
      title: taskTitle,
      description: taskDescription,
      deadline: taskDeadline,
      status: TaskStatus.todo(),
      milestoneId: milestoneId,
    );

    // Repository に保存
    await _taskRepository.saveTask(task);

    return task;
  }
}
