import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/infrastructure/persistence/hive/hive_repository_base.dart';

/// HiveMilestoneRepository - Hive を使用した Milestone の永続化実装
///
/// HiveRepositoryBase を継承して、Milestone 固有の永続化ロジックを実装します。
/// JSON ベースで保存するため、Hive のネイティブな TypeAdapter は不要です。
class HiveMilestoneRepository extends HiveRepositoryBase<Milestone>
    implements MilestoneRepository {
  @override
  String get boxName => 'milestones';

  @override
  Milestone fromJson(Map<String, dynamic> json) => Milestone.fromJson(json);

  @override
  Map<String, dynamic> toJson(Milestone entity) => entity.toJson();

  @override
  String getId(Milestone entity) => entity.itemId.value;

  @override
  Future<List<Milestone>> getAllMilestones() async => await getAll();

  @override
  Future<Milestone?> getMilestoneById(String id) async => await getById(id);

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async {
    final all = await getAll();
    return all.where((m) => m.goalId.value == goalId).toList();
  }

  @override
  Future<void> saveMilestone(Milestone milestone) async =>
      await save(milestone);

  @override
  Future<void> deleteMilestone(String id) async => await deleteById(id);

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async =>
      await deleteWhere((m) => m.goalId.value == goalId);

  @override
  Future<int> getMilestoneCount() async => await count();
}
