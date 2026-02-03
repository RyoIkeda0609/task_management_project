import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/value_objects/task/task_id.dart';

/// CreateTaskUseCase - 新しいタスクを作成する
///
/// ビジネスロジック：
/// - タスク ID は自動生成される
/// - 期限は本日より後の日付のみ許可
/// - ステータスは常に Todo で開始される
/// - すべての入力値は ValueObject でバリデーションされる
abstract class CreateTaskUseCase {
  Future<Task> call({
    required String title,
    required String description,
    required DateTime deadline,
  });
}

/// CreateTaskUseCaseImpl - CreateTaskUseCase の実装
class CreateTaskUseCaseImpl implements CreateTaskUseCase {
  @override
  Future<Task> call({
    required String title,
    required String description,
    required DateTime deadline,
  }) async {
    // ValueObject による入力値検証
    final taskTitle = TaskTitle(title);
    final taskDescription = TaskDescription(description);
    final taskDeadline = TaskDeadline(deadline);

    // Task エンティティの作成（ステータスは Todo で開始）
    final task = Task(
      id: TaskId.generate(),
      title: taskTitle,
      description: taskDescription,
      deadline: taskDeadline,
      status: TaskStatus.todo(),
    );

    return task;
  }
}
