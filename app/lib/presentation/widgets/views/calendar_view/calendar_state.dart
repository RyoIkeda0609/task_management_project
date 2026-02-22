import '../../../../domain/entities/task.dart';

/// カレンダービューの状態
class CalendarPageState {
  /// 選択されている日付
  final DateTime selectedDate;

  /// 表示されている月
  final DateTime displayedMonth;

  /// 日付ごとのタスクキャッシュ
  final Map<DateTime, List<Task>> tasksCache;

  CalendarPageState({
    required this.selectedDate,
    required this.displayedMonth,
    required this.tasksCache,
  });

  /// 指定日付のタスクを取得
  List<Task> getTasksForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return tasksCache[dateKey] ?? [];
  }



  /// copyWith
  CalendarPageState copyWith({
    DateTime? selectedDate,
    DateTime? displayedMonth,
    Map<DateTime, List<Task>>? tasksCache,
  }) {
    return CalendarPageState(
      selectedDate: selectedDate ?? this.selectedDate,
      displayedMonth: displayedMonth ?? this.displayedMonth,
      tasksCache: tasksCache ?? this.tasksCache,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarPageState &&
          runtimeType == other.runtimeType &&
          selectedDate == other.selectedDate &&
          displayedMonth == other.displayedMonth &&
          tasksCache == other.tasksCache;

  @override
  int get hashCode =>
      selectedDate.hashCode ^ displayedMonth.hashCode ^ tasksCache.hashCode;
}
