import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/shared/progress.dart';
import 'package:app/application/use_cases/task/get_tasks_grouped_by_status_use_case.dart';
import 'package:app/application/providers/use_case_providers.dart';
import '../notifiers/goal_notifier.dart';
import '../notifiers/milestone_notifier.dart';
import '../notifiers/task_notifier.dart';
import 'repository_providers.dart';

/// ======================== Goal State Providers ========================

/// ゴール一覧の状態を管理するProvider
///
/// 使用方法:
/// ```dart
/// final goalsAsync = ref.watch(goalsProvider);
/// goalsAsync.when(
///   data: (goals) => GoalListWidget(goals: goals),
///   loading: () => LoadingWidget(),
///   error: (error, stack) => ErrorWidget(error: error),
/// );
/// ```
final goalsProvider =
    StateNotifierProvider<GoalsNotifier, AsyncValue<List<Goal>>>((ref) {
      final repository = ref.watch(goalRepositoryProvider);
      return GoalsNotifier(repository)..loadGoals();
    });

/// 特定IDのゴール詳細を取得するProvider
///
/// 使用方法:
/// ```dart
/// final goalAsync = ref.watch(goalDetailProvider(goalId));
/// ```
final goalDetailProvider = FutureProvider.family<Goal?, String>((
  ref,
  goalId,
) async {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.getGoalById(goalId);
});

/// ======================== Milestone State Providers ========================

/// 特定ゴール配下のマイルストーン一覧を管理するProvider
///
/// 使用方法:
/// ```dart
/// final milestonesAsync = ref.watch(milestonesByGoalProvider(goalId));
/// ```
final milestonesByGoalProvider =
    StateNotifierProvider.family<
      MilestonesNotifier,
      AsyncValue<List<Milestone>>,
      String
    >((ref, goalId) {
      final repository = ref.watch(milestoneRepositoryProvider);
      final notifier = MilestonesNotifier(repository);
      notifier.loadMilestonesByGoalId(goalId);
      return notifier;
    });

/// 特定IDのマイルストーン詳細を取得するProvider
///
/// 使用方法:
/// ```dart
/// final milestoneAsync = ref.watch(milestoneDetailProvider(milestoneId));
/// ```
final milestoneDetailProvider = FutureProvider.family<Milestone?, String>((
  ref,
  milestoneId,
) async {
  final repository = ref.watch(milestoneRepositoryProvider);
  return repository.getMilestoneById(milestoneId);
});

/// ======================== Task State Providers ========================

/// 特定マイルストーン配下のタスク一覧を管理するProvider
///
/// 使用方法:
/// ```dart
/// final tasksAsync = ref.watch(tasksByMilestoneProvider(milestoneId));
/// ```
final tasksByMilestoneProvider =
    StateNotifierProvider.family<TasksNotifier, AsyncValue<List<Task>>, String>(
      (ref, milestoneId) {
        final repository = ref.watch(taskRepositoryProvider);
        final notifier = TasksNotifier(repository);
        notifier.loadTasksByMilestoneId(milestoneId);
        return notifier;
      },
    );

/// すべてのタスク一覧を管理するProvider
///
/// 使用方法:
/// ```dart
/// final tasksAsync = ref.watch(todayTasksProvider);
/// ```
final todayTasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
      final repository = ref.watch(taskRepositoryProvider);
      final notifier = TasksNotifier(repository);
      // すべてのタスクを読み込む（UI側でフィルタリング可能）
      notifier.loadAllTasks();
      return notifier;
    });

/// 特定IDのタスク詳細を取得するProvider
///
/// 使用方法:
/// ```dart
/// final taskAsync = ref.watch(taskDetailProvider(taskId));
/// ```
final taskDetailProvider = FutureProvider.family<Task?, String>((
  ref,
  taskId,
) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTaskById(taskId);
});

/// ======================== Grouped Task Providers ========================

/// 本日のタスクをステータス別にグループ化するProvider
///
/// 使用方法:
/// ```dart
/// final groupedAsync = ref.watch(todayTasksGroupedProvider);
/// groupedAsync.when(
///   data: (grouped) => _buildGroupedContent(grouped),
///   loading: () => LoadingWidget(),
///   error: (error, stack) => ErrorWidget(error: error),
/// );
/// ```
final todayTasksGroupedProvider = FutureProvider<GroupedTasks>((ref) async {
  final useCase = ref.watch(getTasksGroupedByStatusUseCaseProvider);
  final tasksAsync = ref.watch(todayTasksProvider);

  return tasksAsync.when(
    data: (tasks) => useCase.call(tasks),
    loading: () => throw Exception('Loading tasks...'),
    error: (error, stack) => throw error,
  );
});

/// ======================== Progress Providers ========================

/// 特定ゴールの進捗を計算するProvider
///
/// 使用方法:
/// ```dart
/// final progressAsync = ref.watch(goalProgressProvider(goalId));
/// progressAsync.when(
///   data: (progress) => Text('進捗: ${progress.value}%'),
///   loading: () => LoadingWidget(),
///   error: (error, stack) => ErrorWidget(error: error),
/// );
/// ```
final goalProgressProvider = FutureProvider.family<Progress, String>((
  ref,
  goalId,
) async {
  final useCase = ref.watch(calculateProgressUseCaseProvider);
  return useCase.calculateGoalProgress(goalId);
});
