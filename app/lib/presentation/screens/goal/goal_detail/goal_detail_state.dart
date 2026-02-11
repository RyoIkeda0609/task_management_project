class GoalDetailPageState {
  final String goalId;
  final bool isLoading;

  const GoalDetailPageState({required this.goalId, this.isLoading = false});

  GoalDetailPageState copyWith({String? goalId, bool? isLoading}) {
    return GoalDetailPageState(
      goalId: goalId ?? this.goalId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
