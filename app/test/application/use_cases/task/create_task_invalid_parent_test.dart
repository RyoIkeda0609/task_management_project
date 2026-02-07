import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/create_task_use_case.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/entities/task.dart';

void main() {
  group('CreateTaskUseCase - 不正な親への追加テスト', () {
    late CreateTaskUseCase useCase;

    setUp(() {
      useCase = CreateTaskUseCaseImpl();
    });

    test('タスクは ValueObject バリデーションで作成できる', () async {
      final task = await useCase.call(
        title: TaskTitle('テストタスク'),
        deadline: TaskDeadline(DateTime(2026, 12, 31)),
        milestoneId: 'milestone-1',
      );

      expect(task.title.value, 'テストタスク');
      expect(task.milestoneId, 'milestone-1');
      expect(task.status, TaskStatus.notStarted);
    });

    test('空のマイルストーンIDでタスクを作成しようとするとエラー', () async {
      expect(
        () async => await useCase.call(
          title: TaskTitle('タスク'),
          deadline: TaskDeadline(DateTime(2026, 12, 31)),
          milestoneId: '',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('期限が本日より前の日付はエラー', () async {
      expect(
        () async => await useCase.call(
          title: TaskTitle('タスク'),
          deadline: TaskDeadline(DateTime(2020, 1, 1)),
          milestoneId: 'milestone-1',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('タスク作成時、デフォルトのステータスは notStarted', () async {
      final task = await useCase.call(
        title: TaskTitle('新規タスク'),
        deadline: TaskDeadline(DateTime(2026, 12, 31)),
        milestoneId: 'milestone-1',
      );

      expect(task.status, TaskStatus.notStarted);
    });
  });
}
