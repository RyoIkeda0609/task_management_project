import 'package:app/domain/entities/milestone.dart';

enum MilestoneDetailViewState { loading, notFound, data, error }

/// マイルストーン詳細画面の UI状態
///
/// 表示用に整形された状態のみを保持
class MilestoneDetailPageState {
  final MilestoneDetailViewState viewState;
  final Milestone? milestone;
  final String? errorMessage;

  const MilestoneDetailPageState({
    required this.viewState,
    this.milestone,
    this.errorMessage,
  });

  /// ローディング状態
  factory MilestoneDetailPageState.loading() {
    return const MilestoneDetailPageState(
      viewState: MilestoneDetailViewState.loading,
    );
  }

  /// データロード成功
  factory MilestoneDetailPageState.withData(Milestone? milestone) {
    if (milestone == null) {
      return const MilestoneDetailPageState(
        viewState: MilestoneDetailViewState.notFound,
      );
    }
    return MilestoneDetailPageState(
      viewState: MilestoneDetailViewState.data,
      milestone: milestone,
    );
  }

  /// エラー
  factory MilestoneDetailPageState.withError(String message) {
    return MilestoneDetailPageState(
      viewState: MilestoneDetailViewState.error,
      errorMessage: message,
    );
  }

  MilestoneDetailPageState copyWith({
    MilestoneDetailViewState? viewState,
    Milestone? milestone,
    String? errorMessage,
  }) {
    return MilestoneDetailPageState(
      viewState: viewState ?? this.viewState,
      milestone: milestone ?? this.milestone,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => viewState == MilestoneDetailViewState.loading;
  bool get isNotFound => viewState == MilestoneDetailViewState.notFound;
  bool get hasData =>
      viewState == MilestoneDetailViewState.data && milestone != null;
  bool get isError => viewState == MilestoneDetailViewState.error;

  // ========== 手術2-3: 表示用の整形文言 ==========
  String get formattedDeadline {
    final m = milestone;
    if (m == null) return '期限未設定';
    final dt = m.deadline.value;
    return '${dt.year}年${dt.month}月${dt.day}日';
  }
}
