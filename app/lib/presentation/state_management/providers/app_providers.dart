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
        todayTasksGroupedProvider,
        goalProgressProvider;

/// ======================== Onboarding / Initialization Providers ========================

/// オンボーディング完了フラグを管理
///
/// 初回起動時にオンボーディング画面を表示するかどうかを制御します。
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

/// アプリケーション初期化処理を提供
///
/// アプリケーション起動時に必要な初期化を実行します。
final appInitializationProvider = FutureProvider<bool>((ref) async {
  return true;
});
