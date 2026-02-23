import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_edit_state.dart';

class TaskEditViewModel extends StateNotifier<TaskEditPageState> {
  TaskEditViewModel() : super(TaskEditPageState(deadline: DateTime.now()));

  /// タスク情報で状態を初期化
  void initializeWithTask({
    required String taskId,
    required String title,
    required String description,
    required DateTime deadline,
  }) {
    state = TaskEditPageState(
      taskId: taskId,
      title: title,
      description: description,
      deadline: deadline,
      isLoading: false,
    );
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateDeadline(DateTime deadline) {
    state = state.copyWith(deadline: deadline);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

/// StateNotifierProvider
final taskEditViewModelProvider =
    StateNotifierProvider.autoDispose<TaskEditViewModel, TaskEditPageState>((
      ref,
    ) {
      return TaskEditViewModel();
    });
