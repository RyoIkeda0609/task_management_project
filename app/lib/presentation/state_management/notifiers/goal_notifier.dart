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
/// 非同期のGoal操作（ロード、作成、削除等）を統一的に管理し、
/// UI側に AsyncValue で状態を提供します。
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
  Future<void> createGoal({
    required GoalTitle title,
    required GoalCategory category,
    required GoalReason reason,
    required GoalDeadline deadline,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 新しいGoalインスタンスを作成
      final goal = Goal(
        id: GoalId.generate(),
        title: title,
        category: category,
        reason: reason,
        deadline: deadline,
      );
      // リポジトリに保存
      await _repository.saveGoal(goal);
      // 作成後、一覧を更新
      return _repository.getAllGoals();
    });
  }

  /// ゴールを更新
  Future<void> updateGoal({
    required String goalId,
    GoalTitle? newTitle,
    GoalDeadline? newDeadline,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final goal = await _repository.getGoalById(goalId);
      if (goal != null) {
        // 新しいGoalインスタンスを作成（変更部分のみ上書き）
        final updatedGoal = Goal(
          id: goal.id,
          title: newTitle ?? goal.title,
          category: goal.category,
          reason: goal.reason,
          deadline: newDeadline ?? goal.deadline,
        );
        // リポジトリに保存
        await _repository.saveGoal(updatedGoal);
        // 更新後、一覧を更新
        return _repository.getAllGoals();
      }
      throw Exception('Goal not found');
    });
  }

  /// ゴールを削除（カスケード削除: 配下のMS・タスクも削除）
  Future<void> deleteGoal(String goalId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteGoal(goalId);
      // 削除後、一覧を更新
      return _repository.getAllGoals();
    });
  }
}
