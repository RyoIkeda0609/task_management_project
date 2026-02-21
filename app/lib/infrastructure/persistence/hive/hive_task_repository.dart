import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/infrastructure/persistence/hive/hive_repository_base.dart';

/// HiveTaskRepository - Hive を使用した Task の永続化実装
///
/// HiveRepositoryBase を継承して、Task 固有の永続化ロジックを実装します。
/// JSON ベースで保存するため、Hive のネイティブな TypeAdapter は不要です。
class HiveTaskRepository extends HiveRepositoryBase<Task>
    implements TaskRepository {
  @override
  String get boxName => 'tasks';

  @override
  Task fromJson(Map<String, dynamic> json) => Task.fromJson(json);

  @override
  Map<String, dynamic> toJson(Task entity) => entity.toJson();

  @override
  String getId(Task entity) => entity.itemId.value;

  @override
  Future<List<Task>> getAllTasks() async => await getAll();

  @override
  Future<Task?> getTaskById(String id) async => await getById(id);

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async {
    final all = await getAll();
    return all.where((t) => t.milestoneId.value == milestoneId).toList();
  }

  @override
  Future<void> saveTask(Task task) async => await save(task);

  @override
  Future<void> deleteTask(String id) async => await deleteById(id);

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async =>
      await deleteWhere((t) => t.milestoneId.value == milestoneId);

  @override
  Future<int> getTaskCount() async => await count();
}
