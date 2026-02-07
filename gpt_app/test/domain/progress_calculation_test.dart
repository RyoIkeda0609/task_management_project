
import 'package:test/test.dart';
import '../../../lib/domain/entities/task.dart';
import '../../../lib/domain/entities/milestone.dart';
import '../../../lib/domain/entities/goal.dart';
import '../../../lib/domain/value_objects/ids.dart';
import '../../../lib/domain/value_objects/title.dart';
import '../../../lib/domain/value_objects/deadline.dart';
import '../../../lib/domain/value_objects/task_status.dart';

void main() {
  test('Goal progress is aggregated from tasks', () {
    final goal = Goal(
      id: GoalId('g1'),
      title: Title('Goal'),
      deadline: Deadline(DateTime.now().add(Duration(days: 10))),
    );

    final milestone = Milestone(
      id: MilestoneId('m1'),
      goalId: goal.id,
      title: Title('MS'),
      deadline: Deadline(DateTime.now().add(Duration(days: 5))),
      goalDeadline: goal.deadline,
    );

    final task1 = Task(
      id: TaskId('t1'),
      milestoneId: milestone.id,
      title: Title('Task1'),
      deadline: Deadline(DateTime.now().add(Duration(days: 1))),
      status: TaskStatus.done,
    );

    final task2 = Task(
      id: TaskId('t2'),
      milestoneId: milestone.id,
      title: Title('Task2'),
      deadline: Deadline(DateTime.now().add(Duration(days: 1))),
      status: TaskStatus.todo,
    );

    milestone.addTask(task1);
    milestone.addTask(task2);
    goal.addMilestone(milestone);

    expect(milestone.progress, 50);
    expect(goal.progress, 50);
  });
}
