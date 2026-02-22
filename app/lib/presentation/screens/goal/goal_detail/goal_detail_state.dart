import 'package:app/domain/entities/goal.dart';

enum GoalDetailViewState { loading, notFound, data, error }

/// ゴール詳細画面の UI状態
///
/// 表示用に整形された状態のみを保持
class GoalDetailPageState {
  final GoalDetailViewState viewState;
  final Goal? goal;
  final String errorMessage;

  const GoalDetailPageState({
    required this.viewState,
    this.goal,
    this.errorMessage = '',
  });

  /// ローディング状態
  factory GoalDetailPageState.loading() {
    return const GoalDetailPageState(viewState: GoalDetailViewState.loading);
  }

  /// データロード成功
  factory GoalDetailPageState.withData(Goal? goal) {
    if (goal == null) {
      return const GoalDetailPageState(viewState: GoalDetailViewState.notFound);
    }
    return GoalDetailPageState(viewState: GoalDetailViewState.data, goal: goal);
  }

  /// エラー
  factory GoalDetailPageState.withError(String message) {
    return GoalDetailPageState(
      viewState: GoalDetailViewState.error,
      errorMessage: message,
    );
  }

  GoalDetailPageState copyWith({
    GoalDetailViewState? viewState,
    Goal? goal,
    String? errorMessage,
  }) {
    return GoalDetailPageState(
      viewState: viewState ?? this.viewState,
      goal: goal ?? this.goal,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => viewState == GoalDetailViewState.loading;
  bool get isNotFound => viewState == GoalDetailViewState.notFound;
  bool get hasData => viewState == GoalDetailViewState.data && goal != null;
  bool get isError => viewState == GoalDetailViewState.error;

  // ========== 手術2-3: 表示用の整形文言 ==========
  String get formattedDeadline {
    final g = goal;
    if (g == null) return '期限未設定';
    final dt = g.deadline.value;
    return '${dt.year}年${dt.month}月${dt.day}日';
  }

  String get categoryLabel => goal?.category.value ?? 'Unknown';
  String get reasonLabel => goal?.description.value ?? '';
}
