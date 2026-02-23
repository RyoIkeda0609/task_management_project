import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/application/use_cases/milestone/get_milestones_by_goal_id_use_case.dart';

/// マイルストーン一覧の状態を管理する Notifier
///
/// 責務: 状態管理と UseCase の呼び出しのみ
/// CRUD 操作は UseCase 経由で行い、完了後に ref.invalidate で更新。
class MilestonesNotifier extends StateNotifier<AsyncValue<List<Milestone>>> {
  final GetMilestonesByGoalIdUseCase _getMilestonesByGoalIdUseCase;

  MilestonesNotifier(this._getMilestonesByGoalIdUseCase)
    : super(const AsyncValue.loading());

  /// 指定したゴールIDに紐づくマイルストーン一覧を読み込む
  Future<void> loadMilestonesByGoalId(String goalId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getMilestonesByGoalIdUseCase(goalId));
  }
}
