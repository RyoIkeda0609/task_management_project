
import '../exceptions/domain_exception.dart';

abstract class EntityId {
  final String value;
  EntityId(this.value) {
    if (value.isEmpty) {
      throw DomainException('ID cannot be empty');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is EntityId &&
          other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class GoalId extends EntityId {
  GoalId(super.value);
}

class MilestoneId extends EntityId {
  MilestoneId(super.value);
}

class TaskId extends EntityId {
  TaskId(super.value);
}
