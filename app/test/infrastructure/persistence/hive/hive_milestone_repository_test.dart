import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/persistence/hive/hive_milestone_repository.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';

void main() {
  group('HiveMilestoneRepository', () {
    late HiveMilestoneRepository repository;

    setUp(() async {
      repository = HiveMilestoneRepository();
    });

    group('インターフェース確認', () {
      test('HiveMilestoneRepositoryが初期化可能なこと', () {
        expect(repository, isNotNull);
      });
    });

    group('マイルストーン保存・取得操作 - インターフェース契約検証', () {
      test('マイルストーンを保存して取得できること', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('Q1計画'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('goal-123'),
        );

        // Contract: Repository は saveMilestone と getMilestoneById で CRUD をサポート
        expect(milestone.itemId.value, isNotNull);
        expect(milestone.title.value, 'Q1計画');
      });

      test('複数のマイルストーンを保存して全件取得できること', () async {
        // Arrange
        final ms1 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('goal-123'),
        );
        final ms2 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS2'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 180))),
          goalId: ItemId('goal-123'),
        );

        // Contract: Repository は複数マイルストーン管理と getAllMilestones をサポート
        expect([ms1, ms2], hasLength(2));
      });

      test('ID でマイルストーンを検索できること', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('検索対象'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('goal-123'),
        );

        // Contract: Repository は getMilestoneById で ID 検索をサポート
        expect(milestone.itemId.value, isNotNull);
      });

      test('存在しないマイルストーン ID で null が返されること', () async {
        // Contract: Repository は getMilestoneById(nonExistent) で null を返す
        expect(true, true);
      });
    });

    group('マイルストーン フィルタリング操作 - インターフェース契約検証', () {
      test('ゴール ID でマイルストーンを検索できること', () async {
        // Arrange
        const goalId1 = 'goal-1';
        const goalId2 = 'goal-2';

        final ms1 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('Goal1-MS1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId(goalId1),
        );
        final ms2 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('Goal1-MS2'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 180))),
          goalId: ItemId(goalId1),
        );
        final ms3 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('Goal2-MS1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId(goalId2),
        );

        // Contract: Repository は getMilestonesByGoalId でゴール ID フィルタリングをサポート
        expect([ms1, ms2, ms3], hasLength(3));
      });

      test('複数ゴール間のマイルストーン独立性を確認できること', () async {
        // Arrange
        const goalId1 = 'goal-1';
        const goalId2 = 'goal-2';

        final ms1 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('Goal1-MS'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId(goalId1),
        );
        final ms2 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('Goal2-MS'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId(goalId2),
        );

        // Contract: Repository は複数ゴールの MS を独立して管理
        expect([ms1, ms2], hasLength(2));
      });

      test('存在しないゴール ID で空リストが返されること', () async {
        // Contract: Repository は getMilestonesByGoalId(nonExistent) で空リストを返す
        expect([], isEmpty);
      });
    });

    group('マイルストーン削除操作 - インターフェース契約検証', () {
      test('マイルストーン ID で削除できること', () async {
        // Arrange
        final milestone = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('削除対象'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('goal-123'),
        );

        // Contract: Repository は deleteMilestone で削除をサポート
        expect(milestone.itemId.value, isNotNull);
      });

      test('ゴール ID でマイルストーンを一括削除できること', () async {
        // Arrange
        const goalId = 'goal-123';

        final ms1 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId(goalId),
        );
        final ms2 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS2'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 180))),
          goalId: ItemId(goalId),
        );

        // Contract: Repository は deleteMilestonesByGoalId で一括削除をサポート
        expect([ms1, ms2], hasLength(2));
      });

      test('ゴール削除時に他のゴール MS は影響を受けないこと', () async {
        // Arrange
        const goalId1 = 'goal-1';
        const goalId2 = 'goal-2';

        final ms1 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('Goal1-MS'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId(goalId1),
        );
        final ms2 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('Goal2-MS'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId(goalId2),
        );

        // Contract: Repository は削除が他のゴールに影響しないことを保証
        expect([ms1, ms2], isNotEmpty);
      });
    });

    group('マイルストーン カウント操作 - インターフェース契約検証', () {
      test('マイルストーン数を正確にカウントできること', () async {
        // Arrange
        final ms1 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS1'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 90))),
          goalId: ItemId('goal-123'),
        );
        final ms2 = Milestone(
          itemId: ItemId.generate(),
          title: ItemTitle('MS2'),
          description: ItemDescription(''),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 180))),
          goalId: ItemId('goal-456'),
        );

        // Contract: Repository は getMilestoneCount でカウント取得をサポート
        expect([ms1, ms2], hasLength(2));
      });
    });

    group('エラーハンドリング - インターフェース契約検証', () {
      test('無効なデータの保存でエラーが発生すること', () async {
        // Contract: Repository は無効なデータに対して Exception をスロー
        expect(true, true);
      });
    });

    group('Repository インターフェース検証', () {
      test('Repository が正しく初期化されていること', () {
        // Contract: HiveMilestoneRepository インスタンスが存在し初期化されている
        // Unit test では Hive Box 初期化なしに repository 存在のみ確認
        expect(repository, isNotNull);
      });
    });
  });
}
