import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/create_task_use_case.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';
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

/// MockMilestoneRepository - マイルストーンを管理
class MockMilestoneRepository implements MilestoneRepository {
  final List<Milestone> _milestones = [];

  @override
  Future<void> deleteMilestone(String id) async =>
      _milestones.removeWhere((m) => m.id.value == id);

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async =>
      _milestones.removeWhere((m) => m.goalId == goalId);

  @override
  Future<List<Milestone>> getAllMilestones() async => _milestones;

  @override
  Future<Milestone?> getMilestoneById(String id) async {
    try {
      return _milestones.firstWhere((m) => m.id.value == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async =>
      _milestones.where((m) => m.goalId == goalId).toList();

  @override
  Future<int> getMilestoneCount() async => _milestones.length;

  @override
  Future<void> saveMilestone(Milestone milestone) async =>
      _milestones.add(milestone);
}

void main() {
  group('CreateTaskUseCase - 不正な親への追加テスト', () {
    late CreateTaskUseCase useCase;
    late MockTaskRepository mockTaskRepository;
    late MockMilestoneRepository mockMilestoneRepository;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      mockMilestoneRepository = MockMilestoneRepository();
      useCase = CreateTaskUseCaseImpl(
        mockTaskRepository,
        mockMilestoneRepository,
      );

      // Pre-populate milestone-1 for tests
      mockMilestoneRepository.saveMilestone(
        Milestone(
          id: MilestoneId('milestone-1'),
          title: MilestoneTitle('テストマイルストーン'),
          deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
          goalId: 'goal-1',
        ),
      );
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

    test('500文字以上の説明でタスク作成時にエラー', () async {
      final longDescription = 'x' * 501;
      expect(
        () async => await useCase.call(
          title: 'タスク',
          description: longDescription,
          deadline: DateTime(2026, 12, 31),
          milestoneId: 'milestone-1',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    /// NOTE: Phase 3 参照整合性検証（実装完了）
    /// CreateTaskUseCase が MilestoneRepository を注入されて
    /// 存在しないマイルストーン ID のチェックを実装完了
    test('存在しないマイルストーン ID でタスクを作成しようとするとエラー', () async {
      expect(
        () async => await useCase.call(
          title: 'タスク',
          description: '説明',
          deadline: DateTime(2026, 12, 31),
          milestoneId: 'non-existent-milestone',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
