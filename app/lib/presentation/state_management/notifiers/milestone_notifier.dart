import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/repositories/milestone_repository.dart';

/// マイルストーン一覧の状態を管理する Notifier
///
/// 非同期のMilestone操作（ロード、作成、削除等）を統一的に管理し、
/// UI側に AsyncValue で状態を提供します。
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
  Future<void> createMilestone({
    required String goalId,
    required MilestoneTitle title,
    required MilestoneDeadline deadline,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 新しいMilestoneインスタンスを作成
      final milestone = Milestone(
        id: MilestoneId.generate(),
        title: title,
        deadline: deadline,
        goalId: goalId,
      );
      // リポジトリに保存
      await _repository.saveMilestone(milestone);
      // 作成後、一覧を更新
      return _repository.getMilestonesByGoalId(goalId);
    });
  }

  /// マイルストーンを更新
  Future<void> updateMilestone({
    required String milestoneId,
    required String goalId,
    MilestoneTitle? newTitle,
    MilestoneDeadline? newDeadline,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final milestone = await _repository.getMilestoneById(milestoneId);
      if (milestone != null) {
        // 新しいMilestoneインスタンスを作成（変更部分のみ上書き）
        final updatedMilestone = Milestone(
          id: milestone.id,
          title: newTitle ?? milestone.title,
          deadline: newDeadline ?? milestone.deadline,
          goalId: goalId,
        );
        // リポジトリに保存
        await _repository.saveMilestone(updatedMilestone);
        // 更新後、一覧を更新
        return _repository.getMilestonesByGoalId(goalId);
      }
      throw Exception('Milestone not found');
    });
  }

  /// マイルストーンを削除（カスケード削除: 配下のタスクも削除）
  Future<void> deleteMilestone(String milestoneId, String goalId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteMilestone(milestoneId);
      // 削除後、一覧を更新
      return _repository.getMilestonesByGoalId(goalId);
    });
  }
}
