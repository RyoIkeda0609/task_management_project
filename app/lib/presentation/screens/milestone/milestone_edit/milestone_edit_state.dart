class MilestoneEditPageState {
  final String milestoneId; // 編集中のマイルストーンID
  final String title;
  final DateTime deadline;
  final bool isLoading;

  const MilestoneEditPageState({
    this.milestoneId = '',
    this.title = '',
    required this.deadline,
    this.isLoading = false,
  });

  MilestoneEditPageState copyWith({
    String? milestoneId,
    String? title,
    DateTime? deadline,
    bool? isLoading,
  }) {
    return MilestoneEditPageState(
      milestoneId: milestoneId ?? this.milestoneId,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
