/// オンボーディング画面の状態
///
/// UI表示専用のモデル。ViewModel から受け取った値を表示形式に整形。
class OnboardingPageState {
  /// 現在のページインデックス（0 or 1）
  final int currentPageIndex;

  /// オンボーディング完了フラグ
  final bool isCompleted;

  /// エラーメッセージ
  final String? errorMessage;

  const OnboardingPageState({
    required this.currentPageIndex,
    required this.isCompleted,
    this.errorMessage,
  });

  factory OnboardingPageState.initial() {
    return const OnboardingPageState(currentPageIndex: 0, isCompleted: false);
  }

  /// ページ数
  static const int totalPages = 2;

  /// 最後のページかどうか
  bool get isLastPage => currentPageIndex == totalPages - 1;

  /// ボタンテキスト：最後のページなら「開始する」、それ以外は「次へ」
  String get buttonText => isLastPage ? '開始する' : '次へ';

  /// 次のページへ遷移（またはページの最後なら完了）
  OnboardingPageState nextPageOrComplete() {
    if (isLastPage) {
      return OnboardingPageState(
        currentPageIndex: currentPageIndex,
        isCompleted: true,
      );
    } else {
      return OnboardingPageState(
        currentPageIndex: currentPageIndex + 1,
        isCompleted: false,
      );
    }
  }
}
