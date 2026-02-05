import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';

/// HiveGoalRepository - Hive を使用した Goal の永続化実装
///
/// ローカル SQLite-like キー値ストア (Hive) にゴールデータを JSON 文字列として保存・取得する
/// JSON ベースで保存するため、Hive のネイティブな TypeAdapter は不要です
class HiveGoalRepository implements GoalRepository {
  static const String _boxName = 'goals';
  late Box<String> _box;

  /// リポジトリを初期化する
  ///
  /// [initialize] を呼び出す前に、Hive が初期化されていることを確認してください
  /// 通常、アプリケーション起動時に main.dart で呼び出されます
  Future<void> initialize() async {
    // String ベースの Box を開く（JSON の文字列保存用）
    _box = await Hive.openBox<String>(_boxName);
  }

  @override
  Future<List<Goal>> getAllGoals() async {
    try {
      final goalList = <Goal>[];
      for (final jsonString in _box.values) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        goalList.add(Goal.fromJson(json));
      }
      return goalList;
    } catch (e) {
      throw Exception('Failed to fetch all goals: $e');
    }
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      final jsonString = _box.get(id);
      if (jsonString == null) return null;
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Goal.fromJson(json);
    } catch (e) {
      throw Exception('Failed to fetch goal with id $id: $e');
    }
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    try {
      final jsonString = jsonEncode(goal.toJson());
      await _box.put(goal.id.value, jsonString);
    } catch (e) {
      throw Exception('Failed to save goal: $e');
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete goal with id $id: $e');
    }
  }

  @override
  Future<void> deleteAllGoals() async {
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Failed to delete all goals: $e');
    }
  }

  @override
  Future<int> getGoalCount() async {
    try {
      return _box.length;
    } catch (e) {
      throw Exception('Failed to get goal count: $e');
    }
  }

  /// Box を明示的に閉じる（アプリ終了時など）
  Future<void> close() async {
    await _box.close();
  }
}
