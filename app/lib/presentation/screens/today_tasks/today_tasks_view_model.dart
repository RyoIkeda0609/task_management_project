import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'today_tasks_state.dart';

class TodayTasksViewModel extends StateNotifier<TodayTasksPageState> {
  TodayTasksViewModel() : super(const TodayTasksPageState());

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

/// StateNotifierProvider
final todayTasksViewModelProvider =
    StateNotifierProvider<TodayTasksViewModel, TodayTasksPageState>((ref) {
      return TodayTasksViewModel();
    });
