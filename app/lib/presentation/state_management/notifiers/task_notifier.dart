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
/// 責務: 状態管理と Repository の呼び出しのみ
/// UI側で判断（キャッシュ無効化など）を行うことで責務を分離
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
  ///
  /// 注意: UI側で ref.invalidate(tasksByMilestoneProvider) を呼び出して一覧を更新してください
  Future<void> createTask({
    required String milestoneId,
    required TaskTitle title,
    TaskDescription? description,
    required TaskDeadline deadline,
  }) async {
    // Notifier は単に保存処理を実行するのみ
    final task = Task(
      id: TaskId.generate(),
      title: title,
      description: description ?? TaskDescription(''),
      deadline: deadline,
      status: TaskStatus.todo(), // 小文字の'todo'を使用
      milestoneId: milestoneId,
    );
    await _repository.saveTask(task);
  }

  /// タスクを更新
  ///
  /// 注意: UI側で ref.invalidate(tasksByMilestoneProvider) を呼び出して一覧を更新してください
  Future<void> updateTask({
    required String taskId,
    required String milestoneId,
    TaskTitle? newTitle,
    TaskDescription? newDescription,
    TaskDeadline? newDeadline,
  }) async {
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
      await _repository.saveTask(updatedTask);
    } else {
      throw Exception('Task not found');
    }
  }

  /// タスクのステータスを次の状態に遷移（Todo→Doing→Done→Todo）
  ///
  /// 注意: UI側で ref.invalidate(tasksByMilestoneProvider) を呼び出して一覧を更新してください
  Future<void> changeTaskStatus(String taskId, String milestoneId) async {
    final task = await _repository.getTaskById(taskId);
    if (task != null) {
      // cycleStatus() メソッドを使用してステータスを遷移
      final updatedTask = task.cycleStatus();
      await _repository.saveTask(updatedTask);
    } else {
      throw Exception('Task not found');
    }
  }

  /// タスクを削除
  ///
  /// 注意: UI側で ref.invalidate(tasksByMilestoneProvider) を呼び出して一覧を更新してください
  Future<void> deleteTask(String taskId, String milestoneId) async {
    await _repository.deleteTask(taskId);
  }
}
