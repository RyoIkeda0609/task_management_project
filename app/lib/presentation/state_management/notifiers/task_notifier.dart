import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/value_objects/task/task_id.dart';
import 'package:app/domain/value_objects/task/task_title.dart';
import 'package:app/domain/value_objects/task/task_description.dart';
import 'package:app/domain/value_objects/task/task_deadline.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// タスク一覧の状態を管理する Notifier
///
/// 非同期のTask操作（ロード、作成、削除等）を統一的に管理し、
/// UI側に AsyncValue で状態を提供します。
class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;

  TasksNotifier(this._repository) : super(const AsyncValue.loading());

  /// 指定したマイルストーンIDに紐づくタスク一覧を読み込む
  Future<void> loadTasksByMilestoneId(String milestoneId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.getTasksByMilestoneId(milestoneId),
    );
  }

  /// すべてのタスクを読み込む
  Future<void> loadAllTasks() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllTasks());
  }

  /// IDからタスクを取得
  Future<Task?> getTaskById(String taskId) async {
    return await _repository.getTaskById(taskId);
  }

  /// 新しいタスクを作成
  Future<void> createTask({
    required String milestoneId,
    required TaskTitle title,
    TaskDescription? description,
    required TaskDeadline deadline,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 新しいTaskインスタンスを作成
      final task = Task(
        id: TaskId.generate(),
        title: title,
        description: description ?? TaskDescription(''),
        deadline: deadline,
        status: TaskStatus.todo(), // 小文字の'todo'を使用
        milestoneId: milestoneId,
      );
      // リポジトリに保存
      await _repository.saveTask(task);
      // 作成後、一覧を更新
      return _repository.getTasksByMilestoneId(milestoneId);
    });
  }

  /// タスクを更新
  Future<void> updateTask({
    required String taskId,
    required String milestoneId,
    TaskTitle? newTitle,
    TaskDescription? newDescription,
    TaskDeadline? newDeadline,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final task = await _repository.getTaskById(taskId);
      if (task != null) {
        // 新しいTaskインスタンスを作成（変更部分のみ上書き）
        final updatedTask = Task(
          id: task.id,
          title: newTitle ?? task.title,
          description: newDescription ?? task.description,
          deadline: newDeadline ?? task.deadline,
          status: task.status,
          milestoneId: milestoneId,
        );
        // リポジトリに保存
        await _repository.saveTask(updatedTask);
        // 更新後、一覧を更新
        return _repository.getTasksByMilestoneId(milestoneId);
      }
      throw Exception('Task not found');
    });
  }

  /// タスクのステータスを次の状態に遷移（Todo→Doing→Done→Todo）
  Future<void> changeTaskStatus(String taskId, String milestoneId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final task = await _repository.getTaskById(taskId);
      if (task != null) {
        // cycleStatus() メソッドを使用してステータスを遷移
        final updatedTask = task.cycleStatus();
        // リポジトリに保存
        await _repository.saveTask(updatedTask);
        // 更新後、一覧を更新
        return _repository.getTasksByMilestoneId(milestoneId);
      }
      throw Exception('Task not found');
    });
  }

  /// タスクを削除
  Future<void> deleteTask(String taskId, String milestoneId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteTask(taskId);
      // 削除後、一覧を更新
      return _repository.getTasksByMilestoneId(milestoneId);
    });
  }
}
