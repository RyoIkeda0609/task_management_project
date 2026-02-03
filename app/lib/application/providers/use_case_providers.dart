import 'package:riverpod/riverpod.dart';
import 'package:app/application/use_cases/goal/create_goal_use_case.dart';
import 'package:app/application/use_cases/milestone/create_milestone_use_case.dart';
import 'package:app/application/use_cases/task/create_task_use_case.dart';

/// Goal UseCase Provider
final createGoalUseCaseProvider = Provider<CreateGoalUseCase>((ref) {
  return CreateGoalUseCaseImpl();
});

/// Milestone UseCase Provider
final createMilestoneUseCaseProvider = Provider<CreateMilestoneUseCase>((ref) {
  return CreateMilestoneUseCaseImpl();
});

/// Task UseCase Provider
final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCaseImpl();
});
