import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/services/milestone_completion_service.dart';
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
  group('MilestoneCompletionService', () {
    late FakeTaskRepository fakeTaskRepository;
    late MilestoneCompletionService service;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    setUp(() {
      fakeTaskRepository = FakeTaskRepository();
      service = MilestoneCompletionService(fakeTaskRepository);
    });

    Task createTask(String id, String milestoneId, TaskStatus status) {
      return Task(
        itemId: ItemId(id),
        title: ItemTitle('Task $id'),
        description: ItemDescription(''),
        deadline: ItemDeadline(tomorrow),
        status: status,
        milestoneId: ItemId(milestoneId),
      );
    }

    group('isMilestoneCompleted', () {
      test('タスクが存在しない場合は false を返す', () async {
        final result = await service.isMilestoneCompleted('ms-1');
        expect(result, false);
      });

      test('すべてのタスクが Done の場合は true を返す', () async {
        fakeTaskRepository.addTask(createTask('t1', 'ms-1', TaskStatus.done()));
        fakeTaskRepository.addTask(createTask('t2', 'ms-1', TaskStatus.done()));

        final result = await service.isMilestoneCompleted('ms-1');
        expect(result, true);
      });

      test('一部のタスクが未完了の場合は false を返す', () async {
        fakeTaskRepository.addTask(createTask('t1', 'ms-1', TaskStatus.done()));
        fakeTaskRepository.addTask(createTask('t2', 'ms-1', TaskStatus.todo()));

        final result = await service.isMilestoneCompleted('ms-1');
        expect(result, false);
      });

      test('すべてのタスクが Todo の場合は false を返す', () async {
        fakeTaskRepository.addTask(createTask('t1', 'ms-1', TaskStatus.todo()));

        final result = await service.isMilestoneCompleted('ms-1');
        expect(result, false);
      });

      test('Doing のタスクがある場合は false を返す', () async {
        fakeTaskRepository.addTask(
          createTask('t1', 'ms-1', TaskStatus.doing()),
        );

        final result = await service.isMilestoneCompleted('ms-1');
        expect(result, false);
      });

      test('別のマイルストーンのタスクは影響しない', () async {
        fakeTaskRepository.addTask(createTask('t1', 'ms-1', TaskStatus.done()));
        fakeTaskRepository.addTask(createTask('t2', 'ms-2', TaskStatus.todo()));

        final result = await service.isMilestoneCompleted('ms-1');
        expect(result, true);
      });
    });

    group('calculateMilestoneProgress', () {
      test('タスクが存在しない場合は 0% を返す', () async {
        final progress = await service.calculateMilestoneProgress('ms-1');
        expect(progress.value, 0);
      });

      test('すべてのタスクが Done の場合は 100% を返す', () async {
        fakeTaskRepository.addTask(createTask('t1', 'ms-1', TaskStatus.done()));
        fakeTaskRepository.addTask(createTask('t2', 'ms-1', TaskStatus.done()));

        final progress = await service.calculateMilestoneProgress('ms-1');
        expect(progress.value, 100);
      });

      test('すべてのタスクが Todo の場合は 0% を返す', () async {
        fakeTaskRepository.addTask(createTask('t1', 'ms-1', TaskStatus.todo()));
        fakeTaskRepository.addTask(createTask('t2', 'ms-1', TaskStatus.todo()));

        final progress = await service.calculateMilestoneProgress('ms-1');
        expect(progress.value, 0);
      });

      test('タスクが混在する場合に正しい進捗率を返す', () async {
        // Todo=0, Doing=50, Done=100 → average = (0+50+100)/3 = 50
        fakeTaskRepository.addTask(createTask('t1', 'ms-1', TaskStatus.todo()));
        fakeTaskRepository.addTask(
          createTask('t2', 'ms-1', TaskStatus.doing()),
        );
        fakeTaskRepository.addTask(createTask('t3', 'ms-1', TaskStatus.done()));

        final progress = await service.calculateMilestoneProgress('ms-1');
        expect(progress.value, 50);
      });

      test('Doing のみの場合は 50% を返す', () async {
        fakeTaskRepository.addTask(
          createTask('t1', 'ms-1', TaskStatus.doing()),
        );

        final progress = await service.calculateMilestoneProgress('ms-1');
        expect(progress.value, 50);
      });

      test('別のマイルストーンのタスクは計算に含まない', () async {
        fakeTaskRepository.addTask(createTask('t1', 'ms-1', TaskStatus.done()));
        fakeTaskRepository.addTask(createTask('t2', 'ms-2', TaskStatus.todo()));

        final progress = await service.calculateMilestoneProgress('ms-1');
        expect(progress.value, 100);
      });
    });
  });
}
