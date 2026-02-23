import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// DateTimeプロバイダー - テスト時にモック化可能な現在時刻提供
typedef DateTimeProvider = DateTime Function();

/// GetAllTasksTodayUseCase - 本日のタスクと過期限タスクをすべて取得する
///
/// ロードマップ要件: No.10 今日のタスク 行動集中ビュー
/// 期限が本日または過期限（期限が昨日以前）のタスクを取得
abstract class GetAllTasksTodayUseCase {
  Future<List<Task>> call();
}

/// GetAllTasksTodayUseCaseImpl - GetAllTasksTodayUseCase の実装
class GetAllTasksTodayUseCaseImpl implements GetAllTasksTodayUseCase {
  final TaskRepository _taskRepository;
  final DateTimeProvider _dateTimeProvider;

  GetAllTasksTodayUseCaseImpl(
    this._taskRepository, {
    DateTimeProvider? dateTimeProvider,
  }) : _dateTimeProvider = dateTimeProvider ?? (() => DateTime.now());

  @override
  Future<List<Task>> call() async {
    final allTasks = await _taskRepository.getAllTasks();
    final now = _dateTimeProvider();
    final today = DateTime(now.year, now.month, now.day);

    final tasksToday = allTasks.where((task) {
      final taskDate = task.deadline.value;
      final normalizedTaskDate = DateTime(
        taskDate.year,
        taskDate.month,
        taskDate.day,
      );

      return normalizedTaskDate.isBefore(today) ||
          normalizedTaskDate.isAtSameMomentAs(today);
    }).toList();

    return tasksToday;
  }
}
