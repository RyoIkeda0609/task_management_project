import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/services/task_completion_service.dart';
import 'package:app/domain/value_objects/item/item_id.dart';
import 'package:app/domain/value_objects/item/item_title.dart';
import 'package:app/domain/value_objects/item/item_description.dart';
import 'package:app/domain/value_objects/item/item_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';

/// テスト用 Fake TaskRepository
class FakeTaskRepository implements TaskRepository {
  final Map<String, Task> _tasks = {};

  void addTask(Task task) {
    _tasks[task.itemId.value] = task;
  }

  @override
  Future<List<Task>> getAllTasks() async => _tasks.values.toList();

  @override
  Future<Task?> getTaskById(String id) async => _tasks[id];

  @override
  Future<List<Task>> getTasksByMilestoneId(String milestoneId) async =>
      _tasks.values.where((t) => t.milestoneId.value == milestoneId).toList();

  @override
  Future<void> saveTask(Task task) async {
    _tasks[task.itemId.value] = task;
  }

  @override
  Future<void> deleteTask(String id) async => _tasks.remove(id);

  @override
  Future<void> deleteTasksByMilestoneId(String milestoneId) async =>
      _tasks.removeWhere((_, t) => t.milestoneId.value == milestoneId);

  @override
  Future<int> getTaskCount() async => _tasks.length;
}

void main() {
  group('TaskCompletionService', () {
    late FakeTaskRepository fakeTaskRepository;
    late TaskCompletionService service;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      fakeTaskRepository = FakeTaskRepository();
      service = TaskCompletionService(fakeTaskRepository);
    });

    Task createTask(String id, TaskStatus status) {
      return Task(
        itemId: ItemId(id),
        title: ItemTitle('Task $id'),
        description: ItemDescription(''),
        deadline: ItemDeadline(tomorrow),
        status: status,
        milestoneId: ItemId('ms-1'),
      );
    }

    group('isTaskCompleted', () {
      test('Done のタスクは true を返す', () async {
        fakeTaskRepository.addTask(createTask('t1', TaskStatus.done));

        final result = await service.isTaskCompleted('t1');
        expect(result, true);
      });

      test('Todo のタスクは false を返す', () async {
        fakeTaskRepository.addTask(createTask('t1', TaskStatus.todo));

        final result = await service.isTaskCompleted('t1');
        expect(result, false);
      });

      test('Doing のタスクは false を返す', () async {
        fakeTaskRepository.addTask(createTask('t1', TaskStatus.doing));

        final result = await service.isTaskCompleted('t1');
        expect(result, false);
      });

      test('存在しないタスクIDでArgumentErrorが発生すること', () async {
        expect(
          () => service.isTaskCompleted('non-existent'),
          throwsArgumentError,
        );
      });
    });
  });
}
