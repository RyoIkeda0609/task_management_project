import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_detail_state.dart';

class TaskDetailViewModel extends StateNotifier<TaskDetailPageState> {
  TaskDetailViewModel()
    : super(TaskDetailPageState.loading());
}

/// StateNotifierProvider (Family)
final taskDetailViewModelProvider =
    StateNotifierProvider.family<
      TaskDetailViewModel,
      TaskDetailPageState,
      ({String taskId, String source})
    >((ref, params) {
      return TaskDetailViewModel();
    });
