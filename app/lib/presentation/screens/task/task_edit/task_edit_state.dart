class TaskEditPageState {
  final String taskId; // 編集中のタスクID
  final String title;
  final String description;
  final DateTime selectedDeadline;
  final bool isLoading;

  const TaskEditPageState({
    this.taskId = '',
    this.title = '',
    this.description = '',
    required this.selectedDeadline,
    this.isLoading = false,
  });

  TaskEditPageState copyWith({
    String? taskId,
    String? title,
    String? description,
    DateTime? selectedDeadline,
    bool? isLoading,
  }) {
    return TaskEditPageState(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      selectedDeadline: selectedDeadline ?? this.selectedDeadline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
