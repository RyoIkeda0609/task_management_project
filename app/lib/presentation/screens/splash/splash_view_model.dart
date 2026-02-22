import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'splash_state.dart';

/// スプラッシュ画面のViewModel
///
/// 責務：
/// - 初期化処理のオーケストレーション
/// - UI状態の更新
///
/// 禁止：
/// - UI部品の操作
/// - BuildContext の保持
class SplashViewModel extends StateNotifier<SplashPageState> {
  SplashViewModel() : super(SplashPageState.loading());

  /// 初期化処理を実行
  ///
  /// 2秒待機してからオンボーディング完了フラグを確認し、
  /// 遷移先を決定します。
  Future<bool> initialize() async {
    try {
      // 2秒待機
      await Future.delayed(const Duration(seconds: 2));

      // オンボーディング完了フラグを確認
      // 実装例：将来的にRepositoryから読み込むことも可能
      state = SplashPageState.completed();

      return true;
    } catch (e) {
      state = SplashPageState.error(e.toString());
      return false;
    }
  }
}

/// スプラッシュ画面のViewModel Provider
final splashViewModelProvider =
    StateNotifierProvider<SplashViewModel, SplashPageState>((ref) {
      return SplashViewModel();
    });
