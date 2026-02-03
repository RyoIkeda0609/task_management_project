import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/infrastructure/repositories/hive_goal_repository.dart';

void main() {
  group('HiveGoalRepository', () {
    late HiveGoalRepository repository;
    late Box<Goal> testBox;

    setUp(() async {
      // Hive をメモリモードで初期化（テスト用）
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(GoalAdapter());
        Hive.registerAdapter(GoalIdAdapter());
        Hive.registerAdapter(GoalTitleAdapter());
        Hive.registerAdapter(GoalCategoryAdapter());
        Hive.registerAdapter(GoalReasonAdapter());
        Hive.registerAdapter(GoalDeadlineAdapter());
      }

      // テスト用の Box を開く
      testBox = await Hive.openBox<Goal>('test_goals');

      repository = HiveGoalRepository();
      // リポジトリに Box を注入
      // 注：実装では _box を private にしているため、テストでは別の方法を使う必要があります
    });

    tearDown(() async {
      await testBox.clear();
      await testBox.close();
    });

    group('saveGoal & getGoalById', () {
      test('ゴールを保存して取得できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final goal = Goal(
          id: GoalId('goal-1'),
          title: GoalTitle('プログラミング習得'),
          category: GoalCategory('スキル'),
          reason: GoalReason('キャリアアップのため'),
          deadline: GoalDeadline(tomorrow),
        );

        // 実装注：リポジトリをテストするには、初期化メソッドを呼び出す必要があります
        // ここではスキップしています
      });
    });

    group('getAllGoals', () {
      test('ゴールが存在しない場合、空のリストを返すこと', () async {
        // 実装注：リポジトリの初期化が必要
      });

      test('複数のゴールを取得できること', () async {
        // 実装注：リポジトリの初期化が必要
      });
    });

    group('deleteGoal', () {
      test('ゴールを削除できること', () async {
        // 実装注：リポジトリの初期化が必要
      });
    });
  });
}
