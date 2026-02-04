import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/infrastructure/persistence/hive/hive_goal_repository.dart';
import 'package:app/infrastructure/persistence/hive/hive_milestone_repository.dart';
import 'package:app/infrastructure/persistence/hive/hive_task_repository.dart';

/// ======================== Repository Providers ========================

/// GoalRepository インスタンスを提供
///
/// アプリケーション全体でGoalRepositoryを共有するため、
/// シングルトンパターンで提供します。
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return HiveGoalRepository();
});

/// MilestoneRepository インスタンスを提供
///
/// アプリケーション全体でMilestoneRepositoryを共有するため、
/// シングルトンパターンで提供します。
final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  return HiveMilestoneRepository();
});

/// TaskRepository インスタンスを提供
///
/// アプリケーション全体でTaskRepositoryを共有するため、
/// シングルトンパターンで提供します。
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return HiveTaskRepository();
});

/// ======================== Goal Providers ========================

/// すべてのゴール一覧を提供
///
/// ゴール一覧が更新された場合、自動的に再取得します。
final goalListProvider = FutureProvider<List<Goal>>((ref) {
  final goalRepository = ref.watch(goalRepositoryProvider);
  return goalRepository.getAllGoals();
});

/// ID指定でゴール詳細を提供
///
/// Family パターンで、複数のゴール詳細を管理できます。
final goalByIdProvider = FutureProvider.family<Goal?, String>((ref, goalId) {
  final goalRepository = ref.watch(goalRepositoryProvider);
  return goalRepository.getGoalById(goalId);
});

/// ======================== Milestone Providers ========================

/// ゴール ID に紐付いたマイルストーン一覧を提供
///
/// Family パターンで、複数のゴールに対応したマイルストーン一覧を管理できます。
final milestonesByGoalIdProvider =
    FutureProvider.family<List<Milestone>, String>((ref, goalId) {
      final milestoneRepository = ref.watch(milestoneRepositoryProvider);
      return milestoneRepository.getMilestonesByGoalId(goalId);
    });

/// ID指定でマイルストーン詳細を提供
///
/// Family パターンで、複数のマイルストーン詳細を管理できます。
final milestoneByIdProvider = FutureProvider.family<Milestone?, String>((
  ref,
  milestoneId,
) {
  final milestoneRepository = ref.watch(milestoneRepositoryProvider);
  return milestoneRepository.getMilestoneById(milestoneId);
});

/// ======================== Task Providers ========================

/// マイルストーン ID に紐付いたタスク一覧を提供
///
/// Family パターンで、複数のマイルストーンに対応したタスク一覧を管理できます。
final tasksByMilestoneIdProvider = FutureProvider.family<List<Task>, String>((
  ref,
  milestoneId,
) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return taskRepository.getTasksByMilestoneId(milestoneId);
});

/// ID指定でタスク詳細を提供
///
/// Family パターンで、複数のタスク詳細を管理できます。
final taskByIdProvider = FutureProvider.family<Task?, String>((ref, taskId) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return taskRepository.getTaskById(taskId);
});

/// すべてのタスク一覧を提供
///
/// タスク一覧が更新された場合、自動的に再取得します。
final taskListProvider = FutureProvider<List<Task>>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return taskRepository.getAllTasks();
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
