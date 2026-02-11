import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_edit_state.dart';

class TaskEditViewModel extends StateNotifier<TaskEditPageState> {
  TaskEditViewModel()
    : super(TaskEditPageState(selectedDeadline: DateTime.now()));

  /// タスク情報で状態を初期化
  void initializeWithTask({
    required String title,
    required String description,
    required DateTime selectedDeadline,
  }) {
    state = TaskEditPageState(
      title: title,
      description: description,
      selectedDeadline: selectedDeadline,
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
    state = state.copyWith(selectedDeadline: deadline);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

/// StateNotifierProvider
final taskEditViewModelProvider =
    StateNotifierProvider<TaskEditViewModel, TaskEditPageState>((ref) {
      return TaskEditViewModel();
    });
