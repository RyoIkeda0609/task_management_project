import 'package:app/domain/repositories/task_repository.dart';

/// TaskCompletionService - タスク完了判定サービス
///
/// タスクの完了状況を判定する
/// Domain層に属する純粋なビジネスロジック
class TaskCompletionService {
  final TaskRepository _taskRepository;

  TaskCompletionService(this._taskRepository);

  /// タスクが完了（Done）しているかを判定
  Future<bool> isTaskCompleted(String taskId) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw Exception('Task not found');
    }
    return task.status.isDone;
  }
}
