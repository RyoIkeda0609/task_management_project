
import '../exceptions/domain_exception.dart';

class Deadline {
  final DateTime value;

  Deadline(this.value) {
    if (value.isBefore(DateTime.now())) {
      throw DomainException('Deadline must be in the future');
    }
  }

  bool isAfter(Deadline other) => value.isAfter(other.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deadline && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
