import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/update_task_use_case.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
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
  Future<void> saveTask(Task task) async {
    _tasks.removeWhere((t) => t.id.value == task.id.value);
    _tasks.add(task);
  }

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
  group('UpdateTaskUseCase', () {
    late UpdateTaskUseCase useCase;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
      useCase = UpdateTaskUseCaseImpl(mockRepository);
    });

    group('タスク更新', () {
      test('タスクを更新できること', () async {
        // Arrange
        final original = Task(
          id: TaskId.generate(),
          title: TaskTitle('元のタイトル'),
          description: TaskDescription('元の説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(original);

        final newDeadline = DateTime.now().add(const Duration(days: 14));

        // Act
        final updated = await useCase(
          taskId: original.id.value,
          title: '新しいタイトル',
          description: '新しい説明',
          deadline: newDeadline,
        );

        // Assert
        expect(updated.title.value, '新しいタイトル');
        expect(updated.description.value, '新しい説明');
        expect(updated.deadline.value.day, newDeadline.day);
        expect(updated.id.value, original.id.value);
        expect(updated.status.isTodo, true); // ステータスは保護される
      });

      test('タスクのタイトルのみを更新できること', () async {
        // Arrange
        final original = Task(
          id: TaskId.generate(),
          title: TaskTitle('元のタイトル'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(original);

        // Act
        final updated = await useCase(
          taskId: original.id.value,
          title: '更新後のタイトル',
          description: original.description.value,
          deadline: original.deadline.value,
        );

        // Assert
        expect(updated.title.value, '更新後のタイトル');
        expect(updated.description.value, original.description.value);
      });

      test('タスクの説明のみを更新できること', () async {
        // Arrange
        final original = Task(
          id: TaskId.generate(),
          title: TaskTitle('タイトル'),
          description: TaskDescription('元の説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(original);

        // Act
        final updated = await useCase(
          taskId: original.id.value,
          title: original.title.value,
          description: '新しい説明',
          deadline: original.deadline.value,
        );

        // Assert
        expect(updated.description.value, '新しい説明');
      });

      test('タスクのデッドラインのみを更新できること', () async {
        // Arrange
        final original = Task(
          id: TaskId.generate(),
          title: TaskTitle('タイトル'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(original);

        final newDeadline = DateTime.now().add(const Duration(days: 14));

        // Act
        final updated = await useCase(
          taskId: original.id.value,
          title: original.title.value,
          description: original.description.value,
          deadline: newDeadline,
        );

        // Assert
        expect(updated.deadline.value.day, newDeadline.day);
      });

      test('タスクのステータスは保護されて更新されないこと', () async {
        // Arrange
        final original = Task(
          id: TaskId.generate(),
          title: TaskTitle('タイトル'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.doing(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(original);

        // Act
        final updated = await useCase(
          taskId: original.id.value,
          title: 'タイトル更新',
          description: '説明更新',
          deadline: original.deadline.value,
        );

        // Assert
        expect(updated.status.isDoing, true); // ステータスは変更されない
      });

      test('複数タスクの更新が独立していること', () async {
        // Arrange
        final task1 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明1'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明2'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 14))),
          status: TaskStatus.doing(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);

        // Act
        await useCase(
          taskId: task1.id.value,
          title: '更新後のタスク1',
          description: task1.description.value,
          deadline: task1.deadline.value,
        );

        // Assert
        final unchanged = await mockRepository.getTaskById(task2.id.value);
        expect(unchanged?.title.value, 'タスク2');
      });
    });

    group('入力値検証', () {
      test('無効なタイトル（空文字）で更新がエラーになること', () async {
        // Arrange
        final task = Task(
          id: TaskId.generate(),
          title: TaskTitle('タイトル'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(task);

        // Act & Assert
        expect(
          () async => await useCase(
            taskId: task.id.value,
            title: '',
            description: task.description.value,
            deadline: task.deadline.value,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('タイトルが100文字を超える場合はエラーになること', () async {
        // Arrange
        final task = Task(
          id: TaskId.generate(),
          title: TaskTitle('タイトル'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(task);

        // Act & Assert
        expect(
          () async => await useCase(
            taskId: task.id.value,
            title: 'a' * 101,
            description: task.description.value,
            deadline: task.deadline.value,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('説明が500文字を超える場合はエラーになること', () async {
        // Arrange
        final task = Task(
          id: TaskId.generate(),
          title: TaskTitle('タイトル'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(task);

        // Act & Assert
        expect(
          () async => await useCase(
            taskId: task.id.value,
            title: task.title.value,
            description: 'a' * 501,
            deadline: task.deadline.value,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('デッドラインが過去の日付でも更新できること', () async {
        // Arrange
        final task = Task(
          id: TaskId.generate(),
          title: TaskTitle('タイトル'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        await mockRepository.saveTask(task);

        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        expect(
          () async => await useCase(
            taskId: task.id.value,
            title: task.title.value,
            description: task.description.value,
            deadline: yesterday,
          ),
          returnsNormally,
        );
      });
    });

    group('エラーハンドリング', () {
      test('存在しないタスク ID での更新でエラーが発生すること', () async {
        // Act & Assert
        expect(
          () async => await useCase(
            taskId: 'non-existent-id',
            title: 'タイトル',
            description: '説明',
            deadline: DateTime.now().add(const Duration(days: 7)),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('空のタスク ID でエラーが発生すること', () async {
        // Act & Assert
        expect(
          () async => await useCase(
            taskId: '',
            title: 'タイトル',
            description: '説明',
            deadline: DateTime.now().add(const Duration(days: 7)),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
