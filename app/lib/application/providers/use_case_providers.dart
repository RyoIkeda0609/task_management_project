import 'package:riverpod/riverpod.dart';
import 'package:app/application/use_cases/goal/create_goal_use_case.dart';
import 'package:app/application/use_cases/goal/get_all_goals_use_case.dart';
import 'package:app/application/use_cases/goal/get_goal_by_id_use_case.dart';
import 'package:app/application/use_cases/goal/update_goal_use_case.dart';
import 'package:app/application/use_cases/goal/delete_goal_use_case.dart';
import 'package:app/application/use_cases/goal/search_goals_use_case.dart';
import 'package:app/application/use_cases/milestone/create_milestone_use_case.dart';
import 'package:app/application/use_cases/milestone/get_milestones_by_goal_id_use_case.dart';
import 'package:app/application/use_cases/milestone/update_milestone_use_case.dart';
import 'package:app/application/use_cases/milestone/delete_milestone_use_case.dart';
import 'package:app/application/use_cases/task/create_task_use_case.dart';
import 'package:app/application/use_cases/task/get_tasks_by_milestone_id_use_case.dart';
import 'package:app/application/use_cases/task/update_task_use_case.dart';
import 'package:app/application/use_cases/task/delete_task_use_case.dart';
import 'package:app/application/use_cases/task/change_task_status_use_case.dart';
import 'package:app/application/use_cases/task/get_all_tasks_today_use_case.dart';
import 'package:app/application/use_cases/progress/calculate_progress_use_case.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/infrastructure/persistence/hive/hive_goal_repository.dart';
import 'package:app/infrastructure/persistence/hive/hive_milestone_repository.dart';
import 'package:app/infrastructure/persistence/hive/hive_task_repository.dart';

// ==================== Goal UseCase Providers ====================

/// CreateGoalUseCase Provider
final createGoalUseCaseProvider = Provider<CreateGoalUseCase>((ref) {
  return CreateGoalUseCaseImpl();
});

/// GetAllGoalsUseCase Provider
final getAllGoalsUseCaseProvider = Provider<GetAllGoalsUseCase>((ref) {
  return GetAllGoalsUseCaseImpl(ref.watch(goalRepositoryProvider));
});

/// GetGoalByIdUseCase Provider
final getGoalByIdUseCaseProvider = Provider<GetGoalByIdUseCase>((ref) {
  return GetGoalByIdUseCaseImpl(ref.watch(goalRepositoryProvider));
});

/// UpdateGoalUseCase Provider
final updateGoalUseCaseProvider = Provider<UpdateGoalUseCase>((ref) {
  return UpdateGoalUseCaseImpl(
    ref.watch(goalRepositoryProvider),
    ref.watch(milestoneRepositoryProvider),
    ref.watch(taskRepositoryProvider),
  );
});

/// DeleteGoalUseCase Provider
final deleteGoalUseCaseProvider = Provider<DeleteGoalUseCase>((ref) {
  return DeleteGoalUseCaseImpl(
    ref.watch(goalRepositoryProvider),
    ref.watch(milestoneRepositoryProvider),
  );
});

/// SearchGoalsUseCase Provider
final searchGoalsUseCaseProvider = Provider<SearchGoalsUseCase>((ref) {
  return SearchGoalsUseCaseImpl(ref.watch(goalRepositoryProvider));
});

// ==================== Milestone UseCase Providers ====================

/// CreateMilestoneUseCase Provider
final createMilestoneUseCaseProvider = Provider<CreateMilestoneUseCase>((ref) {
  return CreateMilestoneUseCaseImpl();
});

/// GetMilestonesByGoalIdUseCase Provider
final getMilestonesByGoalIdUseCaseProvider =
    Provider<GetMilestonesByGoalIdUseCase>((ref) {
      return GetMilestonesByGoalIdUseCaseImpl(
        ref.watch(milestoneRepositoryProvider),
      );
    });

/// UpdateMilestoneUseCase Provider
final updateMilestoneUseCaseProvider = Provider<UpdateMilestoneUseCase>((ref) {
  return UpdateMilestoneUseCaseImpl(ref.watch(milestoneRepositoryProvider));
});

/// DeleteMilestoneUseCase Provider
final deleteMilestoneUseCaseProvider = Provider<DeleteMilestoneUseCase>((ref) {
  return DeleteMilestoneUseCaseImpl(
    ref.watch(milestoneRepositoryProvider),
    ref.watch(taskRepositoryProvider),
  );
});

// ==================== Task UseCase Providers ====================

/// CreateTaskUseCase Provider
final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCaseImpl();
});

/// GetTasksByMilestoneIdUseCase Provider
final getTasksByMilestoneIdUseCaseProvider =
    Provider<GetTasksByMilestoneIdUseCase>((ref) {
      return GetTasksByMilestoneIdUseCaseImpl(
        ref.watch(taskRepositoryProvider),
      );
    });

/// UpdateTaskUseCase Provider
final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCaseImpl(ref.watch(taskRepositoryProvider));
});

/// DeleteTaskUseCase Provider
final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCaseImpl(ref.watch(taskRepositoryProvider));
});

/// ChangeTaskStatusUseCase Provider
final changeTaskStatusUseCaseProvider = Provider<ChangeTaskStatusUseCase>((
  ref,
) {
  return ChangeTaskStatusUseCaseImpl(ref.watch(taskRepositoryProvider));
});

/// GetAllTasksTodayUseCase Provider
final getAllTasksTodayUseCaseProvider = Provider<GetAllTasksTodayUseCase>((
  ref,
) {
  return GetAllTasksTodayUseCaseImpl(ref.watch(taskRepositoryProvider));
});

// ==================== Progress UseCase Providers ====================

/// CalculateProgressUseCase Provider
final calculateProgressUseCaseProvider = Provider<CalculateProgressUseCase>((
  ref,
) {
  return CalculateProgressUseCaseImpl(
    ref.watch(goalRepositoryProvider),
    ref.watch(milestoneRepositoryProvider),
    ref.watch(taskRepositoryProvider),
  );
});

// ==================== Repository Providers ====================

/// GoalRepository Provider - Hive based implementation
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return HiveGoalRepository();
});

/// MilestoneRepository Provider - Hive based implementation
final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  return HiveMilestoneRepository();
});

/// TaskRepository Provider - Hive based implementation
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return HiveTaskRepository();
});
