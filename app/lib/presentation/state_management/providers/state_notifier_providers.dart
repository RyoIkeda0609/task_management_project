import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/shared/progress.dart';
import 'package:app/application/use_cases/task/get_tasks_grouped_by_status_use_case.dart';
import 'package:app/application/providers/use_case_providers.dart'
    show
        getAllGoalsUseCaseProvider,
        getGoalByIdUseCaseProvider,
        getMilestonesByGoalIdUseCaseProvider,
        getMilestoneByIdUseCaseProvider,
        getTasksByMilestoneIdUseCaseProvider,
        getAllTasksTodayUseCaseProvider,
        getTaskByIdUseCaseProvider,
        getTasksGroupedByStatusUseCaseProvider,
        calculateProgressUseCaseProvider;
import '../notifiers/goal_notifier.dart';
import '../notifiers/milestone_notifier.dart';
import '../notifiers/task_notifier.dart';
import 'package:app/application/providers/repository_providers.dart'
    show taskRepositoryProvider;

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
      final useCase = ref.watch(getAllGoalsUseCaseProvider);
      return GoalsNotifier(useCase)..loadGoals();
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
  final useCase = ref.watch(getGoalByIdUseCaseProvider);
  return useCase(goalId);
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
      final useCase = ref.watch(getMilestonesByGoalIdUseCaseProvider);
      final notifier = MilestonesNotifier(useCase);
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
  final useCase = ref.watch(getMilestoneByIdUseCaseProvider);
  return useCase(milestoneId);
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
        final useCase = ref.watch(getTasksByMilestoneIdUseCaseProvider);
        final notifier = TasksNotifier.forMilestone(useCase);
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
      final useCase = ref.watch(getAllTasksTodayUseCaseProvider);
      final notifier = TasksNotifier.forAll(useCase);
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
  final useCase = ref.watch(getTaskByIdUseCaseProvider);
  return useCase(taskId);
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
    loading: () => useCase.call([]),
    error: (error, stack) => throw error,
  );
});

/// ======================== Tasks by Goal Provider ========================

/// 特定ゴール配下の全タスクを取得するProvider
///
/// ゴールに紐づく全マイルストーンのタスクをまとめて返します。
/// ゴール詳細画面のカレンダービュー等で使用します。
///
/// 使用方法:
/// ```dart
/// final tasksAsync = ref.watch(tasksByGoalProvider(goalId));
/// ```
final tasksByGoalProvider = FutureProvider.family<List<Task>, String>((
  ref,
  goalId,
) async {
  final getMilestonesUseCase = ref.watch(getMilestonesByGoalIdUseCaseProvider);
  final getTasksUseCase = ref.watch(getTasksByMilestoneIdUseCaseProvider);

  final milestones = await getMilestonesUseCase(goalId);
  final allTasks = <Task>[];
  for (final milestone in milestones) {
    final tasks = await getTasksUseCase(milestone.itemId.value);
    allTasks.addAll(tasks);
  }
  return allTasks;
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

/// ======================== Date Selection Providers ========================

/// 「今日のタスク」画面で選択されている日付
///
/// デフォルトは本日。前日・翌日ボタンで変更可能。
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// 選択日付のタスクをステータス別にグループ化するProvider
///
/// [selectedDateProvider] で選ばれた日付と期限が一致するタスクのみ返す。
/// 使用方法:
/// ```dart
/// final groupedAsync = ref.watch(tasksBySelectedDateGroupedProvider);
/// ```
final tasksBySelectedDateGroupedProvider = FutureProvider<GroupedTasks>((
  ref,
) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final taskRepository = ref.watch(taskRepositoryProvider);
  final groupUseCase = ref.watch(getTasksGroupedByStatusUseCaseProvider);

  final allTasks = await taskRepository.getAllTasks();

  final tasksForDate = allTasks.where((task) {
    final d = task.deadline.value;
    return d.year == selectedDate.year &&
        d.month == selectedDate.month &&
        d.day == selectedDate.day;
  }).toList();

  return groupUseCase.call(tasksForDate);
});
