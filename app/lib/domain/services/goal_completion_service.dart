import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// GoalCompletionService - ゴール完了判定サービス
///
/// ゴールの進捗を計算し、完了（100%）かどうかを判定する
/// Domain層に属する純粋なビジネスロジック
class GoalCompletionService {
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;

  GoalCompletionService(this._milestoneRepository, this._taskRepository);

  /// ゴールが完了（進捗100%）しているかを判定
  ///
  /// マイルストーンが存在しない場合は完了していないと判定
  /// すべてのマイルストーンの全タスクが完了した場合に 100% と判定
  Future<bool> isGoalCompleted(String goalId) async {
    // 指定ゴールのマイルストーンを取得
    final milestones = await _milestoneRepository.getMilestonesByGoalId(goalId);

    if (milestones.isEmpty) {
      // マイルストーンが存在しない場合は完了していない
      return false;
    }

    // 各マイルストーンの完了状況を確認
    int completedMilestoneCount = 0;

    for (final milestone in milestones) {
      final tasks = await _taskRepository.getTasksByMilestoneId(
        milestone.id.value,
      );

      if (tasks.isEmpty) {
        // タスクが0個のマイルストーン：完了していないと判定
        continue;
      }

      // すべてのタスクが完了しているかを確認
      final allTasksDone = tasks.every((task) => task.status.isDone);
      if (allTasksDone) {
        completedMilestoneCount++;
      }
    }

    // すべてのマイルストーンが完了 = ゴール完了（100%）
    return completedMilestoneCount == milestones.length;
  }

  /// ゴール進捗を計算（0-100）
  Future<int> calculateGoalProgress(String goalId) async {
    final isCompleted = await isGoalCompleted(goalId);
    return isCompleted ? 100 : 0;
  }
}
