import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/change_task_status_use_case.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/repositories/task_repository.dart';

class MockTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAllTasks() async => _tasks;

  @override
  Future<Task?> getTaskById(String id) async => _tasks.firstWhere(
    (t) => t.id.value == id,
    orElse: () => throw Exception(),
  );

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async =>
      _tasks.where((t) => t.id.value.startsWith(milestoneId)).toList();

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
      _tasks.removeWhere((t) => t.id.value.startsWith(milestoneId));

  @override
  Future<int> getTaskCount() async => _tasks.length;
}

void main() {
  group('ChangeTaskStatusUseCase', () {
    late ChangeTaskStatusUseCase useCase;
    late MockTaskRepository repository;

    setUp(() {
      repository = MockTaskRepository();
      useCase = ChangeTaskStatusUseCaseImpl(repository);
    });

    test('ステータスが Todo → Doing に変更されること', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final task = Task(
        id: TaskId('task-1'),
        title: TaskTitle('テストタスク'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(tomorrow),
        status: TaskStatus.todo(),
        milestoneId: 'milestone-1',
      );

      await repository.saveTask(task);

      final updatedTask = await useCase.call('task-1');

      expect(updatedTask.status.isDoing, true);
    });

    test('ステータスが Doing → Done に変更されること', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final task = Task(
        id: TaskId('task-2'),
        title: TaskTitle('テストタスク'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(tomorrow),
        status: TaskStatus.doing(),
        milestoneId: 'milestone-1',
      );

      await repository.saveTask(task);

      final updatedTask = await useCase.call('task-2');

      expect(updatedTask.status.isDone, true);
    });

    test('ステータスが Done → Todo に変更されること（循環）', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final task = Task(
        id: TaskId('task-3'),
        title: TaskTitle('テストタスク'),
        description: TaskDescription('説明'),
        deadline: TaskDeadline(tomorrow),
        status: TaskStatus.done(),
        milestoneId: 'milestone-1',
      );

      await repository.saveTask(task);

      final updatedTask = await useCase.call('task-3');

      expect(updatedTask.status.isTodo, true);
    });
  });
}
