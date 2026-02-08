import 'package:flutter_riverpod/flutter_riverpod.dart';

// ======================== Providers のエクスポート ========================
// Repository Providers
export 'repository_providers.dart'
    show
        goalRepositoryProvider,
        milestoneRepositoryProvider,
        taskRepositoryProvider;

// StateNotifier Providers（新）
export 'state_notifier_providers.dart'
    show
        goalsProvider,
        goalDetailProvider,
        milestonsByGoalProvider,
        milestoneDetailProvider,
        tasksByMilestoneProvider,
        todayTasksProvider,
        taskDetailProvider,
        todayTasksGroupedProvider;

/// ======================== Onboarding / Initialization Providers ========================

/// オンボーディング完了フラグを管理
///
/// 初回起動時にオンボーディング画面を表示するかどうかを制御します。
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

/// アプリケーション初期化処理を提供
///
/// アプリケーション起動時に必要な初期化を実行します。
/// 例：データベース初期化、ユーザーデータの読み込み等
final appInitializationProvider = FutureProvider<bool>((ref) async {
  // TODO: 実装が必要
  // 例えば以下の初期化処理を実装：
  // - Hive データベースの初期化
  // - ユーザー設定の読み込み
  // - オンボーディング完了フラグの確認
  return true;
});
