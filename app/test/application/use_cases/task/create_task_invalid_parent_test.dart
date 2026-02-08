import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/create_task_use_case.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

class MockTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAllTasks() async => _tasks;

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.id.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async =>
      _tasks.where((t) => t.milestoneId == milestoneId).toList();

  @override
  Future<void> saveTask(Task task) async => _tasks.add(task);

  @override
  Future<void> deleteTask(String id) async =>
      _tasks.removeWhere((t) => t.id.value == id);

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async =>
      _tasks.removeWhere((t) => t.milestoneId == milestoneId);

  @override
  Future<int> getTaskCount() async => _tasks.length;
}

void main() {
  group('CreateTaskUseCase - 不正な親への追加テスト', () {
    late CreateTaskUseCase useCase;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
      useCase = CreateTaskUseCaseImpl(mockRepository);
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
