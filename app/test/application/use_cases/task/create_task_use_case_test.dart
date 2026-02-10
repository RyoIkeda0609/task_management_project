import 'package:flutter_test/flutter_test.dart';
import 'package:app/application/use_cases/task/create_task_use_case.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';
import 'package:app/domain/value_objects/milestone/milestone_id.dart';
import 'package:app/domain/value_objects/milestone/milestone_title.dart';

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

/// MockMilestoneRepository
class MockMilestoneRepository implements MilestoneRepository {
  final List<Milestone> _milestones = [];

  @override
  Future<bool> deleteAllMilestones() async => true;

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
  group('CreateTaskUseCase', () {
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

      // Pre-populate milestones for tests
      mockMilestoneRepository.saveMilestone(
        Milestone(
          id: MilestoneId('milestone-1'),
          title: MilestoneTitle('テストマイルストーン1'),
          deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
          goalId: 'goal-1',
        ),
      );
      mockMilestoneRepository.saveMilestone(
        Milestone(
          id: MilestoneId('milestone-123'),
          title: MilestoneTitle('テストマイルストーン123'),
          deadline: MilestoneDeadline(DateTime(2026, 12, 31)),
          goalId: 'goal-1',
        ),
      );
    });

    group('実行', () {
      test('有効な入力でタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: 'API実装',
          description: 'RESTful APIの実装とテスト',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.title.value, 'API実装');
        expect(task.description.value, 'RESTful APIの実装とテスト');
        expect(task.deadline.value.day, tomorrow.day);
        expect(task.status.isTodo, true);
        expect(task.milestoneId, milestoneId);
      });

      test('ID は一意に生成されること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        final task1 = await useCase.call(
          title: 'タスク1',
          description: '説明1',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        final task2 = await useCase.call(
          title: 'タスク2',
          description: '説明2',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task1.id, isNot(equals(task2.id)));
      });

      test('作成時のステータスは常に Todo であること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: 'タイトル',
          description: '説明',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.status.isTodo, true);
        expect(task.status.isDoing, false);
        expect(task.status.isDone, false);
      });

      test('無効なタイトル（101文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidTitle = 'a' * 101;
        const milestoneId = 'milestone-123';

        expect(
          () => useCase.call(
            title: invalidTitle,
            description: '説明',
            deadline: tomorrow,
            milestoneId: milestoneId,
          ),
          throwsArgumentError,
        );
      });

      test('無効な説明（501文字以上）でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final invalidDescription = 'a' * 501;
        const milestoneId = 'milestone-123';

        expect(
          () => useCase.call(
            title: 'タイトル',
            description: invalidDescription,
            deadline: tomorrow,
            milestoneId: milestoneId,
          ),
          throwsArgumentError,
        );
      });

      test('本日以前の期限でもタスクが作成できること', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        expect(
          () => useCase.call(
            title: 'タイトル',
            description: '説明',
            deadline: yesterday,
            milestoneId: milestoneId,
          ),
          returnsNormally,
        );
      });

      test('空白のみのタイトルでエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        expect(
          () => useCase.call(
            title: '   ',
            description: '説明',
            deadline: tomorrow,
            milestoneId: milestoneId,
          ),
          throwsArgumentError,
        );
      });

      test('空白のみの説明でも正常に作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: 'タイトル',
          description: '   ',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.description.value, '   ');
      });

      test('空の milestoneId でエラーが発生すること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(
          () => useCase.call(
            title: 'タイトル',
            description: '説明',
            deadline: tomorrow,
            milestoneId: '',
          ),
          throwsArgumentError,
        );
      });

      test('1文字のタイトルでタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: 'a',
          description: '説明',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.title.value, 'a');
      });

      test('100文字のタイトルでタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxTitle = 'a' * 100;
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: maxTitle,
          description: '説明',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.title.value, maxTitle);
      });

      test('1文字の説明でタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: 'タイトル',
          description: 'a',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.description.value, 'a');
      });

      test('500文字の説明でタスクが作成できること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final maxDescription = 'a' * 500;
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: 'タイトル',
          description: maxDescription,
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        expect(task.description.value, maxDescription);
      });

      test('タスクを作成したら Repository に保存されること', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        const milestoneId = 'milestone-123';

        final task = await useCase.call(
          title: 'API実装',
          description: 'RESTful APIの実装とテスト',
          deadline: tomorrow,
          milestoneId: milestoneId,
        );

        final saved = await mockTaskRepository.getTaskById(task.id.value);
        expect(saved, isNotNull);
        expect(saved!.id, task.id);
        expect(saved.title.value, task.title.value);
        expect(saved.description.value, task.description.value);
      });

      /// NOTE: Phase 3 参照整合性検証（実装完了）
      test('存在しないマイルストーン ID でタスク作成時にエラー', () async {
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
  });
}
