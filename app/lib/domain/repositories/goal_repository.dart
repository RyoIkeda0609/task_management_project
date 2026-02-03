import 'package:app/domain/entities/goal.dart';

/// GoalRepository - ゴール のデータ永続化インターフェース
///
/// 実装は Infrastructure 層で提供される
abstract class GoalRepository {
  /// すべてのゴールを取得する
  Future<List<Goal>> getAllGoals();

  /// ID からゴールを取得する
  Future<Goal?> getGoalById(String id);

  /// ゴールを保存する（新規作成または更新）
  Future<void> saveGoal(Goal goal);

  /// ゴールを削除する
  Future<void> deleteGoal(String id);

  /// すべてのゴールを削除する
  Future<void> deleteAllGoals();

  /// ゴールの総数を取得する
  Future<int> getGoalCount();
}
