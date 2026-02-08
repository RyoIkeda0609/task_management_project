import 'package:app/domain/entities/task.dart';

/// GetTasksGroupedByStatusUseCase - タスクをステータス別にグループ化する
///
/// 責務: タスク一覧をステータス（Todo, Doing, Done）別にグループ化して返す
/// これにより、Presentation層での複雑なフィルタリングロジックを排除する
abstract class GetTasksGroupedByStatusUseCase {
  Future<GroupedTasks> call(List<Task> tasks);
}

/// タスクをステータス別にグループ化した結果
class GroupedTasks {
  final List<Task> todoTasks;
  final List<Task> doingTasks;
  final List<Task> doneTasks;

  GroupedTasks({
    required this.todoTasks,
    required this.doingTasks,
    required this.doneTasks,
  });

  /// 総タスク数
  int get total => todoTasks.length + doingTasks.length + doneTasks.length;

  /// 完了タスク数
  int get completedCount => doneTasks.length;

  /// 完了率（0～100）
  int get completionPercentage =>
      total > 0 ? ((completedCount / total) * 100).toInt() : 0;

  /// すべてのタスクを1つのリストで返す
  List<Task> get allTasks => [...todoTasks, ...doingTasks, ...doneTasks];
}

/// GetTasksGroupedByStatusUseCaseImpl - GetTasksGroupedByStatusUseCase の実装
class GetTasksGroupedByStatusUseCaseImpl
    implements GetTasksGroupedByStatusUseCase {
  @override
  Future<GroupedTasks> call(List<Task> tasks) async {
    final todoTasks = tasks.where((t) => t.status.isTodo).toList();
    final doingTasks = tasks.where((t) => t.status.isDoing).toList();
    final doneTasks = tasks.where((t) => t.status.isDone).toList();

    return GroupedTasks(
      todoTasks: todoTasks,
      doingTasks: doingTasks,
      doneTasks: doneTasks,
    );
  }
}
