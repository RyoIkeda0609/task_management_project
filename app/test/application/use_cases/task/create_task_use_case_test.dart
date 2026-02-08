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
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: 'API実装',
          description: 'RESTful APIの実装とテスト',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.title.value, 'API実装');
        expect(task.description.value, 'RESTful APIの実装とテスト');
        expect(task.deadline.value.day, tomorrow.day);
        expect(task.status.isTodo, true);
        expect(task.milestoneId, milestoneId);
      });

      test('ID は一意に生成されること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        final task1 = await useCase.call(
          title: 'タスク1',
          description: '説明1',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        final task2 = await useCase.call(
          title: 'タスク2',
          description: '説明2',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task1.id, isNot(equals(task2.id)));
      });

      test('作成時のステータスは常に Todo であること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: 'タイトル',
          description: '説明',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.status.isTodo, true);
        expect(task.status.isDoing, false);
        expect(task.status.isDone, false);
      });

      test('無効なタイトル（101文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidTitle = 'a' * 101;
        const milestoneId = 'milestone-123';

        expect(
          () => useCase.call(
            title: invalidTitle,
            description: '説明',
            deadline: tomorrow,
            milestoneId: milestoneId,
          ),
          throwsArgumentError,
        );
      });

      test('無効な説明（501文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidDescription = 'a' * 501;
        const milestoneId = 'milestone-123';

        expect(
          () => useCase.call(
            title: 'タイトル',
            description: invalidDescription,
            deadline: tomorrow,
            milestoneId: milestoneId,
          ),
          throwsArgumentError,
        );
      });

      test('本日以前の期限でもタスクが作成できること', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        expect(
          () => useCase.call(
            title: 'タイトル',
            description: '説明',
            deadline: yesterday,
            milestoneId: milestoneId,
          ),
          returnsNormally,
        );
      });

      test('空白のみのタイトルでエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        expect(
          () => useCase.call(
            title: '   ',
            description: '説明',
            deadline: tomorrow,
            milestoneId: milestoneId,
          ),
          throwsArgumentError,
        );
      });

      test('空白のみの説明でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        expect(
          () => useCase.call(
            title: 'タイトル',
            description: '   ',
            deadline: tomorrow,
            milestoneId: milestoneId,
          ),
          throwsArgumentError,
        );
      });

      test('空の milestoneId でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(
          () => useCase.call(
            title: 'タイトル',
            description: '説明',
            deadline: tomorrow,
            milestoneId: '',
          ),
          throwsArgumentError,
        );
      });

      test('1文字のタイトルでタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: 'a',
          description: '説明',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.title.value, 'a');
      });

      test('100文字のタイトルでタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxTitle = 'a' * 100;
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: maxTitle,
          description: '説明',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.title.value, maxTitle);
      });

      test('1文字の説明でタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: 'タイトル',
          description: 'a',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.description.value, 'a');
      });

      test('500文字の説明でタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxDescription = 'a' * 500;
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: 'タイトル',
          description: maxDescription,
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.description.value, maxDescription);
      });
    });
  });
}
