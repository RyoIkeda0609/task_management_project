class GoalEditPageState {
  final String title;
  final String reason;
  final String category;
  final DateTime deadline;
  final bool isLoading;

  const GoalEditPageState({
    this.title = '',
    this.reason = '',
    this.category = 'キャリア',
    required this.deadline,
    this.isLoading = false,
  });

  GoalEditPageState copyWith({
    String? title,
    String? reason,
    String? category,
    DateTime? deadline,
    bool? isLoading,
  }) {
    return GoalEditPageState(
      title: title ?? this.title,
      reason: reason ?? this.reason,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
