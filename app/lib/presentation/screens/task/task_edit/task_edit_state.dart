class TaskEditPageState {
  final String title;
  final String description;
  final DateTime selectedDeadline;
  final bool isLoading;

  const TaskEditPageState({
    this.title = '',
    this.description = '',
    required this.selectedDeadline,
    this.isLoading = false,
  });

  TaskEditPageState copyWith({
    String? title,
    String? description,
    DateTime? selectedDeadline,
    bool? isLoading,
  }) {
    return TaskEditPageState(
      title: title ?? this.title,
      description: description ?? this.description,
      selectedDeadline: selectedDeadline ?? this.selectedDeadline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
