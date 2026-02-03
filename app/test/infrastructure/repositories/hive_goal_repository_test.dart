import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/persistence/hive/hive_goal_repository.dart';

void main() {
  group('HiveGoalRepository', () {
    late HiveGoalRepository repository;

    setUp(() async {
      repository = HiveGoalRepository();
      // 注：本テストは実装のインターフェース確認用です
      // 実際の Hive 統合テストは別ファイルで実施してください
    });

    group('インターフェース確認', () {
      test('HiveGoalRepositoryが初期化可能なこと', () {
        expect(repository, isNotNull);
      });

      test('isInitializedメソッドが存在すること', () {
        expect(repository.isInitialized, isFalse);
      });
    });
  });
}
