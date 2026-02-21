import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';

/// ゴール一覧の状態を管理する Notifier
///
/// 責務: 状態管理と Repository の呼び出しのみ
/// CRUD 操作は UseCase 経由で行い、完了後に ref.invalidate(goalsProvider) で更新。
class GoalsNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
  final GoalRepository _repository;

  GoalsNotifier(this._repository) : super(const AsyncValue.loading());

  /// すべてのゴールを読み込む
  Future<void> loadGoals() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllGoals());
  }
}
