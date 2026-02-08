import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/milestone/create_milestone_use_case.dart';

void main() {
  group('CreateMilestoneUseCase', () {
    late CreateMilestoneUseCase useCase;

    setUp(() {
      useCase = CreateMilestoneUseCaseImpl();
    });

    group('実行', () {
      test('有効な入力でマイルストーンが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const goalId = 'goal-123';

        final milestone = await useCase.call(
          title: 'フロントエンド構築',
          deadline: tomorrow,
          goalId: goalId,
        );

        expect(milestone.title.value, 'フロントエンド構築');
        expect(milestone.deadline.value.day, tomorrow.day);
        expect(milestone.goalId, goalId);
      });

      test('ID は一意に生成されること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const goalId = 'goal-123';

        final milestone1 = await useCase.call(
          title: 'マイルストーン1',
          deadline: tomorrow,
          goalId: goalId,
        );

        final milestone2 = await useCase.call(
          title: 'マイルストーン2',
          deadline: tomorrow,
          goalId: goalId,
        );

        expect(milestone1.id, isNot(equals(milestone2.id)));
      });

      test('無効なタイトル（101文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidTitle = 'a' * 101;
        const goalId = 'goal-123';

        expect(
          () => useCase.call(
            title: invalidTitle,
            deadline: tomorrow,
            goalId: goalId,
          ),
          throwsArgumentError,
        );
      });

      test('本日以前の期限でもマイルストーンが作成できること', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        const goalId = 'goal-123';

        expect(
          () =>
              useCase.call(title: 'タイトル', deadline: yesterday, goalId: goalId),
          returnsNormally,
        );
      });

      test('空白のみのタイトルでエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const goalId = 'goal-123';

        expect(
          () => useCase.call(title: '   ', deadline: tomorrow, goalId: goalId),
          throwsArgumentError,
        );
      });

      test('空の goalId でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(
          () => useCase.call(title: 'タイトル', deadline: tomorrow, goalId: ''),
          throwsArgumentError,
        );
      });

      test('1文字のタイトルでマイルストーンが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const goalId = 'goal-123';

        final milestone = await useCase.call(
          title: 'a',
          deadline: tomorrow,
          goalId: goalId,
        );

        expect(milestone.title.value, 'a');
      });

      test('100文字のタイトルでマイルストーンが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxTitle = 'a' * 100;
        const goalId = 'goal-123';

        final milestone = await useCase.call(
          title: maxTitle,
          deadline: tomorrow,
          goalId: goalId,
        );

        expect(milestone.title.value, maxTitle);
      });
    });
  });
}
