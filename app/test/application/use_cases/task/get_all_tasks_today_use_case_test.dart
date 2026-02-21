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
  group('GetAllTasksTodayUseCase', () {
    late GetAllTasksTodayUseCase useCase;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
    });

    group('本日のタスク取得', () {
      test('本日のデッドラインを持つタスクを取得できること', () async {
        // Arrange
        // テスト用の基準日を設定（2099年1月15日）
        final today = DateTime(2099, 1, 15);
        // 本日のタスク用の期限：同じ日付（時間は任意）
        final todayDeadline = DateTime(2099, 1, 15, 23, 59, 59);
        // 他の日付のタスク用の期限
        final otherDayDeadline = DateTime(2099, 1, 16, 23, 59, 59);

        useCase = GetAllTasksTodayUseCaseImpl(
          mockRepository,
          dateTimeProvider: () => today,
        );

        final todayTask = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('本日タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(todayDeadline),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );
        final otherDayTask = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('明日タスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(otherDayDeadline),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );

        await mockRepository.saveTask(todayTask);
        await mockRepository.saveTask(otherDayTask);

        // Act
        final result = await useCase();

        // Assert
        expect(result.length, 1);
        expect(result.first.itemId.value, todayTask.itemId.value);
      });

      test('複数の本日タスクをすべて取得できること', () async {
        // Arrange
        final today = DateTime(2099, 1, 15);
        final todayDeadline = DateTime(2099, 1, 15, 23, 59, 59);
        final tomorrowDeadline = DateTime(2099, 1, 16, 10, 0, 0);

        useCase = GetAllTasksTodayUseCaseImpl(
          mockRepository,
          dateTimeProvider: () => today,
        );

        final task1 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク1'),
          description: ItemDescription('説明1'),
          deadline: ItemDeadline(todayDeadline),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );
        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク2'),
          description: ItemDescription('説明2'),
          deadline: ItemDeadline(todayDeadline),
          status: TaskStatus.doing(),
          milestoneId: ItemId('milestone-1'),
        );
        final task3 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('タスク3'),
          description: ItemDescription('説明3'),
          deadline: ItemDeadline(todayDeadline),
          status: TaskStatus.done(),
          milestoneId: ItemId('milestone-1'),
        );
        final task4 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('明日のタスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrowDeadline),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );

        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);
        await mockRepository.saveTask(task3);
        await mockRepository.saveTask(task4);

        // Act
        final result = await useCase();

        // Assert
        expect(result.length, 3);
        expect(result.any((t) => t.itemId.value == task1.itemId.value), true);
        expect(result.any((t) => t.itemId.value == task2.itemId.value), true);
        expect(result.any((t) => t.itemId.value == task3.itemId.value), true);
      });

      test('本日のタスクがない場合は空のリストを返すこと', () async {
        // Arrange
        final today = DateTime(2099, 1, 15);
        final tomorrowDeadline = DateTime(2099, 1, 16, 10, 0, 0);
        final threeDaysLaterDeadline = DateTime(2099, 1, 18, 10, 0, 0);

        useCase = GetAllTasksTodayUseCaseImpl(
          mockRepository,
          dateTimeProvider: () => today,
        );

        final task1 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('明日のタスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrowDeadline),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );
        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('3日後のタスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(threeDaysLaterDeadline),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );

        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);

        // Act
        final result = await useCase();

        // Assert
        expect(result, isEmpty);
      });

      test('本日のタスクが異なるマイルストーンに属していても含まれること', () async {
        // Arrange
        final today = DateTime(2099, 1, 15);
        final todayDeadline = DateTime(2099, 1, 15, 23, 59, 59);
        final tomorrowDeadline = DateTime(2099, 1, 16, 10, 0, 0);

        useCase = GetAllTasksTodayUseCaseImpl(
          mockRepository,
          dateTimeProvider: () => today,
        );

        final task1 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('マイルストーン1のタスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(todayDeadline),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );
        final task2 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('マイルストーン2のタスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(todayDeadline),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-2'),
        );
        final task3 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('マイルストーン3のタスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(todayDeadline),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-3'),
        );
        final task4 = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('別マイルストーンの明日のタスク'),
          description: ItemDescription('説明'),
          deadline: ItemDeadline(tomorrowDeadline),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );

        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);
        await mockRepository.saveTask(task3);
        await mockRepository.saveTask(task4);

        // Act
        final result = await useCase();

        // Assert
        expect(result.length, 3);
        expect(result.any((t) => t.milestoneId.value == 'milestone-1'), true);
        expect(result.any((t) => t.milestoneId.value == 'milestone-2'), true);
        expect(result.any((t) => t.milestoneId.value == 'milestone-3'), true);
      });

      test('複数ステータスのタスクがすべて含まれること', () async {
        // Arrange
        final today = DateTime(2099, 1, 15);
        final todayDeadline = DateTime(2099, 1, 15, 14, 30, 0);

        useCase = GetAllTasksTodayUseCaseImpl(
          mockRepository,
          dateTimeProvider: () => today,
        );

        final todoTask = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('TODO タスク'),
          description: ItemDescription('まだ開始していない'),
          deadline: ItemDeadline(todayDeadline),
          status: TaskStatus.todo(),
          milestoneId: ItemId('milestone-1'),
        );
        final doingTask = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('DOING タスク'),
          description: ItemDescription('進行中'),
          deadline: ItemDeadline(todayDeadline),
          status: TaskStatus.doing(),
          milestoneId: ItemId('milestone-1'),
        );
        final doneTask = Task(
          itemId: ItemId.generate(),
          title: ItemTitle('DONE タスク'),
          description: ItemDescription('完了済み'),
          deadline: ItemDeadline(todayDeadline),
          status: TaskStatus.done(),
          milestoneId: ItemId('milestone-1'),
        );

        await mockRepository.saveTask(todoTask);
        await mockRepository.saveTask(doingTask);
        await mockRepository.saveTask(doneTask);

        // Act
        final result = await useCase();

        // Assert
        expect(result.length, 3);
        expect(result.where((t) => t.status.isTodo).length, 1);
        expect(result.where((t) => t.status.isDoing).length, 1);
        expect(result.where((t) => t.status.isDone).length, 1);
      });
    });
  });
}
