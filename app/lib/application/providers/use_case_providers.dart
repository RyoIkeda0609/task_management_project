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
import 'package:app/application/use_cases/task/get_tasks_grouped_by_status_use_case.dart';
import 'package:app/application/use_cases/progress/calculate_progress_use_case.dart';

import 'package:app/domain/services/goal_completion_service.dart';
import 'package:app/domain/services/milestone_completion_service.dart';
import 'package:app/domain/services/task_completion_service.dart';
import 'package:app/application/providers/repository_providers.dart';

import 'package:app/application/app_service_facade.dart';

// ==================== Domain Service Providers ====================

/// GoalCompletionService Provider
final goalCompletionServiceProvider = Provider<GoalCompletionService>((ref) {
  return GoalCompletionService(
    ref.watch(milestoneRepositoryProvider),
    ref.watch(taskRepositoryProvider),
  );
});

/// MilestoneCompletionService Provider
final milestoneCompletionServiceProvider = Provider<MilestoneCompletionService>(
  (ref) {
    return MilestoneCompletionService(ref.watch(taskRepositoryProvider));
  },
);

/// TaskCompletionService Provider
final taskCompletionServiceProvider = Provider<TaskCompletionService>((ref) {
  return TaskCompletionService(ref.watch(taskRepositoryProvider));
});

// ==================== Goal UseCase Providers ====================

/// CreateGoalUseCase Provider
final createGoalUseCaseProvider = Provider<CreateGoalUseCase>((ref) {
  return CreateGoalUseCaseImpl(ref.watch(goalRepositoryProvider));
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
    ref.watch(goalCompletionServiceProvider),
  );
});

/// DeleteGoalUseCase Provider
final deleteGoalUseCaseProvider = Provider<DeleteGoalUseCase>((ref) {
  return DeleteGoalUseCaseImpl(
    ref.watch(goalRepositoryProvider),
    ref.watch(milestoneRepositoryProvider),
    ref.watch(taskRepositoryProvider),
  );
});

/// SearchGoalsUseCase Provider
final searchGoalsUseCaseProvider = Provider<SearchGoalsUseCase>((ref) {
  return SearchGoalsUseCaseImpl(ref.watch(goalRepositoryProvider));
});

// ==================== Milestone UseCase Providers ====================

/// CreateMilestoneUseCase Provider
final createMilestoneUseCaseProvider = Provider<CreateMilestoneUseCase>((ref) {
  return CreateMilestoneUseCaseImpl(
    ref.watch(milestoneRepositoryProvider),
    ref.watch(goalRepositoryProvider),
  );
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
  return UpdateMilestoneUseCaseImpl(
    ref.watch(milestoneRepositoryProvider),
    ref.watch(milestoneCompletionServiceProvider),
  );
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
  return CreateTaskUseCaseImpl(
    ref.watch(taskRepositoryProvider),
    ref.watch(milestoneRepositoryProvider),
  );
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
  return UpdateTaskUseCaseImpl(
    ref.watch(taskRepositoryProvider),
    ref.watch(taskCompletionServiceProvider),
  );
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

/// CalculateProgressUseCase Provider
final calculateProgressUseCaseProvider = Provider<CalculateProgressUseCase>((
  ref,
) {
  return CalculateProgressUseCaseImpl(
    ref.watch(goalCompletionServiceProvider),
    ref.watch(milestoneCompletionServiceProvider),
  );
});

/// GetTasksGroupedByStatusUseCase Provider
final getTasksGroupedByStatusUseCaseProvider =
    Provider<GetTasksGroupedByStatusUseCase>((ref) {
      return GetTasksGroupedByStatusUseCaseImpl();
    });

// ==================== Application Service Facade Provider ====================

/// AppServiceFacade Provider
/// Presentation層がすべてのUseCaseにアクセスするための単一エントリーポイント
final appServiceFacadeProvider = Provider<AppServiceFacade>((ref) {
  return AppServiceFacade(
    // Goal UseCases
    createGoalUseCase: ref.watch(createGoalUseCaseProvider),
    deleteGoalUseCase: ref.watch(deleteGoalUseCaseProvider),
    getAllGoalsUseCase: ref.watch(getAllGoalsUseCaseProvider),
    getGoalByIdUseCase: ref.watch(getGoalByIdUseCaseProvider),
    searchGoalsUseCase: ref.watch(searchGoalsUseCaseProvider),
    updateGoalUseCase: ref.watch(updateGoalUseCaseProvider),
    // Milestone UseCases
    createMilestoneUseCase: ref.watch(createMilestoneUseCaseProvider),
    deleteMilestoneUseCase: ref.watch(deleteMilestoneUseCaseProvider),
    getMilestonesByGoalIdUseCase: ref.watch(
      getMilestonesByGoalIdUseCaseProvider,
    ),
    updateMilestoneUseCase: ref.watch(updateMilestoneUseCaseProvider),
    // Task UseCases
    changeTaskStatusUseCase: ref.watch(changeTaskStatusUseCaseProvider),
    createTaskUseCase: ref.watch(createTaskUseCaseProvider),
    deleteTaskUseCase: ref.watch(deleteTaskUseCaseProvider),
    getAllTasksTodayUseCase: ref.watch(getAllTasksTodayUseCaseProvider),
    getTasksByMilestoneIdUseCase: ref.watch(
      getTasksByMilestoneIdUseCaseProvider,
    ),
    getTasksGroupedByStatusUseCase: ref.watch(
      getTasksGroupedByStatusUseCaseProvider,
    ),
    updateTaskUseCase: ref.watch(updateTaskUseCaseProvider),
    // Progress UseCases
    calculateProgressUseCase: ref.watch(calculateProgressUseCaseProvider),
  );
});
