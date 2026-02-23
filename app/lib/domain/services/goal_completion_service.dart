import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/shared/progress.dart';

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
    final milestones = await _milestoneRepository.getMilestonesByGoalId(goalId);

    if (milestones.isEmpty) {
      return false;
    }

    int completedMilestoneCount = 0;

    for (final milestone in milestones) {
      final tasks = await _taskRepository.getTasksByMilestoneId(
        milestone.itemId.value,
      );

      if (tasks.isEmpty) {
        continue;
      }

      final allTasksDone = tasks.every((task) => task.status.isDone);
      if (allTasksDone) {
        completedMilestoneCount++;
      }
    }

    return completedMilestoneCount == milestones.length;
  }

  /// ゴール進捗を計算（0-100）
  Future<Progress> calculateGoalProgress(String goalId) async {
    final milestones = await _milestoneRepository.getMilestonesByGoalId(goalId);

    if (milestones.isEmpty) {
      return Progress(0);
    }

    int totalProgress = 0;
    for (final milestone in milestones) {
      final tasks = await _taskRepository.getTasksByMilestoneId(
        milestone.itemId.value,
      );

      if (tasks.isEmpty) {
        continue;
      }

      final taskProgresses = tasks
          .map((task) => task.getProgress().value)
          .toList();
      final avg =
          taskProgresses.fold<int>(0, (sum, p) => sum + p) ~/ tasks.length;
      totalProgress += avg;
    }

    final goalProgress = totalProgress ~/ milestones.length;
    return Progress(goalProgress);
  }
}
