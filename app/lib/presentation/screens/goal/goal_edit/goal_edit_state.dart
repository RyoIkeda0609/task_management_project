class GoalEditPageState {
  final String goalId; // 編集中のゴールID
  final String title;
  final String reason;
  final String category;
  final DateTime deadline;
  final bool isLoading;

  const GoalEditPageState({
    this.goalId = '',
    this.title = '',
    this.reason = '',
    this.category = 'キャリア',
    required this.deadline,
    this.isLoading = false,
  });

  GoalEditPageState copyWith({
    String? goalId,
    String? title,
    String? reason,
    String? category,
    DateTime? deadline,
    bool? isLoading,
  }) {
    return GoalEditPageState(
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      reason: reason ?? this.reason,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
