import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/screens/home/home_screen.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/state_management/providers/app_providers.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';

class FakeGoalRepository implements GoalRepository {
  @override
  Future<void> saveGoal(goal) async {}

  @override
  Future<List<Goal>> getAllGoals() async => [];

  @override
  Future<Goal?> getGoalById(String id) async => null;

  @override
  Future<void> deleteGoal(String id) async {}

  @override
  Future<void> deleteAllGoals() async {}

  @override
  Future<int> getGoalCount() async => 0;
}

class FakeMilestoneRepository implements MilestoneRepository {
  @override
  Future<void> saveMilestone(milestone) async {}

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async => [];

  @override
  Future<List<Milestone>> getAllMilestones() async => [];

  @override
  Future<Milestone?> getMilestoneById(String id) async => null;

  @override
  Future<void> deleteMilestone(String id) async {}

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async {}

  @override
  Future<int> getMilestoneCount() async => 0;
}

class FakeTaskRepository implements TaskRepository {
  @override
  Future<void> saveTask(Task task) async {}

  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<Task?> getTaskById(String id) async => null;

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async => [];

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async {}

  @override
  Future<int> getTaskCount() async => 0;
}

void main() {
  group('HomeScreen', () {
    testWidgets('home screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            goalRepositoryProvider.overrideWithValue(FakeGoalRepository()),
            milestoneRepositoryProvider.overrideWithValue(
              FakeMilestoneRepository(),
            ),
            taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
          ],
          child: MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // ホーム画面が正常に表示されていることを確認
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
