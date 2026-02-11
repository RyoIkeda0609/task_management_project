class MilestoneCreatePageState {
  final String title;
  final DateTime selectedTargetDate;
  final bool isLoading;

  const MilestoneCreatePageState({
    this.title = '',
    required this.selectedTargetDate,
    this.isLoading = false,
  });

  MilestoneCreatePageState copyWith({
    String? title,
    DateTime? selectedTargetDate,
    bool? isLoading,
  }) {
    return MilestoneCreatePageState(
      title: title ?? this.title,
      selectedTargetDate: selectedTargetDate ?? this.selectedTargetDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
