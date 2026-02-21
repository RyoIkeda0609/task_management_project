import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// タスク一覧の状態を管理する Notifier
///
/// 責務: 状態管理と Repository の呼び出しのみ
/// CRUD 操作は UseCase 経由で行い、完了後に ref.invalidate で更新。
class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;

  TasksNotifier(this._repository) : super(const AsyncValue.loading());

  /// 指定したマイルストーンIDに紐づくタスク一覧を読み込む
  Future<void> loadTasksByMilestoneId(String milestoneId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.getTasksByMilestoneId(milestoneId),
    );
  }

  /// すべてのタスクを読み込む
  Future<void> loadAllTasks() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllTasks());
  }
}
