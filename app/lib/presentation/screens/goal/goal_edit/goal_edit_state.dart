class GoalEditPageState {
  final String goalId; // 編集中のゴールID
  final String title;
  final String description;
  final String category;
  final DateTime deadline;
  final bool isLoading;

  const GoalEditPageState({
    this.goalId = '',
    this.title = '',
    this.description = '',
    this.category = 'キャリア',
    required this.deadline,
    this.isLoading = false,
  });

  GoalEditPageState copyWith({
    String? goalId,
    String? title,
    String? description,
    String? category,
    DateTime? deadline,
    bool? isLoading,
  }) {
    return GoalEditPageState(
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
