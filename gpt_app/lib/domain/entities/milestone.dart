
import '../value_objects/title.dart';
import '../value_objects/deadline.dart';
import '../value_objects/ids.dart';
import '../exceptions/domain_exception.dart';
import 'task.dart';

class Milestone {
  final MilestoneId id;
  final GoalId goalId;
  final Title title;
  final Deadline deadline;
  final List<Task> _tasks = [];

  Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    required this.deadline,
    required Deadline goalDeadline,
  }) {
    if (deadline.isAfter(goalDeadline)) {
      throw DomainException('Milestone deadline exceeds goal deadline');
    }
  }

  List<Task> get tasks => List.unmodifiable(_tasks);

  void addTask(Task task) {
    if (task.milestoneId != id) {
      throw DomainException('Task belongs to different milestone');
    }
    _tasks.add(task);
  }

  int get progress {
    if (_tasks.isEmpty) return 0;
    final sum = _tasks.map((t) => t.progress).reduce((a, b) => a + b);
    return (sum / _tasks.length).round();
  }
}
