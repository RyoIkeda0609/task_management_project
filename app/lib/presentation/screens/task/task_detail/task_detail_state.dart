import 'package:app/domain/entities/task.dart';

enum TaskDetailViewState { loading, notFound, data, error }

/// タスク詳細画面の UI状態
///
/// 表示用に整形された状態のみを保持
class TaskDetailPageState {
  final TaskDetailViewState viewState;
  final Task? task;
  final String? errorMessage;

  const TaskDetailPageState({
    required this.viewState,
    this.task,
    this.errorMessage,
  });

  /// ローディング状態
  factory TaskDetailPageState.loading() {
    return const TaskDetailPageState(viewState: TaskDetailViewState.loading);
  }

  /// データロード成功
  factory TaskDetailPageState.withData(Task? task) {
    if (task == null) {
      return const TaskDetailPageState(viewState: TaskDetailViewState.notFound);
    }
    return TaskDetailPageState(
      viewState: TaskDetailViewState.data,
      task: task,
    );
  }

  /// エラー
  factory TaskDetailPageState.withError(String message) {
    return TaskDetailPageState(
      viewState: TaskDetailViewState.error,
      errorMessage: message,
    );
  }

  TaskDetailPageState copyWith({
    TaskDetailViewState? viewState,
    Task? task,
    String? errorMessage,
  }) {
    return TaskDetailPageState(
      viewState: viewState ?? this.viewState,
      task: task ?? this.task,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => viewState == TaskDetailViewState.loading;
  bool get isNotFound => viewState == TaskDetailViewState.notFound;
  bool get hasData => viewState == TaskDetailViewState.data && task != null;
  bool get isError => viewState == TaskDetailViewState.error;
}
