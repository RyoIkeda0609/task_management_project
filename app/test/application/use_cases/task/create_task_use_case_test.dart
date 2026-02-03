import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/create_task_use_case.dart';

void main() {
  group('CreateTaskUseCase', () {
    late CreateTaskUseCase useCase;

    setUp(() {
      useCase = CreateTaskUseCaseImpl();
    });

    group('実行', () {
      test('有効な入力でタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final task = await useCase.call(
          title: 'API実装',
          description: 'RESTful APIの実装とテスト',
          deadline: tomorrow,
        );

        expect(task.title.value, 'API実装');
        expect(task.description.value, 'RESTful APIの実装とテスト');
        expect(task.deadline.value.day, tomorrow.day);
        expect(task.status.isTodo, true);
      });

      test('ID は一意に生成されること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final task1 = await useCase.call(
          title: 'タスク1',
          description: '説明1',
          deadline: tomorrow,
        );

        final task2 = await useCase.call(
          title: 'タスク2',
          description: '説明2',
          deadline: tomorrow,
        );

        expect(task1.id, isNot(equals(task2.id)));
      });

      test('作成時のステータスは常に Todo であること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final task = await useCase.call(
          title: 'タイトル',
          description: '説明',
          deadline: tomorrow,
        );

        expect(task.status.isTodo, true);
        expect(task.status.isDoing, false);
        expect(task.status.isDone, false);
      });

      test('無効なタイトル（101文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidTitle = 'a' * 101;

        expect(
          () => useCase.call(
            title: invalidTitle,
            description: '説明',
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
            description: invalidDescription,
            deadline: tomorrow,
          ),
          throwsArgumentError,
        );
      });

      test('本日以前の期限でエラーが発生すること', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        expect(
          () => useCase.call(
            title: 'タイトル',
            description: '説明',
            deadline: yesterday,
          ),
          throwsArgumentError,
        );
      });

      test('空白のみのタイトルでエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(
          () =>
              useCase.call(title: '   ', description: '説明', deadline: tomorrow),
          throwsArgumentError,
        );
      });

      test('空白のみの説明でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(
          () => useCase.call(
            title: 'タイトル',
            description: '   ',
            deadline: tomorrow,
          ),
          throwsArgumentError,
        );
      });

      test('1文字のタイトルでタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final task = await useCase.call(
          title: 'a',
          description: '説明',
          deadline: tomorrow,
        );

        expect(task.title.value, 'a');
      });

      test('100文字のタイトルでタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxTitle = 'a' * 100;

        final task = await useCase.call(
          title: maxTitle,
          description: '説明',
          deadline: tomorrow,
        );

        expect(task.title.value, maxTitle);
      });

      test('1文字の説明でタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        final task = await useCase.call(
          title: 'タイトル',
          description: 'a',
          deadline: tomorrow,
        );

        expect(task.description.value, 'a');
      });

      test('500文字の説明でタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxDescription = 'a' * 500;

        final task = await useCase.call(
          title: 'タイトル',
          description: maxDescription,
          deadline: tomorrow,
        );

        expect(task.description.value, maxDescription);
      });
    });
  });
}
