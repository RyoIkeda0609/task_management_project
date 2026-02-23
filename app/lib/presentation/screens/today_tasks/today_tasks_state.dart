import 'package:app/application/use_cases/task/get_tasks_grouped_by_status_use_case.dart';

enum TodayTasksViewState { loading, empty, data, error }

/// 今日のタスク画面の UI状態
///
/// 表示用に整形された状態のみを保持（Domain モデルをそのまま持ち込まない）
class TodayTasksPageState {
  final TodayTasksViewState viewState;
  final GroupedTasks? groupedTasks;
  final String errorMessage;

  const TodayTasksPageState({
    required this.viewState,
    this.groupedTasks,
    this.errorMessage = '',
  });

  /// ローディング状態
  factory TodayTasksPageState.loading() {
    return const TodayTasksPageState(viewState: TodayTasksViewState.loading);
  }

  /// データ載入完了
  factory TodayTasksPageState.withData(GroupedTasks grouped) {
    return TodayTasksPageState(
      viewState: grouped.total == 0
          ? TodayTasksViewState.empty
          : TodayTasksViewState.data,
      groupedTasks: grouped,
    );
  }

  /// エラー
  factory TodayTasksPageState.withError(String message) {
    return TodayTasksPageState(
      viewState: TodayTasksViewState.error,
      errorMessage: message,
    );
  }

  TodayTasksPageState copyWith({
    TodayTasksViewState? viewState,
    GroupedTasks? groupedTasks,
    String? errorMessage,
  }) {
    return TodayTasksPageState(
      viewState: viewState ?? this.viewState,
      groupedTasks: groupedTasks ?? this.groupedTasks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isEmpty =>
      viewState == TodayTasksViewState.empty || groupedTasks?.total == 0;

  bool get isLoading => viewState == TodayTasksViewState.loading;

  bool get isError => viewState == TodayTasksViewState.error;

  bool get hasData =>
      viewState == TodayTasksViewState.data &&
      groupedTasks != null &&
      (groupedTasks?.total ?? 0) > 0;

  /// 未完了セクションを表示するか
  bool get showTodoSection => groupedTasks?.todoTasks.isNotEmpty ?? false;

  /// 進行中セクションを表示するか
  bool get showDoingSection => groupedTasks?.doingTasks.isNotEmpty ?? false;

  /// 完了セクションを表示するか
  bool get showDoneSection => groupedTasks?.doneTasks.isNotEmpty ?? false;
}
