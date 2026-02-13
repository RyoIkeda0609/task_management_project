import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/repositories/milestone_repository.dart';

/// マイルストーン一覧の状態を管理する Notifier
///
/// 責務: 状態管理と Repository の呼び出しのみ
/// UI側で判断（キャッシュ無効化など）を行うことで責務を分離
class MilestonesNotifier extends StateNotifier<AsyncValue<List<Milestone>>> {
  final MilestoneRepository _repository;

  MilestonesNotifier(this._repository) : super(const AsyncValue.loading());

  /// 指定したゴールIDに紐づくマイルストーン一覧を読み込む
  Future<void> loadMilestonesByGoalId(String goalId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.getMilestonesByGoalId(goalId),
    );
  }

  /// IDからマイルストーンを取得
  Future<Milestone?> getMilestoneById(String milestoneId) async {
    return await _repository.getMilestoneById(milestoneId);
  }

  /// 新しいマイルストーンを作成
  ///
  /// 注意: UI側で ref.invalidate(milestonesByGoalProvider) を呼び出して一覧を更新してください
  Future<void> createMilestone({
    required String goalId,
    required MilestoneTitle title,
    required MilestoneDeadline deadline,
  }) async {
    // Notifier は単に保存処理を実行するのみ
    final milestone = Milestone(
      id: MilestoneId.generate(),
      title: title,
      deadline: deadline,
      goalId: goalId,
    );
    await _repository.saveMilestone(milestone);
  }

  /// マイルストーンを更新
  ///
  /// 注意: UI側で ref.invalidate(milestonesByGoalProvider) を呼び出して一覧を更新してください
  Future<void> updateMilestone({
    required String milestoneId,
    required String goalId,
    MilestoneTitle? newTitle,
    MilestoneDeadline? newDeadline,
  }) async {
    final milestone = await _repository.getMilestoneById(milestoneId);
    if (milestone != null) {
      // 新しいMilestoneインスタンスを作成（変更部分のみ上書き）
      final updatedMilestone = Milestone(
        id: milestone.id,
        title: newTitle ?? milestone.title,
        deadline: newDeadline ?? milestone.deadline,
        goalId: goalId,
      );
      await _repository.saveMilestone(updatedMilestone);
    } else {
      throw Exception('Milestone not found');
    }
  }

  /// マイルストーンを削除（カスケード削除: 配下のタスクも削除）
  ///
  /// 注意: UI側で ref.invalidate(milestonesByGoalProvider) を呼び出して一覧を更新してください
  Future<void> deleteMilestone(String milestoneId, String goalId) async {
    await _repository.deleteMilestone(milestoneId);
  }
}
