import 'package:app/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/goal.dart';
import '../../state_management/providers/app_providers.dart';
import 'calendar_view/calendar_view_model.dart';
import 'calendar_view/calendar_widgets.dart';

/// カレンダービュー
///
/// 月単位のカレンダーで、日付ごとのタスク期限を可視化します。
class CalendarView extends ConsumerWidget {
  final List<Goal> goals;

  const CalendarView({super.key, required this.goals});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // すべてのタスクを取得
    final allTasksAsync = ref.watch(todayTasksProvider);
    final state = ref.watch(calendarViewModelProvider);
    final viewModel = ref.read(calendarViewModelProvider.notifier);

    // タスクが更新されたときのみキャッシュを再構築
    ref.listen(todayTasksProvider, (previous, next) {
      next.whenData((allTasks) {
        // listener 内で state 更新（build 外で実行）
        viewModel.buildTasksCache(allTasks);
      });
    });

    return allTasksAsync.when(
      data: (allTasks) {
        return Column(
          children: [
            CalendarMonthNavigator(
              onPreviousMonth: viewModel.previousMonth,
              onNextMonth: viewModel.nextMonth,
              monthDisplayText: state.monthDisplayText,
            ),
            CalendarGrid(
              displayedMonth: state.displayedMonth,
              selectedDate: state.selectedDate,
              onDateSelected: viewModel.selectDate,
              getTasksForDate: viewModel.getTasksForDate,
            ),
            Expanded(
              child: CalendarTaskList(
                selectedDate: state.selectedDate,
                tasks: viewModel.getTasksForDate(state.selectedDate),
                selectedDateDisplayText: state.selectedDateDisplayText,
              ),
            ),
          ],
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
      error: (error, stackTrace) => Center(child: Text('エラー: $error')),
    );
  }
}
