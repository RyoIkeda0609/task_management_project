/// テスト用共有モックドメインサービス
///
/// 完了判定・進捗計算サービスのモック実装を集約。
import 'package:app/domain/services/goal_completion_service.dart';
import 'package:app/domain/services/milestone_completion_service.dart';
import 'package:app/domain/services/task_completion_service.dart';
import 'package:app/domain/value_objects/shared/progress.dart';
import 'mock_repositories.dart';

/// ゴール完了判定サービスのモック
///
/// MockMilestoneRepository / MockTaskRepository に依存し、
/// 全マイルストーンの全タスクが完了していれば isGoalCompleted = true を返す。
class MockGoalCompletionService implements GoalCompletionService {
  final MockMilestoneRepository milestoneRepository;
  final MockTaskRepository taskRepository;

  MockGoalCompletionService(this.milestoneRepository, this.taskRepository);

  @override
  Future<bool> isGoalCompleted(String goalId) async {
    final milestones = await milestoneRepository.getMilestonesByGoalId(goalId);
    if (milestones.isEmpty) return false;
    int completedCount = 0;
    for (final milestone in milestones) {
      final tasks = await taskRepository.getTasksByMilestoneId(
        milestone.itemId.value,
      );
      if (tasks.isNotEmpty) {
        final allTasksDone = tasks.every((task) => task.status.isDone);
        if (allTasksDone) completedCount++;
      }
    }
    return completedCount == milestones.length;
  }

  @override
  Future<Progress> calculateGoalProgress(String goalId) async {
    final milestones = await milestoneRepository.getMilestonesByGoalId(goalId);
    if (milestones.isEmpty) return Progress(0);
    int totalProgress = 0;
    for (final milestone in milestones) {
      final tasks = await taskRepository.getTasksByMilestoneId(
        milestone.itemId.value,
      );
      if (tasks.isEmpty) continue;
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

/// マイルストーン完了判定サービスのモック
///
/// MockTaskRepository に依存し、全タスク完了で isMilestoneCompleted = true を返す。
class MockMilestoneCompletionService implements MilestoneCompletionService {
  final MockTaskRepository taskRepository;

  MockMilestoneCompletionService(this.taskRepository);

  @override
  Future<bool> isMilestoneCompleted(String milestoneId) async {
    final tasks = await taskRepository.getTasksByMilestoneId(milestoneId);
    if (tasks.isEmpty) return false;
    return tasks.every((task) => task.status.isDone);
  }

  @override
  Future<Progress> calculateMilestoneProgress(String milestoneId) async {
    final tasks = await taskRepository.getTasksByMilestoneId(milestoneId);
    if (tasks.isEmpty) return Progress(0);
    final totalProgress = tasks.fold<int>(
      0,
      (sum, task) => sum + task.getProgress().value,
    );
    return Progress(totalProgress ~/ tasks.length);
  }
}

/// タスク完了判定サービスのスタブ
///
/// 常に false を返す最小限のスタブ実装。
class MockTaskCompletionService implements TaskCompletionService {
  @override
  Future<bool> isTaskCompleted(String taskId) async => false;
}
