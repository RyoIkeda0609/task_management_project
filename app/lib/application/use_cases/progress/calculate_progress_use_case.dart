import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/shared/progress.dart';

/// CalculateProgressUseCase - 進捗を計算する
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
      throw ArgumentError('ゴールIDが正しくありません');
    }

    // Load
    final goal = await _goalRepository.getGoalById(goalId);
    if (goal == null) {
      throw ArgumentError('対象のゴールが見つかりません');
    }

    // Execute
    final milestones = await _milestoneRepository.getMilestonesByGoalId(goalId);

    if (milestones.isEmpty) {
      return Progress(0);
    }

    final milestoneProgresses = <Progress>[];
    for (final milestone in milestones) {
      final progress = await calculateMilestoneProgress(milestone.id.value);
      milestoneProgresses.add(progress);
    }

    return goal.calculateProgress(milestoneProgresses);
  }

  @override
  Future<Progress> calculateMilestoneProgress(String milestoneId) async {
    if (milestoneId.isEmpty) {
      throw ArgumentError('マイルストーンIDが正しくありません');
    }

    // Load
    final milestone = await _milestoneRepository.getMilestoneById(milestoneId);
    if (milestone == null) {
      throw ArgumentError('対象のマイルストーンが見つかりません');
    }

    // Execute
    final tasks = await _taskRepository.getTasksByMilestoneId(milestoneId);

    if (tasks.isEmpty) {
      return Progress(0);
    }

    final taskProgresses = tasks.map((task) => task.getProgress()).toList();

    return milestone.calculateProgress(taskProgresses);
  }
}
