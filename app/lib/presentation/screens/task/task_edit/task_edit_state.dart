class TaskEditPageState {
  final String taskId; // 編集中のタスクID
  final String title;
  final String description;
  final DateTime deadline;
  final bool isLoading;

  const TaskEditPageState({
    this.taskId = '',
    this.title = '',
    this.description = '',
    required this.deadline,
    this.isLoading = false,
  });

  /// タスク情報が初期化されているか
  bool get isInitialized => taskId.isNotEmpty;

  TaskEditPageState copyWith({
    String? taskId,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isLoading,
  }) {
    return TaskEditPageState(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
