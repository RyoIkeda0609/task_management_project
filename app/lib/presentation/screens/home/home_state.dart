import 'package:app/domain/entities/goal.dart';

/// ホーム画面の表示状態
enum HomeViewState { loading, empty, data, error }

/// ゴールフィルター種別
enum HomeGoalFilter {
  /// 活動中（進捗 < 100%）
  active,

  /// 完了済み（進捗 100%）
  completed,
}

/// ホーム画面の UI 状態
///
/// Domain 層の Goal をそのまま持ち込まず、
/// UI 表示に最適化した形式のみを含む。
class HomePageState {
  final HomeViewState viewState;
  final List<Goal> goals;
  final String? errorMessage;
  final int selectedTabIndex;
  final HomeGoalFilter filter;

  /// ゴールIDごとの進捗率（0〜100）
  final Map<String, int> goalProgressMap;

  const HomePageState({
    required this.viewState,
    required this.goals,
    required this.selectedTabIndex,
    this.errorMessage,
    this.filter = HomeGoalFilter.active,
    this.goalProgressMap = const {},
  });

  /// 初期状態（ローディング）
  factory HomePageState.initial() {
    return const HomePageState(
      viewState: HomeViewState.loading,
      goals: [],
      selectedTabIndex: 0,
    );
  }

  /// データ取得成功
  factory HomePageState.withData(
    List<Goal> goals, {
    Map<String, int> goalProgressMap = const {},
    HomeGoalFilter filter = HomeGoalFilter.active,
  }) {
    return HomePageState(
      viewState: goals.isEmpty ? HomeViewState.empty : HomeViewState.data,
      goals: goals,
      selectedTabIndex: 0,
      goalProgressMap: goalProgressMap,
      filter: filter,
    );
  }

  /// エラー
  factory HomePageState.withError(String message) {
    return HomePageState(
      viewState: HomeViewState.error,
      goals: [],
      selectedTabIndex: 0,
      errorMessage: message,
    );
  }

  /// copyWith
  HomePageState copyWith({
    HomeViewState? viewState,
    List<Goal>? goals,
    int? selectedTabIndex,
    String? errorMessage,
    HomeGoalFilter? filter,
    Map<String, int>? goalProgressMap,
  }) {
    return HomePageState(
      viewState: viewState ?? this.viewState,
      goals: goals ?? this.goals,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      errorMessage: errorMessage ?? this.errorMessage,
      filter: filter ?? this.filter,
      goalProgressMap: goalProgressMap ?? this.goalProgressMap,
    );
  }

  // ヘルパーメソッド
  bool get isLoading => viewState == HomeViewState.loading;
  bool get isEmpty => viewState == HomeViewState.empty;
  bool get hasData => viewState == HomeViewState.data;
  bool get isError => viewState == HomeViewState.error;

  /// フィルター適用後のソート済みゴール（期限が近い順）
  List<Goal> get sortedGoals {
    final filtered = goals.where((goal) {
      final progress = goalProgressMap[goal.itemId.value] ?? 0;
      return switch (filter) {
        HomeGoalFilter.active => progress < 100,
        HomeGoalFilter.completed => progress >= 100,
      };
    }).toList();
    filtered.sort((a, b) => a.deadline.value.compareTo(b.deadline.value));
    return filtered;
  }
}
