import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/task.dart';
import 'calendar_state.dart';

/// カレンダービューのViewModel
class CalendarViewModel extends StateNotifier<CalendarPageState> {
  CalendarViewModel()
    : super(
        CalendarPageState(
          selectedDate: DateTime.now(),
          displayedMonth: DateTime.now(),
          tasksCache: {},
        ),
      );

  /// タスク一覧からキャッシュを構築
  void buildTasksCache(List<Task> allTasks) {
    final cache = <DateTime, List<Task>>{};
    for (final task in allTasks) {
      final dateKey = DateTime(
        task.deadline.value.year,
        task.deadline.value.month,
        task.deadline.value.day,
      );
      cache.putIfAbsent(dateKey, () => []).add(task);
    }
    state = state.copyWith(tasksCache: cache);
  }

  /// 指定日付を選択
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// 前月に移動
  void previousMonth() {
    final newMonth = DateTime(
      state.displayedMonth.year,
      state.displayedMonth.month - 1,
    );
    state = state.copyWith(displayedMonth: newMonth);
  }

  /// 次月に移動
  void nextMonth() {
    final newMonth = DateTime(
      state.displayedMonth.year,
      state.displayedMonth.month + 1,
    );
    state = state.copyWith(displayedMonth: newMonth);
  }
}

/// CalendarViewModelProvider
final calendarViewModelProvider =
    StateNotifierProvider.autoDispose<CalendarViewModel, CalendarPageState>(
      (ref) => CalendarViewModel(),
    );
