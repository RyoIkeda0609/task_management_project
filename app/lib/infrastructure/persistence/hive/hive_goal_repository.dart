import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/infrastructure/persistence/hive/hive_repository_base.dart';

/// HiveGoalRepository - Hive を使用した Goal の永続化実装
///
/// HiveRepositoryBase を継承して、Goal 固有の永続化ロジックを実装します。
/// JSON ベースで保存するため、Hive のネイティブな TypeAdapter は不要です。
class HiveGoalRepository extends HiveRepositoryBase<Goal>
    implements GoalRepository {
  @override
  String get boxName => 'goals';

  @override
  Goal fromJson(Map<String, dynamic> json) => Goal.fromJson(json);

  @override
  Map<String, dynamic> toJson(Goal entity) => entity.toJson();

  @override
  String getId(Goal entity) => entity.itemId.value;

  @override
  Future<List<Goal>> getAllGoals() async => await getAll();

  @override
  Future<Goal?> getGoalById(String id) async => await getById(id);

  @override
  Future<void> saveGoal(Goal goal) async => await save(goal);

  @override
  Future<void> deleteGoal(String id) async => await deleteById(id);

  @override
  Future<void> deleteAllGoals() async => await deleteAll();

  @override
  Future<int> getGoalCount() async => await count();
}
