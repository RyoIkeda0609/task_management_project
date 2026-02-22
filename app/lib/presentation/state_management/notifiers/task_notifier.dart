import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/application/use_cases/task/get_tasks_by_milestone_id_use_case.dart';
import 'package:app/application/use_cases/task/get_all_tasks_today_use_case.dart';

/// タスク一覧の状態を管理する Notifier
///
/// 責務: 状態管理と UseCase の呼び出しのみ
/// CRUD 操作は UseCase 経由で行い、完了後に ref.invalidate で更新。
class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final GetTasksByMilestoneIdUseCase? _getTasksByMilestoneIdUseCase;
  final GetAllTasksTodayUseCase? _getAllTasksTodayUseCase;

  TasksNotifier.forMilestone(GetTasksByMilestoneIdUseCase useCase)
    : _getTasksByMilestoneIdUseCase = useCase,
      _getAllTasksTodayUseCase = null,
      super(const AsyncValue.loading());

  TasksNotifier.forAll(GetAllTasksTodayUseCase useCase)
    : _getTasksByMilestoneIdUseCase = null,
      _getAllTasksTodayUseCase = useCase,
      super(const AsyncValue.loading());

  /// 指定したマイルストーンIDに紐づくタスク一覧を読み込む
  Future<void> loadTasksByMilestoneId(String milestoneId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _getTasksByMilestoneIdUseCase!(milestoneId),
    );
  }

  /// すべてのタスクを読み込む
  Future<void> loadAllTasks() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getAllTasksTodayUseCase!());
  }
}
