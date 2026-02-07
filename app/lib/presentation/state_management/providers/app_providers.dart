import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'repository_providers.dart';

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
        taskDetailProvider;

/// ======================== 既存コード対応の Provider（後方互換性） ========================
/// 注意：以下のProviderは古い設計を基に作成されており、
/// 新しいコードでは最新のStateNotifierProviderを使用してください。

/// すべてのゴール一覧を提供（FutureProvider）
/// 
/// @deprecated goalsProvider を使用してください
final goalListProvider = FutureProvider<List<Goal>>((ref) {
  return ref.watch(goalRepositoryProvider).getAllGoals();
});

/// ID指定でゴール詳細を提供（FutureProvider）
///
/// @deprecated goalDetailProvider を使用してください  
final goalByIdProvider = FutureProvider.family<Goal?, String>((ref, goalId) {
  return ref.watch(goalRepositoryProvider).getGoalById(goalId);
});

/// ゴール ID に紐付いたマイルストーン一覧を提供（FutureProvider）
///
/// @deprecated milestonsByGoalProvider を使用してください
final milestonesByGoalIdProvider =
    FutureProvider.family<List<Milestone>, String>((ref, goalId) {
      return ref.watch(milestoneRepositoryProvider).getMilestonesByGoalId(goalId);
    });

/// ID指定でマイルストーン詳細を提供（FutureProvider）
///
/// @deprecated milestoneDetailProvider を使用してください
final milestoneByIdProvider = FutureProvider.family<Milestone?, String>(
  (ref, milestoneId) {
    return ref.watch(milestoneRepositoryProvider).getMilestoneById(milestoneId);
  },
);

/// マイルストーン ID に紐付いたタスク一覧を提供（FutureProvider）
///
/// @deprecated tasksByMilestoneProvider を使用してください
final tasksByMilestoneIdProvider = FutureProvider.family<List<Task>, String>(
  (ref, milestoneId) {
    return ref.watch(taskRepositoryProvider).getTasksByMilestoneId(milestoneId);
  },
);

/// ID指定でタスク詳細を提供（FutureProvider）
///
/// @deprecated taskDetailProvider を使用してください
final taskByIdProvider = FutureProvider.family<Task?, String>((ref, taskId) {
  return ref.watch(taskRepositoryProvider).getTaskById(taskId);
});

/// すべてのタスク一覧を提供（FutureProvider）
///
/// @deprecated todayTasksProvider を使用してください
final taskListProvider = FutureProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).getAllTasks();
});

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
