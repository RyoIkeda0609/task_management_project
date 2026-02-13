import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/presentation/widgets/views/pyramid_view/pyramid_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PyramidMilestoneNode - Card Height', () {
    testWidgets('renders milestone node with correct structure', (
      WidgetTester tester,
    ) async {
      final milestone = Milestone(
        id: MilestoneId('milestone-1'),
        goalId: 'goal-1',
        title: MilestoneTitle('Phase 1'),
        deadline: MilestoneDeadline(DateTime(2026, 3, 1)),
      );

      const emptyTasksAsync = AsyncValue<List<Task>>.data([]);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PyramidMilestoneNode(
                milestone: milestone,
                goalId: 'goal-1',
                milestoneTasks: emptyTasksAsync,
              ),
            ),
          ),
        ),
      );

      // マイルストーンタイトルが表示されているか
      expect(find.text('Phase 1'), findsOneWidget);

      // ExpansionTile が存在するか
      expect(find.byType(ExpansionTile), findsOneWidget);
    });

    testWidgets('displays tasks when provided', (WidgetTester tester) async {
      final milestone = Milestone(
        id: MilestoneId('milestone-2'),
        goalId: 'goal-1',
        title: MilestoneTitle('Phase 2'),
        deadline: MilestoneDeadline(DateTime(2026, 4, 1)),
      );

      final tasks = <Task>[
        Task(
          id: TaskId('task-1'),
          milestoneId: 'milestone-2',
          title: TaskTitle('Task 1'),
          description: TaskDescription('First task description'),
          deadline: TaskDeadline(DateTime(2026, 4, 5)),
          status: TaskStatus.todo(),
        ),
        Task(
          id: TaskId('task-2'),
          milestoneId: 'milestone-2',
          title: TaskTitle('Task 2'),
          description: TaskDescription('Second task description'),
          deadline: TaskDeadline(DateTime(2026, 4, 10)),
          status: TaskStatus.doing(),
        ),
      ];

      final tasksAsync = AsyncValue<List<Task>>.data(tasks);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PyramidMilestoneNode(
                milestone: milestone,
                goalId: 'goal-1',
                milestoneTasks: tasksAsync,
              ),
            ),
          ),
        ),
      );

      // マイルストーンタイトルが表示されているか
      expect(find.text('Phase 2'), findsOneWidget);

      // 展開ボタン（ExpansionTile）が表示されているか
      expect(find.byType(ExpansionTile), findsOneWidget);
    });

    testWidgets('displays empty state when no tasks', (
      WidgetTester tester,
    ) async {
      final milestone = Milestone(
        id: MilestoneId('milestone-3'),
        goalId: 'goal-1',
        title: MilestoneTitle('Phase 3'),
        deadline: MilestoneDeadline(DateTime(2026, 5, 1)),
      );

      const emptyTasksAsync = AsyncValue<List<Task>>.data([]);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PyramidMilestoneNode(
                milestone: milestone,
                goalId: 'goal-1',
                milestoneTasks: emptyTasksAsync,
              ),
            ),
          ),
        ),
      );

      // マイルストーンが表示されているか
      expect(find.text('Phase 3'), findsOneWidget);

      // ExpansionTile が存在するか
      expect(find.byType(ExpansionTile), findsOneWidget);
    });
  });

  group('PyramidTaskNode - Display', () {
    testWidgets('renders task node with title and status', (
      WidgetTester tester,
    ) async {
      final task = Task(
        id: TaskId('task-1'),
        milestoneId: 'milestone-1',
        title: TaskTitle('Complete Documentation'),
        description: TaskDescription('Write docs for the new feature'),
        deadline: TaskDeadline(DateTime(2026, 3, 15)),
        status: TaskStatus.todo(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PyramidTaskNode(task: task)),
        ),
      );

      // タスクタイトルが表示されているか
      expect(find.text('Complete Documentation'), findsOneWidget);
    });

    testWidgets('renders multiple tasks with different statuses', (
      WidgetTester tester,
    ) async {
      final tasks = [
        Task(
          id: TaskId('task-1'),
          milestoneId: 'milestone-1',
          title: TaskTitle('Task 1 - TODO'),
          description: TaskDescription('First task description'),
          deadline: TaskDeadline(DateTime(2026, 3, 10)),
          status: TaskStatus.todo(),
        ),
        Task(
          id: TaskId('task-2'),
          milestoneId: 'milestone-1',
          title: TaskTitle('Task 2 - In Progress'),
          description: TaskDescription('Second task description'),
          deadline: TaskDeadline(DateTime(2026, 3, 12)),
          status: TaskStatus.doing(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [for (final task in tasks) PyramidTaskNode(task: task)],
            ),
          ),
        ),
      );

      expect(find.text('Task 1 - TODO'), findsOneWidget);
      expect(find.text('Task 2 - In Progress'), findsOneWidget);
    });
  });
}
