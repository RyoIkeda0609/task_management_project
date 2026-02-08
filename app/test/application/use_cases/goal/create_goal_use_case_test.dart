import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/goal/create_goal_use_case.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';

class MockGoalRepository implements GoalRepository {
  final List<Goal> _goals = [];

  @override
  Future<List<Goal>> getAllGoals() async => _goals;

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      return _goals.firstWhere((g) => g.id.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveGoal(Goal goal) async => _goals.add(goal);

  @override
  Future<void> deleteGoal(String id) async =>
      _goals.removeWhere((g) => g.id.value == id);

  @override
  Future<void> deleteAllGoals() async => _goals.clear();

  @override
  Future<int> getGoalCount() async => _goals.length;
}

void main() {
  group('CreateGoalUseCase', () {
    late CreateGoalUseCase useCase;
    late MockGoalRepository mockRepository;

    setUp(() {
      mockRepository = MockGoalRepository();
      useCase = CreateGoalUseCaseImpl(mockRepository);
    });

    group('実行', () {
      test('有効な入力でゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal = await useCase.call(
          title: 'フロントエンドスキル習得',
          category: 'スキル開発',
          reason: 'キャリアアップのため',
          deadline: tomorrow,
        );

        expect(goal.title.value, 'フロントエンドスキル習得');
        expect(goal.category.value, 'スキル開発');
        expect(goal.reason.value, 'キャリアアップのため');
        expect(goal.deadline.value.day, tomorrow.day);
      });

      test('ゴールを作成したら Repository に保存されること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal = await useCase.call(
          title: 'テストゴール',
          category: 'テスト',
          reason: 'テスト理由',
          deadline: tomorrow,
        );

        // Repository に保存されたかを確認
        final savedGoal = await mockRepository.getGoalById(goal.id.value);
        expect(savedGoal, isNotNull);
        expect(savedGoal!.title.value, 'テストゴール');
      });

      test('ID は一意に生成されること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal1 = await useCase.call(
          title: 'ゴール1',
          category: 'カテゴリ1',
          reason: '理由1',
          deadline: tomorrow,
        );

        final goal2 = await useCase.call(
          title: 'ゴール2',
          category: 'カテゴリ2',
          reason: '理由2',
          deadline: tomorrow,
        );

        expect(goal1.id, isNot(equals(goal2.id)));
      });

      test('無効なタイトル（101文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidTitle = 'a' * 101;

        expect(
          () => useCase.call(
            title: invalidTitle,
            category: 'カテゴリ',
            reason: '理由',
            deadline: tomorrow,
          ),
          throwsArgumentError,
        );
      });

      test('無効なカテゴリ（101文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidCategory = 'a' * 101;

        expect(
          () => useCase.call(
            title: 'タイトル',
            category: invalidCategory,
            reason: '理由',
            deadline: tomorrow,
          ),
          throwsArgumentError,
        );
      });

      test('無効な理由（101文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidReason = 'a' * 101;

        expect(
          () => useCase.call(
            title: 'タイトル',
            category: 'カテゴリ',
            reason: invalidReason,
            deadline: tomorrow,
          ),
          throwsArgumentError,
        );
      });

      test('本日以前の期限でもゴールが作成できること', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        expect(
          () => useCase.call(
            title: 'タイトル',
            category: 'カテゴリ',
            reason: '理由',
            deadline: yesterday,
          ),
          returnsNormally,
        );
      });

      test('空白のみのタイトルでエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(
          () => useCase.call(
            title: '   ',
            category: 'カテゴリ',
            reason: '理由',
            deadline: tomorrow,
          ),
          throwsArgumentError,
        );
      });

      test('空白のみのカテゴリでエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(
          () => useCase.call(
            title: 'タイトル',
            category: '   ',
            reason: '理由',
            deadline: tomorrow,
          ),
          throwsArgumentError,
        );
      });

      test('空白のみの理由でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(
          () => useCase.call(
            title: 'タイトル',
            category: 'カテゴリ',
            reason: '   ',
            deadline: tomorrow,
          ),
          throwsArgumentError,
        );
      });

      test('1文字のタイトルでゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal = await useCase.call(
          title: 'a',
          category: 'カテゴリ',
          reason: '理由',
          deadline: tomorrow,
        );

        expect(goal.title.value, 'a');
      });

      test('100文字のタイトルでゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxTitle = 'a' * 100;

        final goal = await useCase.call(
          title: maxTitle,
          category: 'カテゴリ',
          reason: '理由',
          deadline: tomorrow,
        );

        expect(goal.title.value, maxTitle);
      });

      test('1文字のカテゴリでゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal = await useCase.call(
          title: 'タイトル',
          category: 'a',
          reason: '理由',
          deadline: tomorrow,
        );

        expect(goal.category.value, 'a');
      });

      test('100文字のカテゴリでゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxCategory = 'a' * 100;

        final goal = await useCase.call(
          title: 'タイトル',
          category: maxCategory,
          reason: '理由',
          deadline: tomorrow,
        );

        expect(goal.category.value, maxCategory);
      });

      test('1文字の理由でゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal = await useCase.call(
          title: 'タイトル',
          category: 'カテゴリ',
          reason: 'a',
          deadline: tomorrow,
        );

        expect(goal.reason.value, 'a');
      });

      test('100文字の理由でゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxReason = 'a' * 100;

        final goal = await useCase.call(
          title: 'タイトル',
          category: 'カテゴリ',
          reason: maxReason,
          deadline: tomorrow,
        );

        expect(goal.reason.value, maxReason);
      });

      test('明日の期限でゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal = await useCase.call(
          title: 'タイトル',
          category: 'カテゴリ',
          reason: '理由',
          deadline: tomorrow,
        );

        expect(goal.deadline.value.day, tomorrow.day);
      });

      test('1年後の期限でゴールが作成できること', () async {
        final nextYear = DateTime.now().add(const Duration(days: 365));

        final goal = await useCase.call(
          title: 'タイトル',
          category: 'カテゴリ',
          reason: '理由',
          deadline: nextYear,
        );

        expect(goal.deadline.value.year, nextYear.year);
      });
    });
  });
}
