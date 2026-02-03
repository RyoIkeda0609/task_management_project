import 'package:hive/hive.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// HiveTaskRepository - Hive を使用した Task の永続化実装
///
/// ローカル キー値ストア (Hive) にタスクデータを保存・取得する
class HiveTaskRepository implements TaskRepository {
  static const String _boxName = 'tasks';
  late Box<Task> _box;

  /// Hive の初期化が完了しているか確認
  bool get isInitialized => Hive.isAdapterRegistered(2);

  /// リポジトリを初期化する
  ///
  /// [initialize] を呼び出す前に、Hive が初期化されていることを確認してください
  Future<void> initialize() async {
    _box = await Hive.openBox<Task>(_boxName);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      return _box.values.toList();
    } catch (e) {
      throw Exception('Failed to fetch all tasks: $e');
    }
  }

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      final task = _box.get(id);
      return task;
    } catch (e) {
      throw Exception('Failed to fetch task with id $id: $e');
    }
  }

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async {
    try {
      final tasks = _box.values
          .where((task) => task.milestoneId == milestoneId)
          .toList();
      return tasks;
    } catch (e) {
      throw Exception('Failed to fetch tasks for milestone $milestoneId: $e');
    }
  }

  @override
  Future<void> saveTask(Task task) async {
    try {
      // key に task.id.value を使用
      await _box.put(task.id.value, task);
    } catch (e) {
      throw Exception('Failed to save task: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete task with id $id: $e');
    }
  }

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async {
    try {
      // milestoneId に属するタスクをすべて削除
      final tasks = _box.values
          .where((task) => task.milestoneId == milestoneId)
          .toList();
      for (final task in tasks) {
        await _box.delete(task.id.value);
      }
    } catch (e) {
      throw Exception('Failed to delete tasks for milestone $milestoneId: $e');
    }
  }

  @override
  Future<int> getTaskCount() async {
    try {
      return _box.length;
    } catch (e) {
      throw Exception('Failed to get task count: $e');
    }
  }

  /// Box を明示的に閉じる（アプリ終了時など）
  Future<void> close() async {
    await _box.close();
  }
}
