import 'package:app/presentation/theme/app_colors.dart';
import 'package:app/presentation/utils/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/goal.dart';
import '../../state_management/providers/app_providers.dart';
import 'calendar_view/calendar_view_model.dart';
import 'calendar_view/calendar_state.dart';
import 'calendar_view/calendar_widgets.dart';

/// カレンダービュー
///
/// 月単位のカレンダーで、日付ごとのタスク期限を可視化します。
class CalendarView extends ConsumerWidget {
  final List<Goal> goals;

  const CalendarView({super.key, required this.goals});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasksAsync = ref.watch(todayTasksProvider);
    final state = ref.watch(calendarViewModelProvider);
    final viewModel = ref.read(calendarViewModelProvider.notifier);

    ref.listen(todayTasksProvider, (previous, next) {
      next.whenData((allTasks) {
        viewModel.updateTasksCache(allTasks);
      });
    });

    return allTasksAsync.when(
      data: (_) => _buildCalendarContent(state, viewModel),
      loading: () => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
      error: (error, stackTrace) => Center(child: Text('エラー: $error')),
    );
  }

  Column _buildCalendarContent(
    CalendarPageState state,
    CalendarViewModel viewModel,
  ) {
    return Column(
      children: [
        CalendarMonthNavigator(
          onPreviousMonth: viewModel.previousMonth,
          onNextMonth: viewModel.nextMonth,
          monthDisplayText: DateFormatter.toJapaneseMonth(state.displayedMonth),
        ),
        CalendarGrid(
          displayedMonth: state.displayedMonth,
          selectedDate: state.selectedDate,
          onDateSelected: viewModel.selectDate,
          getTasksForDate: state.getTasksForDate,
        ),
        Expanded(
          child: CalendarTaskList(
            selectedDate: state.selectedDate,
            tasks: state.getTasksForDate(state.selectedDate),
            selectedDateDisplayText: DateFormatter.toJapaneseDateTaskHeader(
              state.selectedDate,
            ),
          ),
        ),
      ],
    );
  }
}
