/// スプラッシュ画面の状態
///
/// UI表示専用のモデル。ViewModel から受け取った値を表示形式に整形。
enum SplashState { loading, completed, error }

/// スプラッシュ画面の状態情報
///
/// Domainモデルをそのまま持ち込まない。
/// 表示に必要な情報のみ。
class SplashPageState {
  final SplashState state;
  final String? errorMessage;

  const SplashPageState({required this.state, this.errorMessage});

  factory SplashPageState.loading() {
    return const SplashPageState(state: SplashState.loading);
  }

  factory SplashPageState.completed() {
    return const SplashPageState(state: SplashState.completed);
  }

  factory SplashPageState.error(String? errorMessage) {
    return SplashPageState(
      state: SplashState.error,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => state == SplashState.loading;
  bool get isCompleted => state == SplashState.completed;
  bool get isError => state == SplashState.error;
}
