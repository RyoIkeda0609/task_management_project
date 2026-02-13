class TaskCreatePageState {
  final String milestoneId;
  final String goalId;
  final String title;
  final String description;
  final DateTime deadline;
  final bool isLoading;

  const TaskCreatePageState({
    this.milestoneId = '',
    this.goalId = '',
    this.title = '',
    this.description = '',
    required this.deadline,
    this.isLoading = false,
  });

  TaskCreatePageState copyWith({
    String? milestoneId,
    String? goalId,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isLoading,
  }) {
    return TaskCreatePageState(
      milestoneId: milestoneId ?? this.milestoneId,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
