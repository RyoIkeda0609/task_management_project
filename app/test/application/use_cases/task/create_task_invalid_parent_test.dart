import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/create_task_use_case.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

void main() {
  group('CreateTaskUseCase - 不正な親への追加テスト', () {
    late CreateTaskUseCase useCase;

    setUp(() {
      useCase = CreateTaskUseCaseImpl();
    });

    test('タスクは ValueObject バリデーションで作成できる', () async {
      final task = await useCase.call(
        title: 'テストタスク',
        description: 'テストタスクの説明',
        deadline: DateTime(2026, 12, 31),
        milestoneId: 'milestone-1',
      );

      expect(task.title.value, 'テストタスク');
      expect(task.description.value, 'テストタスクの説明');
      expect(task.milestoneId, 'milestone-1');
      expect(task.status.value, TaskStatus.statusTodo);
    });

    test('空のマイルストーンIDでタスクを作成しようとするとエラー', () async {
      expect(
        () async => await useCase.call(
          title: 'タスク',
          description: 'タスクの説明',
          deadline: DateTime(2026, 12, 31),
          milestoneId: '',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('期限が本日より前の日付でもタスクが作成できること', () async {
      expect(
        () async => await useCase.call(
          title: 'タスク',
          description: 'タスクの説明',
          deadline: DateTime(2020, 1, 1),
          milestoneId: 'milestone-1',
        ),
        returnsNormally,
      );
    });

    test('タスク作成時、デフォルトのステータスは todo', () async {
      final task = await useCase.call(
        title: '新規タスク',
        description: '新規タスクの説明',
        deadline: DateTime(2026, 12, 31),
        milestoneId: 'milestone-1',
      );

      expect(task.status.value, TaskStatus.statusTodo);
    });
  });
}
