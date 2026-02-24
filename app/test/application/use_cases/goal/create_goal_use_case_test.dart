import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/goal/create_goal_use_case.dart';
import '../../../helpers/mock_repositories.dart';

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
          description: 'キャリアアップのため',
          deadline: tomorrow,
        );

        expect(goal.title.value, 'フロントエンドスキル習得');
        expect(goal.category.value, 'スキル開発');
        expect(goal.description.value, 'キャリアアップのため');
        expect(goal.deadline.value.day, tomorrow.day);
      });

      test('ゴールを作成したら Repository に保存されること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal = await useCase.call(
          title: 'テストゴール',
          category: 'テスト',
          description: 'テスト理由',
          deadline: tomorrow,
        );

        // Repository に保存されたかを確認
        final savedGoal = await mockRepository.getGoalById(goal.itemId.value);
        expect(savedGoal, isNotNull);
        expect(savedGoal!.title.value, 'テストゴール');
      });

      test('ID は一意に生成されること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal1 = await useCase.call(
          title: 'ゴール1',
          category: 'カテゴリ1',
          description: '理由1',
          deadline: tomorrow,
        );

        final goal2 = await useCase.call(
          title: 'ゴール2',
          category: 'カテゴリ2',
          description: '理由2',
          deadline: tomorrow,
        );

        expect(goal1.itemId, isNot(equals(goal2.itemId)));
      });

      test('無効なタイトル（101文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidTitle = 'a' * 101;

        expect(
          () => useCase.call(
            title: invalidTitle,
            category: 'カテゴリ',
            description: '理由',
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
            description: '理由',
            deadline: tomorrow,
          ),
          throwsArgumentError,
        );
      });

      test('無効な説明（501文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidDescription = 'a' * 501;

        expect(
          () => useCase.call(
            title: 'タイトル',
            category: 'カテゴリ',
            description: invalidDescription,
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
            description: '理由',
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
            description: '理由',
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
            description: '理由',
            deadline: tomorrow,
          ),
          throwsArgumentError,
        );
      });

      test('空白のみの説明でもゴールが作成できること（ItemDescriptionは空白を許可）', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(
          () => useCase.call(
            title: 'タイトル',
            category: 'カテゴリ',
            description: '   ',
            deadline: tomorrow,
          ),
          returnsNormally,
        );
      });

      test('1文字のタイトルでゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal = await useCase.call(
          title: 'a',
          category: 'カテゴリ',
          description: '理由',
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
          description: '理由',
          deadline: tomorrow,
        );

        expect(goal.title.value, maxTitle);
      });

      test('1文字のカテゴリでゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal = await useCase.call(
          title: 'タイトル',
          category: 'a',
          description: '理由',
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
          description: '理由',
          deadline: tomorrow,
        );

        expect(goal.category.value, maxCategory);
      });

      test('1文字の説明でゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal = await useCase.call(
          title: 'タイトル',
          category: 'カテゴリ',
          description: 'a',
          deadline: tomorrow,
        );

        expect(goal.description.value, 'a');
      });

      test('100文字の説明でゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxDescription = 'a' * 100;

        final goal = await useCase.call(
          title: 'タイトル',
          category: 'カテゴリ',
          description: maxDescription,
          deadline: tomorrow,
        );

        expect(goal.description.value, maxDescription);
      });

      test('明日の期限でゴールが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final goal = await useCase.call(
          title: 'タイトル',
          category: 'カテゴリ',
          description: '理由',
          deadline: tomorrow,
        );

        expect(goal.deadline.value.day, tomorrow.day);
      });

      test('1年後の期限でゴールが作成できること', () async {
        final nextYear = DateTime.now().add(const Duration(days: 365));

        final goal = await useCase.call(
          title: 'タイトル',
          category: 'カテゴリ',
          description: '理由',
          deadline: nextYear,
        );

        expect(goal.deadline.value.year, nextYear.year);
      });
    });
  });
}
