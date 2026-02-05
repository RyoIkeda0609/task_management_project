import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// HiveTaskRepository - Hive を使用した Task の永続化実装
///
/// ローカル キー値ストア (Hive) にタスクデータを JSON 文字列として保存・取得する
/// JSON ベースで保存するため、Hive のネイティブな TypeAdapter は不要です
class HiveTaskRepository implements TaskRepository {
  static const String _boxName = 'tasks';
  late Box<String> _box;

  /// リポジトリを初期化する
  ///
  /// [initialize] を呼び出す前に、Hive が初期化されていることを確認してください
  Future<void> initialize() async {
    // String ベースの Box を開く（JSON の文字列保存用）
    _box = await Hive.openBox<String>(_boxName);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      final taskList = <Task>[];
      for (final jsonString in _box.values) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        taskList.add(Task.fromJson(json));
      }
      return taskList;
    } catch (e) {
      throw Exception('Failed to fetch all tasks: $e');
    }
  }

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      final jsonString = _box.get(id);
      if (jsonString == null) return null;
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Task.fromJson(json);
    } catch (e) {
      throw Exception('Failed to fetch task with id $id: $e');
    }
  }

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async {
    try {
      final taskList = <Task>[];
      for (final jsonString in _box.values) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final task = Task.fromJson(json);
        if (task.milestoneId == milestoneId) {
          taskList.add(task);
        }
      }
      return taskList;
    } catch (e) {
      throw Exception('Failed to fetch tasks for milestone $milestoneId: $e');
    }
  }

  @override
  Future<void> saveTask(Task task) async {
    try {
      final jsonString = jsonEncode(task.toJson());
      await _box.put(task.id.value, jsonString);
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
      final keysToDelete = <String>[];
      for (final key in _box.keys) {
        final jsonString = _box.get(key);
        if (jsonString != null) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          if (json['milestoneId'] == milestoneId) {
            keysToDelete.add(key as String);
          }
        }
      }
      for (final key in keysToDelete) {
        await _box.delete(key);
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
