import 'package:app/domain/entities/milestone.dart';

/// MilestoneRepository - マイルストーン のデータ永続化インターフェース
///
/// Hive により実装される
abstract class MilestoneRepository {
  /// すべてのマイルストーンを取得する
  Future<List<Milestone>> getAllMilestones();

  /// ID からマイルストーンを取得する
  Future<Milestone?> getMilestoneById(String id);

  /// ゴール ID に属するマイルストーンをすべて取得する
  Future<List<Milestone>> getMilestonesByGoalId(String goalId);

  /// マイルストーンを保存する（新規作成または更新）
  Future<void> saveMilestone(Milestone milestone);

  /// マイルストーンを削除する
  Future<void> deleteMilestone(String id);

  /// ゴール ID に属するマイルストーンをすべて削除する
  Future<void> deleteMilestonesByGoalId(String goalId);

  /// マイルストーンの総数を取得する
  Future<int> getMilestoneCount();
}
