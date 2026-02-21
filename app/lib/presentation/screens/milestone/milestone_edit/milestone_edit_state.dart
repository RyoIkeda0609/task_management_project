class MilestoneEditPageState {
  final String milestoneId; // 編集中のマイルストーンID
  final String title;
  final String description;
  final DateTime deadline;
  final bool isLoading;

  const MilestoneEditPageState({
    this.milestoneId = '',
    this.title = '',
    this.description = '',
    required this.deadline,
    this.isLoading = false,
  });

  MilestoneEditPageState copyWith({
    String? milestoneId,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isLoading,
  }) {
    return MilestoneEditPageState(
      milestoneId: milestoneId ?? this.milestoneId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
