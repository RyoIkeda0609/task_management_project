import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/update_task_use_case.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/services/task_completion_service.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

class MockTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAllTasks() async => _tasks;

  @override
  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.itemId.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async =>
      _tasks.where((t) => t.milestoneId.value == milestoneId).toList();

  @override
  Future<void> saveTask(Task task) async {
    _tasks.removeWhere((t) => t.itemId.value == task.itemId.value);
    _tasks.add(task);
  }

  @override
  Future<void> deleteTask(String id) async =>
      _tasks.removeWhere((t) => t.itemId.value == id);

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async =>
      _tasks.removeWhere((t) => t.milestoneId.value == milestoneId);

  @override
  Future<int> getTaskCount() async => _tasks.length;
}

class MockTaskCompletionService implements TaskCompletionService {
  @override
  Future<bool> isTaskCompleted(String taskId) async {
    // For testing: by default, no task is marked as completed
    return false;
  }
}

void main() {
  group('UpdateTaskUseCase', () {
    late UpdateTaskUseCase useCase;
    late MockTaskRepository mockRepository;
    late MockTaskCompletionService mockCompletionService;

    setUp(() {
      mockRepository = MockTaskRepository();
      mockCompletionService = MockTaskCompletionService();
      useCase = UpdateTaskUseCaseImpl(mockRepository, mockCompletionService);
    });

    group('タスク更新', () {
      test('タスクを更新できること', () async {
        // Arrange
        final original = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('元のタイトル'),
          description: ItemDescription('元の説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-1'),
        );
        await mockRepository.saveTask(original);

        final newDeadline = DateTime.now().add(const Duration(days: 14));

        // Act
        final updated = await useCase(
          taskId: original.itemId.value,
          title: '新しいタイトル',
          description: '新しい説明',
          deadline: newDeadline,
        );

        // Assert
        expect(updated.title.value, '新しいタイトル');
        expect(updated.description.value, '新しい説明');
        expect(updated.deadline.value.day, newDeadline.day);
        expect(updated.itemId.value, original.itemId.value);
        expect(updated.status.isTodo, true); // ステータスは保護される
      });

      test('タスクのタイトルのみを更新できること', () async {
        // Arrange
        final original = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('元のタイトル'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-1'),
        );
        await mockRepository.saveTask(original);

        // Act
        final updated = await useCase(
          taskId: original.itemId.value,
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
          itemId: ItemId.generate(),
          title: ItemTitle('タイトル'),
          description: ItemDescription('元の説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-1'),
        );
        await mockRepository.saveTask(original);

        // Act
        final updated = await useCase(
          taskId: original.itemId.value,
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
          itemId: ItemId.generate(),
          title: ItemTitle('タイトル'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-1'),
        );
        await mockRepository.saveTask(original);

        final newDeadline = DateTime.now().add(const Duration(days: 14));

        // Act
        final updated = await useCase(
          taskId: original.itemId.value,
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
          itemId: ItemId.generate(),
          title: ItemTitle('タイトル'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.doing,
          milestoneId: ItemId('milestone-1'),
        );
        await mockRepository.saveTask(original);

        // Act
        final updated = await useCase(
          taskId: original.itemId.value,
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
          itemId: ItemId.generate(),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明1'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-1'),
        );
        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク2'),
          description: ItemDescription('説明2'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 14))),
          status: TaskStatus.doing,
          milestoneId: ItemId('milestone-1'),
        );
        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);

        // Act
        await useCase(
          taskId: task1.itemId.value,
          title: '更新後のタスク1',
          description: task1.description.value,
          deadline: task1.deadline.value,
        );

        // Assert
        final unchanged = await mockRepository.getTaskById(task2.itemId.value);
        expect(unchanged?.title.value, 'タスク2');
      });
    });

    group('入力値検証', () {
      test('無効なタイトル（空文字）で更新がエラーになること', () async {
        // Arrange
        final task = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タイトル'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-1'),
        );
        await mockRepository.saveTask(task);

        // Act & Assert
        expect(
          () async => await useCase(
            taskId: task.itemId.value,
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
          itemId: ItemId.generate(),
          title: ItemTitle('タイトル'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-1'),
        );
        await mockRepository.saveTask(task);

        // Act & Assert
        expect(
          () async => await useCase(
            taskId: task.itemId.value,
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
          itemId: ItemId.generate(),
          title: ItemTitle('タイトル'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-1'),
        );
        await mockRepository.saveTask(task);

        // Act & Assert
        expect(
          () async => await useCase(
            taskId: task.itemId.value,
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
          itemId: ItemId.generate(),
          title: ItemTitle('タイトル'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(DateTime.now().add(const Duration(days: 7))),
          status: TaskStatus.todo,
          milestoneId: ItemId('milestone-123'),
        );
        await mockRepository.saveTask(task);

        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        expect(
          () async => await useCase(
            taskId: task.itemId.value,
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
