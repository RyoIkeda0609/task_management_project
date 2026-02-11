class TaskDetailPageState {
  final String taskId;
  final String source;
  final bool isLoading;

  const TaskDetailPageState({
    required this.taskId,
    this.source = 'today_tasks',
    this.isLoading = false,
  });

  TaskDetailPageState copyWith({
    String? taskId,
    String? source,
    bool? isLoading,
  }) {
    return TaskDetailPageState(
      taskId: taskId ?? this.taskId,
      source: source ?? this.source,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
