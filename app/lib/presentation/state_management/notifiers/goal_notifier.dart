import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/application/use_cases/goal/get_all_goals_use_case.dart';

/// ゴール一覧の状態を管理する Notifier
///
/// 責務: 状態管理と UseCase の呼び出しのみ
/// CRUD 操作は UseCase 経由で行い、完了後に ref.invalidate(goalsProvider) で更新。
class GoalsNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
  final GetAllGoalsUseCase _getAllGoalsUseCase;

  GoalsNotifier(this._getAllGoalsUseCase) : super(const AsyncValue.loading());

  /// すべてのゴールを読み込む
  Future<void> loadGoals() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getAllGoalsUseCase());
  }
}
