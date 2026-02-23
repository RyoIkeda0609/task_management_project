import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/shared/progress.dart';

/// MilestoneCompletionService - マイルストーン完了判定サービス
///
/// マイルストーンの進捗を計算し、完了（100%）かどうかを判定する
/// Domain層に属する純粋なビジネスロジック
class MilestoneCompletionService {
  final TaskRepository _taskRepository;

  MilestoneCompletionService(this._taskRepository);

  /// マイルストーンが完了（進捗100%）しているかを判定
  ///
  /// タスクが存在しない場合は完了していないと判定
  /// すべてのタスクが完了した場合に 100% と判定
  Future<bool> isMilestoneCompleted(String milestoneId) async {
    final tasks = await _taskRepository.getTasksByMilestoneId(milestoneId);

    if (tasks.isEmpty) {
      return false;
    }

    final allTasksDone = tasks.every((task) => task.status.isDone);
    return allTasksDone;
  }

  /// マイルストーン進捗を計算（0-100）
  Future<Progress> calculateMilestoneProgress(String milestoneId) async {
    final tasks = await _taskRepository.getTasksByMilestoneId(milestoneId);

    if (tasks.isEmpty) {
      return Progress(0);
    }

    final totalProgress = tasks.fold<int>(
      0,
      (sum, task) => sum + task.getProgress().value,
    );
    final average = totalProgress ~/ tasks.length;
    return Progress(average);
  }
}
