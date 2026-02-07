
import '../exceptions/domain_exception.dart';

class Title {
  final String value;

  Title(this.value) {
    if (value.trim().isEmpty) {
      throw DomainException('Title cannot be empty');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Title && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
