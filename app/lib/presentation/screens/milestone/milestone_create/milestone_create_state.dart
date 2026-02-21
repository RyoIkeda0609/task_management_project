class MilestoneCreatePageState {
  final String title;
  final String description;
  final DateTime deadline;
  final bool isLoading;

  const MilestoneCreatePageState({
    this.title = '',
    this.description = '',
    required this.deadline,
    this.isLoading = false,
  });

  MilestoneCreatePageState copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    bool? isLoading,
  }) {
    return MilestoneCreatePageState(
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
