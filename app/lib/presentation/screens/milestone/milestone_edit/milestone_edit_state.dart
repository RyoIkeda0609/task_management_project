class MilestoneEditPageState {
  final String title;
  final DateTime targetDate;
  final bool isLoading;

  const MilestoneEditPageState({
    this.title = '',
    required this.targetDate,
    this.isLoading = false,
  });

  MilestoneEditPageState copyWith({
    String? title,
    DateTime? targetDate,
    bool? isLoading,
  }) {
    return MilestoneEditPageState(
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
