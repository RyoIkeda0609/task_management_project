import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/get_all_tasks_today_use_case.dart';
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
          id: TaskId.generate(),
          title: TaskTitle('本日タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(todayDeadline),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        final otherDayTask = Task(
          id: TaskId.generate(),
          title: TaskTitle('明日タスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(otherDayDeadline),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );

        await mockRepository.saveTask(todayTask);
        await mockRepository.saveTask(otherDayTask);

        // Act
        final result = await useCase();

        // Assert
        expect(result.length, 1);
        expect(result.first.id.value, todayTask.id.value);
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
          id: TaskId.generate(),
          title: TaskTitle('タスク1'),
          description: TaskDescription('説明1'),
          deadline: TaskDeadline(todayDeadline),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク2'),
          description: TaskDescription('説明2'),
          deadline: TaskDeadline(todayDeadline),
          status: TaskStatus.doing(),
          milestoneId: 'milestone-123',
        );
        final task3 = Task(
          id: TaskId.generate(),
          title: TaskTitle('タスク3'),
          description: TaskDescription('説明3'),
          deadline: TaskDeadline(todayDeadline),
          status: TaskStatus.done(),
          milestoneId: 'milestone-456',
        );
        final task4 = Task(
          id: TaskId.generate(),
          title: TaskTitle('明日のタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(tomorrowDeadline),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-789',
        );

        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);
        await mockRepository.saveTask(task3);
        await mockRepository.saveTask(task4);

        // Act
        final result = await useCase();

        // Assert
        expect(result.length, 3);
        expect(result.any((t) => t.id.value == task1.id.value), true);
        expect(result.any((t) => t.id.value == task2.id.value), true);
        expect(result.any((t) => t.id.value == task3.id.value), true);
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
          id: TaskId.generate(),
          title: TaskTitle('明日のタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(tomorrowDeadline),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('3日後のタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(threeDaysLaterDeadline),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-123',
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
          id: TaskId.generate(),
          title: TaskTitle('マイルストーン1のタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(todayDeadline),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-1',
        );
        final task2 = Task(
          id: TaskId.generate(),
          title: TaskTitle('マイルストーン2のタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(todayDeadline),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-2',
        );
        final task3 = Task(
          id: TaskId.generate(),
          title: TaskTitle('マイルストーン3のタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(todayDeadline),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-3',
        );
        final task4 = Task(
          id: TaskId.generate(),
          title: TaskTitle('別マイルストーンの明日のタスク'),
          description: TaskDescription('説明'),
          deadline: TaskDeadline(tomorrowDeadline),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-4',
        );

        await mockRepository.saveTask(task1);
        await mockRepository.saveTask(task2);
        await mockRepository.saveTask(task3);
        await mockRepository.saveTask(task4);

        // Act
        final result = await useCase();

        // Assert
        expect(result.length, 3);
        expect(result.any((t) => t.milestoneId == 'milestone-1'), true);
        expect(result.any((t) => t.milestoneId == 'milestone-2'), true);
        expect(result.any((t) => t.milestoneId == 'milestone-3'), true);
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
          id: TaskId.generate(),
          title: TaskTitle('TODO タスク'),
          description: TaskDescription('まだ開始していない'),
          deadline: TaskDeadline(todayDeadline),
          status: TaskStatus.todo(),
          milestoneId: 'milestone-1',
        );
        final doingTask = Task(
          id: TaskId.generate(),
          title: TaskTitle('DOING タスク'),
          description: TaskDescription('進行中'),
          deadline: TaskDeadline(todayDeadline),
          status: TaskStatus.doing(),
          milestoneId: 'milestone-1',
        );
        final doneTask = Task(
          id: TaskId.generate(),
          title: TaskTitle('DONE タスク'),
          description: TaskDescription('完了済み'),
          deadline: TaskDeadline(todayDeadline),
          status: TaskStatus.done(),
          milestoneId: 'milestone-1',
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
