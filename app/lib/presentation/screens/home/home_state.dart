import 'package:app/domain/entities/goal.dart';

/// ホーム画面の表示状態
enum HomeViewState { loading, empty, data, error }

/// ホーム画面の UI 状態
///
/// Domain 層の Goal をそのまま持ち込まず、
/// UI 表示に最適化した形式のみを含む。
class HomePageState {
  final HomeViewState viewState;
  final List<Goal> goals; // Domain モデルは表示前提で使用
  final String? errorMessage;
  final int selectedTabIndex; // タブのインデックス

  const HomePageState({
    required this.viewState,
    required this.goals,
    required this.selectedTabIndex,
    this.errorMessage,
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
  factory HomePageState.withData(List<Goal> goals) {
    return HomePageState(
      viewState: goals.isEmpty ? HomeViewState.empty : HomeViewState.data,
      goals: goals,
      selectedTabIndex: 0,
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

  /// タブIndex を更新（新しい状態を返す）
  HomePageState updateTabIndex(int newIndex) {
    return HomePageState(
      viewState: viewState,
      goals: goals,
      selectedTabIndex: newIndex,
      errorMessage: errorMessage,
    );
  }

  // ヘルパーメソッド
  bool get isLoading => viewState == HomeViewState.loading;
  bool get isEmpty => viewState == HomeViewState.empty;
  bool get hasData => viewState == HomeViewState.data;
  bool get isError => viewState == HomeViewState.error;

  /// ソート済みゴール（期限が近い順）
  List<Goal> get sortedGoals {
    final sorted = [...goals];
    sorted.sort((a, b) => a.deadline.value.compareTo(b.deadline.value));
    return sorted;
  }
}
