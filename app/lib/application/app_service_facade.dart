/// AppServiceFacade
/// Application層のすべてのUseCaseへのアクセスを提供する単一のエントリーポイント
/// Presentation層はこのファサードを通じてのみUseCase にアクセスすることで、
/// 依存性を最小化し、Application層の構造変更の影響を局所化できる
///
/// --- 現在の実装方針 ---
/// Presentation層は Riverpod の個別 UseCase Provider
/// （use_case_providers.dart）を直接 ref.watch/read している。
/// このファサードはその代替エントリーポイントとして定義されており、
/// テストや将来的なリファクタリングで「UseCase へのアクセスを単一クラスに集約したい」
/// 場合に活用できる。現状は個別 Provider が UI に近い粒度で利用できるため
/// ファサード経由への統一は行っていない。
library;

import 'package:app/application/use_cases/goal/create_goal_use_case.dart';
import 'package:app/application/use_cases/goal/delete_goal_use_case.dart';
import 'package:app/application/use_cases/goal/get_all_goals_use_case.dart';
import 'package:app/application/use_cases/goal/get_goal_by_id_use_case.dart';
import 'package:app/application/use_cases/goal/search_goals_use_case.dart';
import 'package:app/application/use_cases/goal/update_goal_use_case.dart';

import 'package:app/application/use_cases/milestone/create_milestone_use_case.dart';
import 'package:app/application/use_cases/milestone/delete_milestone_use_case.dart';
import 'package:app/application/use_cases/milestone/get_milestones_by_goal_id_use_case.dart';
import 'package:app/application/use_cases/milestone/update_milestone_use_case.dart';

import 'package:app/application/use_cases/task/change_task_status_use_case.dart';
import 'package:app/application/use_cases/task/create_task_use_case.dart';
import 'package:app/application/use_cases/task/delete_task_use_case.dart';
import 'package:app/application/use_cases/task/get_all_tasks_today_use_case.dart';
import 'package:app/application/use_cases/task/get_tasks_by_milestone_id_use_case.dart';
import 'package:app/application/use_cases/task/get_tasks_grouped_by_status_use_case.dart';
import 'package:app/application/use_cases/task/update_task_use_case.dart';

import 'package:app/application/use_cases/progress/calculate_progress_use_case.dart';

/// AppServiceFacade
/// Application層すべてのUseCaseへのアクセスを提供するファサード
class AppServiceFacade {
  // Goal UseCases
  final CreateGoalUseCase createGoalUseCase;
  final DeleteGoalUseCase deleteGoalUseCase;
  final GetAllGoalsUseCase getAllGoalsUseCase;
  final GetGoalByIdUseCase getGoalByIdUseCase;
  final SearchGoalsUseCase searchGoalsUseCase;
  final UpdateGoalUseCase updateGoalUseCase;

  // Milestone UseCases
  final CreateMilestoneUseCase createMilestoneUseCase;
  final DeleteMilestoneUseCase deleteMilestoneUseCase;
  final GetMilestonesByGoalIdUseCase getMilestonesByGoalIdUseCase;
  final UpdateMilestoneUseCase updateMilestoneUseCase;

  // Task UseCases
  final ChangeTaskStatusUseCase changeTaskStatusUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final GetAllTasksTodayUseCase getAllTasksTodayUseCase;
  final GetTasksByMilestoneIdUseCase getTasksByMilestoneIdUseCase;
  final GetTasksGroupedByStatusUseCase getTasksGroupedByStatusUseCase;
  final UpdateTaskUseCase updateTaskUseCase;

  // Progress UseCases
  final CalculateProgressUseCase calculateProgressUseCase;

  AppServiceFacade({
    // Goal
    required this.createGoalUseCase,
    required this.deleteGoalUseCase,
    required this.getAllGoalsUseCase,
    required this.getGoalByIdUseCase,
    required this.searchGoalsUseCase,
    required this.updateGoalUseCase,
    // Milestone
    required this.createMilestoneUseCase,
    required this.deleteMilestoneUseCase,
    required this.getMilestonesByGoalIdUseCase,
    required this.updateMilestoneUseCase,
    // Task
    required this.changeTaskStatusUseCase,
    required this.createTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getAllTasksTodayUseCase,
    required this.getTasksByMilestoneIdUseCase,
    required this.getTasksGroupedByStatusUseCase,
    required this.updateTaskUseCase,
    // Progress
    required this.calculateProgressUseCase,
  });
}
