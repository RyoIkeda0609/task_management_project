class MilestoneDetailPageState {
  final String milestoneId;
  final bool isLoading;

  const MilestoneDetailPageState({
    required this.milestoneId,
    this.isLoading = false,
  });

  MilestoneDetailPageState copyWith({String? milestoneId, bool? isLoading}) {
    return MilestoneDetailPageState(
      milestoneId: milestoneId ?? this.milestoneId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
