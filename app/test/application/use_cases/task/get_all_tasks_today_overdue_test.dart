import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/get_all_tasks_today_use_case.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';

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

void main() {
  group('GetAllTasksTodayUseCase - 過期限タスク対応', () {
    late GetAllTasksTodayUseCase useCase;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
    });

    test('過期限タスク（昨日の期限）が含まれること', () async {
      // Arrange
      final today = DateTime(2099, 1, 15);
      final yesterdayDeadline = DateTime(2099, 1, 14, 10, 0, 0);
      final todayDeadline = DateTime(2099, 1, 15, 23, 59, 59);
      final tomorrowDeadline = DateTime(2099, 1, 16, 10, 0, 0);

      useCase = GetAllTasksTodayUseCaseImpl(
        mockRepository,
        dateTimeProvider: () => today,
      );

      final yesterdayTask = Task(
        itemId: ItemId.generate(),
        title: ItemTitle('昨日のタスク'),
        description: ItemDescription('過期限'),
        deadline: ItemDeadline(yesterdayDeadline),
        status: TaskStatus.todo(),
        milestoneId: ItemId('milestone-1'),
      );
      final todayTask = Task(
        itemId: ItemId.generate(),
        title: ItemTitle('本日のタスク'),
        description: ItemDescription('本日'),
        deadline: ItemDeadline(todayDeadline),
        status: TaskStatus.todo(),
        milestoneId: ItemId('milestone-1'),
      );
      final tomorrowTask = Task(
        itemId: ItemId.generate(),
        title: ItemTitle('明日のタスク'),
        description: ItemDescription('未来'),
        deadline: ItemDeadline(tomorrowDeadline),
        status: TaskStatus.todo(),
        milestoneId: ItemId('milestone-1'),
      );

      await mockRepository.saveTask(yesterdayTask);
      await mockRepository.saveTask(todayTask);
      await mockRepository.saveTask(tomorrowTask);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, 2); // 昨日 + 本日のみ（明日は含まない）
      expect(
        result.any((t) => t.itemId.value == yesterdayTask.itemId.value),
        true,
      );
      expect(result.any((t) => t.itemId.value == todayTask.itemId.value), true);
      expect(
        result.any((t) => t.itemId.value == tomorrowTask.itemId.value),
        false,
      );
    });

    test('複数日の過期限タスクがすべて含まれること', () async {
      // Arrange
      final today = DateTime(2099, 1, 15);
      final threeDaysAgoDeadline = DateTime(2099, 1, 12, 10, 0, 0);
      final twoDaysAgoDeadline = DateTime(2099, 1, 13, 10, 0, 0);
      final yesterdayDeadline = DateTime(2099, 1, 14, 10, 0, 0);
      final todayDeadline = DateTime(2099, 1, 15, 23, 59, 59);

      useCase = GetAllTasksTodayUseCaseImpl(
        mockRepository,
        dateTimeProvider: () => today,
      );

      final task3DaysAgo = Task(
        itemId: ItemId.generate(),
        title: ItemTitle('3日前のタスク'),
        description: ItemDescription('説明'),
        deadline: ItemDeadline(threeDaysAgoDeadline),
        status: TaskStatus.todo(),
        milestoneId: ItemId('milestone-1'),
      );
      final task2DaysAgo = Task(
        itemId: ItemId.generate(),
        title: ItemTitle('2日前のタスク'),
        description: ItemDescription('説明'),
        deadline: ItemDeadline(twoDaysAgoDeadline),
        status: TaskStatus.todo(),
        milestoneId: ItemId('milestone-1'),
      );
      final taskYesterday = Task(
        itemId: ItemId.generate(),
        title: ItemTitle('昨日のタスク'),
        description: ItemDescription('説明'),
        deadline: ItemDeadline(yesterdayDeadline),
        status: TaskStatus.todo(),
        milestoneId: ItemId('milestone-1'),
      );
      final taskToday = Task(
        itemId: ItemId.generate(),
        title: ItemTitle('本日のタスク'),
        description: ItemDescription('説明'),
        deadline: ItemDeadline(todayDeadline),
        status: TaskStatus.todo(),
        milestoneId: ItemId('milestone-1'),
      );

      await mockRepository.saveTask(task3DaysAgo);
      await mockRepository.saveTask(task2DaysAgo);
      await mockRepository.saveTask(taskYesterday);
      await mockRepository.saveTask(taskToday);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, 4);
      expect(
        result.any((t) => t.itemId.value == task3DaysAgo.itemId.value),
        true,
      );
      expect(
        result.any((t) => t.itemId.value == task2DaysAgo.itemId.value),
        true,
      );
      expect(
        result.any((t) => t.itemId.value == taskYesterday.itemId.value),
        true,
      );
      expect(result.any((t) => t.itemId.value == taskToday.itemId.value), true);
    });
  });
}
