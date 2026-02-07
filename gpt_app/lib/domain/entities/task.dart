
import '../value_objects/title.dart';
import '../value_objects/deadline.dart';
import '../value_objects/task_status.dart';
import '../value_objects/ids.dart';

class Task {
  final TaskId id;
  final MilestoneId milestoneId;
  final Title title;
  final Deadline deadline;
  TaskStatus _status;

  Task({
    required this.id,
    required this.milestoneId,
    required this.title,
    required this.deadline,
    TaskStatus status = TaskStatus.todo,
  }) : _status = status;

  TaskStatus get status => _status;

  int get progress => _status.progress;

  void start() {
    if (_status != TaskStatus.todo) return;
    _status = TaskStatus.doing;
  }

  void complete() {
    _status = TaskStatus.done;
  }
}
