
import 'package:test/test.dart';
import '../../../lib/domain/value_objects/ids.dart';

void main() {
  test('EntityId equality works by value', () {
    expect(GoalId('a'), GoalId('a'));
    expect(GoalId('a') == GoalId('b'), false);
  });
}
