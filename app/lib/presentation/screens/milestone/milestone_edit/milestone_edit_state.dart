class MilestoneEditPageState {
  final String milestoneId; // 編集中のマイルストーンID
  final String title;
  final DateTime targetDate;
  final bool isLoading;

  const MilestoneEditPageState({
    this.milestoneId = '',
    this.title = '',
    required this.targetDate,
    this.isLoading = false,
  });

  MilestoneEditPageState copyWith({
    String? milestoneId,
    String? title,
    DateTime? targetDate,
    bool? isLoading,
  }) {
    return MilestoneEditPageState(
      milestoneId: milestoneId ?? this.milestoneId,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
