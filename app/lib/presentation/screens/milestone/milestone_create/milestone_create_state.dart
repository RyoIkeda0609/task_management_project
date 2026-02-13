class MilestoneCreatePageState {
  final String title;
  final DateTime deadline;
  final bool isLoading;

  const MilestoneCreatePageState({
    this.title = '',
    required this.deadline,
    this.isLoading = false,
  });

  MilestoneCreatePageState copyWith({
    String? title,
    DateTime? deadline,
    bool? isLoading,
  }) {
    return MilestoneCreatePageState(
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
