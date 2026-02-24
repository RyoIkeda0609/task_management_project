/// テスト用共有モックリポジトリ
///
/// 各テストファイルで重複していたモック実装を集約。
/// すべてのメソッドは in-memory の List に対して操作するため、
/// テスト間で状態が共有されないよう setUp で新しいインスタンスを生成すること。
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// ゴールリポジトリのインメモリモック
///
/// `saveGoal` は upsert（既存があれば置換）として動作する。
class MockGoalRepository implements GoalRepository {
  final List<Goal> goals = [];

  @override
  Future<List<Goal>> getAllGoals() async => goals;

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      return goals.firstWhere((g) => g.itemId.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    goals.removeWhere((g) => g.itemId.value == goal.itemId.value);
    goals.add(goal);
  }

  @override
  Future<void> deleteGoal(String id) async =>
      goals.removeWhere((g) => g.itemId.value == id);

  @override
  Future<void> deleteAllGoals() async => goals.clear();

  @override
  Future<int> getGoalCount() async => goals.length;
}

/// マイルストーンリポジトリのインメモリモック
///
/// `saveMilestone` は upsert として動作する。
class MockMilestoneRepository implements MilestoneRepository {
  final List<Milestone> milestones = [];

  @override
  Future<List<Milestone>> getAllMilestones() async => milestones;

  @override
  Future<Milestone?> getMilestoneById(String id) async {
    try {
      return milestones.firstWhere((m) => m.itemId.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async =>
      milestones.where((m) => m.goalId.value == goalId).toList();

  @override
  Future<void> saveMilestone(Milestone milestone) async {
    milestones.removeWhere((m) => m.itemId.value == milestone.itemId.value);
    milestones.add(milestone);
  }

  @override
  Future<void> deleteMilestone(String id) async =>
      milestones.removeWhere((m) => m.itemId.value == id);

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async =>
      milestones.removeWhere((m) => m.goalId.value == goalId);

  @override
  Future<int> getMilestoneCount() async => milestones.length;
}

/// タスクリポジトリのインメモリモック
///
/// `saveTask` は upsert として動作する。
class MockTaskRepository implements TaskRepository {
  final List<Task> tasks = [];

  @override
  Future<List<Task>> getAllTasks() async => tasks;

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return tasks.firstWhere((t) => t.itemId.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async =>
      tasks.where((t) => t.milestoneId.value == milestoneId).toList();

  @override
  Future<void> saveTask(Task task) async {
    tasks.removeWhere((t) => t.itemId.value == task.itemId.value);
    tasks.add(task);
  }

  @override
  Future<void> deleteTask(String id) async =>
      tasks.removeWhere((t) => t.itemId.value == id);

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async =>
      tasks.removeWhere((t) => t.milestoneId.value == milestoneId);

  @override
  Future<int> getTaskCount() async => tasks.length;
}
