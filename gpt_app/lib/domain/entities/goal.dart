
import '../value_objects/title.dart';
import '../value_objects/deadline.dart';
import '../value_objects/ids.dart';
import 'milestone.dart';

class Goal {
  final GoalId id;
  final Title title;
  final Deadline deadline;
  final List<Milestone> _milestones = [];

  Goal({
    required this.id,
    required this.title,
    required this.deadline,
  });

  List<Milestone> get milestones => List.unmodifiable(_milestones);

  void addMilestone(Milestone milestone) {
    if (milestone.goalId != id) {
      throw ArgumentError('Milestone belongs to different goal');
    }
    _milestones.add(milestone);
  }

  int get progress {
    if (_milestones.isEmpty) return 0;
    final sum =
        _milestones.map((m) => m.progress).reduce((a, b) => a + b);
    return (sum / _milestones.length).round();
  }
}
