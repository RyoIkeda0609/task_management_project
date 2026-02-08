import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/repositories/goal_repository.dart';

/// ゴール一覧の状態を管理する Notifier
///
/// 責務: 状態管理と Repository の呼び出しのみ
/// UI側で判断（キャッシュ無効化など）を行うことで責務を分離
class GoalsNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
  final GoalRepository _repository;

  GoalsNotifier(this._repository) : super(const AsyncValue.loading());

  /// すべてのゴールを読み込む
  Future<void> loadGoals() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllGoals());
  }

  /// IDからゴールを取得
  Future<Goal?> getGoalById(String goalId) async {
    return await _repository.getGoalById(goalId);
  }

  /// 新しいゴールを作成
  ///
  /// 注意: UI側で ref.invalidate(goalsProvider) を呼び出して一覧を更新してください
  Future<void> createGoal({
    required GoalTitle title,
    required GoalCategory category,
    required GoalReason reason,
    required GoalDeadline deadline,
  }) async {
    // Notifier は単に保存処理を実行するのみ
    // UI側での状態更新は Repository ← UseCase ← UI の流れで自動化
    final goal = Goal(
      id: GoalId.generate(),
      title: title,
      category: category,
      reason: reason,
      deadline: deadline,
    );
    await _repository.saveGoal(goal);
  }

  /// ゴールを更新
  ///
  /// 注意: UI側で ref.invalidate(goalsProvider) を呼び出して一覧を更新してください
  Future<void> updateGoal({
    required String goalId,
    GoalTitle? newTitle,
    GoalDeadline? newDeadline,
  }) async {
    final goal = await _repository.getGoalById(goalId);
    if (goal != null) {
      final updatedGoal = Goal(
        id: goal.id,
        title: newTitle ?? goal.title,
        category: goal.category,
        reason: goal.reason,
        deadline: newDeadline ?? goal.deadline,
      );
      await _repository.saveGoal(updatedGoal);
    } else {
      throw Exception('Goal not found');
    }
  }

  /// ゴールを削除（カスケード削除: 配下のMS・タスクも削除）
  ///
  /// 注意: UI側で ref.invalidate(goalsProvider) を呼び出して一覧を更新してください
  Future<void> deleteGoal(String goalId) async {
    await _repository.deleteGoal(goalId);
  }
}
