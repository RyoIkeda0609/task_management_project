import 'package:hive/hive.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';

/// HiveGoalRepository - Hive を使用した Goal の永続化実装
///
/// ローカル SQLite-like キー値ストア (Hive) にゴールデータを保存・取得する
class HiveGoalRepository implements GoalRepository {
  static const String _boxName = 'goals';
  late Box<Goal> _box;

  /// Hive の初期化が完了しているか確認
  bool get isInitialized => Hive.isAdapterRegistered(0);

  /// リポジトリを初期化する
  ///
  /// [initialize] を呼び出す前に、Hive が初期化されていることを確認してください
  /// 通常、アプリケーション起動時に main.dart で呼び出されます
  Future<void> initialize() async {
    _box = await Hive.openBox<Goal>(_boxName);
  }

  @override
  Future<List<Goal>> getAllGoals() async {
    try {
      return _box.values.toList();
    } catch (e) {
      throw Exception('Failed to fetch all goals: $e');
    }
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      // Hive では key:value で保存されているため、直接キーでアクセス
      final goal = _box.get(id);
      return goal;
    } catch (e) {
      throw Exception('Failed to fetch goal with id $id: $e');
    }
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    try {
      // key に goal.id.value を使用
      await _box.put(goal.id.value, goal);
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
