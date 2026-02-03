import 'package:app/domain/entities/task.dart';
import 'package:app/infrastructure/repositories/task_repository.dart';

/// GetAllTasksTodayUseCase - 本日のタスクをすべて取得する
///
/// ロードマップ要件: No.10 今日のタスク 行動集中ビュー
/// 期限が本日のすべてのタスクを取得
abstract class GetAllTasksTodayUseCase {
  Future<List<Task>> call();
}

/// GetAllTasksTodayUseCaseImpl - GetAllTasksTodayUseCase の実装
class GetAllTasksTodayUseCaseImpl implements GetAllTasksTodayUseCase {
  final TaskRepository _taskRepository;

  GetAllTasksTodayUseCaseImpl(this._taskRepository);

  @override
  Future<List<Task>> call() async {
    // すべてのタスクを取得
    final allTasks = await _taskRepository.getAllTasks();

    // 本日の日付を取得（時刻は00:00:00に正規化）
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 本日の期限のタスクをフィルタリング
    final tasksToday = allTasks.where((task) {
      final taskDate = task.deadline.value;
      return taskDate.year == today.year &&
          taskDate.month == today.month &&
          taskDate.day == today.day;
    }).toList();

    return tasksToday;
  }
}
