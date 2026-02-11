import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'today_tasks_state.dart';

class TodayTasksViewModel extends StateNotifier<TodayTasksPageState> {
  TodayTasksViewModel() : super(TodayTasksPageState.loading());
}

/// StateNotifierProvider
final todayTasksViewModelProvider =
    StateNotifierProvider<TodayTasksViewModel, TodayTasksPageState>((ref) {
      return TodayTasksViewModel();
    });
