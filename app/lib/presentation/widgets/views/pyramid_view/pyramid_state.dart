/// ピラミッドビューの状態
class PyramidPageState {
  /// 展開中のマイルストーンID のマップ
  final Map<String, bool> expandedMilestones;

  const PyramidPageState({required this.expandedMilestones});

  /// copyWith
  PyramidPageState copyWith({Map<String, bool>? expandedMilestones}) {
    return PyramidPageState(
      expandedMilestones: expandedMilestones ?? this.expandedMilestones,
    );
  }

  /// 指定マイルストーンが展開中かを判定
  bool isMilestoneExpanded(String milestoneId) {
    return expandedMilestones[milestoneId] ?? false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PyramidPageState &&
          runtimeType == other.runtimeType &&
          expandedMilestones == other.expandedMilestones;

  @override
  int get hashCode => expandedMilestones.hashCode;
}
