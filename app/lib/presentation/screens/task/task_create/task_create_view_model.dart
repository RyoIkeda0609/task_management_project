import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_create_state.dart';

class TaskCreateViewModel extends StateNotifier<TaskCreatePageState> {
  TaskCreateViewModel({required String milestoneId, required String goalId})
    : super(
        TaskCreatePageState(
          milestoneId: milestoneId,
          goalId: goalId,
          selectedDeadline: DateTime.now(),
        ),
      );

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

  /// フォームをリセット
  void resetForm() {
    state = TaskCreatePageState(
      milestoneId: state.milestoneId,
      goalId: state.goalId,
      selectedDeadline: DateTime.now(),
    );
  }
}

/// StateNotifierProvider (Family)
final taskCreateViewModelProvider =
    StateNotifierProvider.family<
      TaskCreateViewModel,
      TaskCreatePageState,
      ({String milestoneId, String goalId})
    >((ref, params) {
      return TaskCreateViewModel(
        milestoneId: params.milestoneId,
        goalId: params.goalId,
      );
    });
