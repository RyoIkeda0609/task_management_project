import 'package:app/domain/entities/task.dart';

/// TaskRepository - タスク のデータ永続化インターフェース
///
/// Hive により実装される
abstract class TaskRepository {
  /// すべてのタスクを取得する
  Future<List<Task>> getAllTasks();

  /// ID からタスクを取得する
  Future<Task?> getTaskById(String id);

  /// マイルストーン ID に属するタスクをすべて取得する
  Future<List<Task>> getTasksByMilestoneId(String milestoneId);

  /// タスクを保存する（新規作成または更新）
  Future<void> saveTask(Task task);

  /// タスクを削除する
  Future<void> deleteTask(String id);

  /// マイルストーン ID に属するタスクをすべて削除する
  Future<void> deleteTasksByMilestoneId(String milestoneId);

  /// タスクの総数を取得する
  Future<int> getTaskCount();
}
