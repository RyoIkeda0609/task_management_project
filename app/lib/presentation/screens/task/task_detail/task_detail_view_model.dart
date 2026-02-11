import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_detail_state.dart';

class TaskDetailViewModel extends StateNotifier<TaskDetailPageState> {
  TaskDetailViewModel({required String taskId, String source = 'today_tasks'})
    : super(TaskDetailPageState(taskId: taskId, source: source));

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

/// StateNotifierProvider (Family)
final taskDetailViewModelProvider =
    StateNotifierProvider.family<
      TaskDetailViewModel,
      TaskDetailPageState,
      ({String taskId, String source})
    >((ref, params) {
      return TaskDetailViewModel(taskId: params.taskId, source: params.source);
    });
