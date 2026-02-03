import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/shared/progress.dart';
import 'package:app/infrastructure/repositories/goal_repository.dart';
import 'package:app/infrastructure/repositories/milestone_repository.dart';
import 'package:app/infrastructure/repositories/task_repository.dart';

/// CalculateProgressUseCase - 進捗を計算する
///
/// ロードマップ要件: No.4 進捗自動計算 タスク→MS→ゴール
/// タスクのステータスから自動計算される
abstract class CalculateProgressUseCase {
  /// ゴールの進捗を計算
  Future<Progress> calculateGoalProgress(String goalId);

  /// マイルストーンの進捗を計算
  Future<Progress> calculateMilestoneProgress(String milestoneId);
}

/// CalculateProgressUseCaseImpl - CalculateProgressUseCase の実装
class CalculateProgressUseCaseImpl implements CalculateProgressUseCase {
  final GoalRepository _goalRepository;
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;

  CalculateProgressUseCaseImpl(
    this._goalRepository,
    this._milestoneRepository,
    this._taskRepository,
  );

  @override
  Future<Progress> calculateGoalProgress(String goalId) async {
    if (goalId.isEmpty) {
      throw ArgumentError('goalId must not be empty');
    }

    // ゴールが存在することを確認
    final goal = await _goalRepository.getGoalById(goalId);
    if (goal == null) {
      throw ArgumentError('Goal with id $goalId not found');
    }

    // ゴール配下のすべてのマイルストーンを取得
    final milestones = await _milestoneRepository.getMilestonesByGoalId(goalId);

    if (milestones.isEmpty) {
      // マイルストーンがない場合は0%
      return Progress(0);
    }

    // 各マイルストーンの進捗を計算
    final milestoneProgresses = <Progress>[];
    for (final milestone in milestones) {
      final progress = await calculateMilestoneProgress(milestone.id.value);
      milestoneProgresses.add(progress);
    }

    // ゴールの進捗は、マイルストーン進捗の平均
    return goal.calculateProgress(milestoneProgresses);
  }

  @override
  Future<Progress> calculateMilestoneProgress(String milestoneId) async {
    if (milestoneId.isEmpty) {
      throw ArgumentError('milestoneId must not be empty');
    }

    // マイルストーンが存在することを確認
    final milestone = await _milestoneRepository.getMilestoneById(milestoneId);
    if (milestone == null) {
      throw ArgumentError('Milestone with id $milestoneId not found');
    }

    // マイルストーン配下のすべてのタスクを取得
    final tasks = await _taskRepository.getTasksByMilestoneId(milestoneId);

    if (tasks.isEmpty) {
      // タスクがない場合は0%
      return Progress(0);
    }

    // 各タスクの進捗を取得
    final taskProgresses = tasks.map((task) => task.getProgress()).toList();

    // マイルストーンの進捗は、タスク進捗の平均
    return milestone.calculateProgress(taskProgresses);
  }
}
