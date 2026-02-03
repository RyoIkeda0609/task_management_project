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

        final milestone = await useCase.call(
          title: 'フロントエンド構築',
          deadline: tomorrow,
        );

        expect(milestone.title.value, 'フロントエンド構築');
        expect(milestone.deadline.value.day, tomorrow.day);
      });

      test('ID は一意に生成されること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final milestone1 = await useCase.call(
          title: 'マイルストーン1',
          deadline: tomorrow,
        );

        final milestone2 = await useCase.call(
          title: 'マイルストーン2',
          deadline: tomorrow,
        );

        expect(milestone1.id, isNot(equals(milestone2.id)));
      });

      test('無効なタイトル（101文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidTitle = 'a' * 101;

        expect(
          () => useCase.call(title: invalidTitle, deadline: tomorrow),
          throwsArgumentError,
        );
      });

      test('本日以前の期限でエラーが発生すること', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        expect(
          () => useCase.call(title: 'タイトル', deadline: yesterday),
          throwsArgumentError,
        );
      });

      test('空白のみのタイトルでエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(
          () => useCase.call(title: '   ', deadline: tomorrow),
          throwsArgumentError,
        );
      });

      test('1文字のタイトルでマイルストーンが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final milestone = await useCase.call(title: 'a', deadline: tomorrow);

        expect(milestone.title.value, 'a');
      });

      test('100文字のタイトルでマイルストーンが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxTitle = 'a' * 100;

        final milestone = await useCase.call(
          title: maxTitle,
          deadline: tomorrow,
        );

        expect(milestone.title.value, maxTitle);
      });
    });
  });
}
