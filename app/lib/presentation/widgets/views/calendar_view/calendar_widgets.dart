import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/task.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../navigation/app_router.dart';

/// カレンダーの月ナビゲータ
class CalendarMonthNavigator extends ConsumerWidget {
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final String monthDisplayText;

  const CalendarMonthNavigator({
    super.key,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.monthDisplayText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.neutral100,
      padding: EdgeInsets.all(Spacing.medium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousMonth,
          ),
          Text(monthDisplayText, style: AppTextStyles.titleMedium),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}

/// カレンダーグリッド
class CalendarGrid extends ConsumerWidget {
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) getTasksForDate;

  const CalendarGrid({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.getTasksForDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.neutral50,
      padding: EdgeInsets.all(Spacing.small),
      child: Column(children: [_buildWeekdayHeader(), _buildCalendarDays()]),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        return Center(
          child: Text(
            weekdays[index],
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarDays() {
    final firstDayOfMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: firstWeekday + daysInMonth,
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return Container();
        }
        final day = index - firstWeekday + 1;
        final date = DateTime(displayedMonth.year, displayedMonth.month, day);
        return CalendarDayCell(
          date: date,
          isSelected: _isSelected(date),
          isToday: _isToday(date),
          taskCount: (getTasksForDate(date) as List<Task>).length,
          onTap: onDateSelected,
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isSelected(DateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }
}

/// カレンダーの日付セル
class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final int taskCount;
  final Function(DateTime) onTap;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.taskCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(date),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isToday
              ? AppColors.primaryLight
              : AppColors.neutral100,
          border: Border.all(
            color: isToday ? AppColors.warning : AppColors.neutral200,
            width: isToday ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date.day.toString(),
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.neutral100
                      : AppColors.neutral900,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (taskCount > 0)
                Padding(
                  padding: EdgeInsets.only(top: Spacing.xSmall),
                  child: Text(
                    '$taskCount',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.neutral100
                          : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// カレンダーのタスク一覧
class CalendarTaskList extends StatelessWidget {
  final DateTime selectedDate;
  final List<Task> tasks;
  final String selectedDateDisplayText;

  const CalendarTaskList({
    super.key,
    required this.selectedDate,
    required this.tasks,
    required this.selectedDateDisplayText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral100,
      padding: EdgeInsets.all(Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(selectedDateDisplayText, style: AppTextStyles.titleMedium),
          SizedBox(height: Spacing.medium),
          if (tasks.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'この日のタスクはありません',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) =>
                    CalendarTaskItem(task: tasks[index]),
              ),
            ),
        ],
      ),
    );
  }
}

/// カレンダーのタスク項目
class CalendarTaskItem extends StatelessWidget {
  final Task task;

  const CalendarTaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: Spacing.small),
      child: InkWell(
        onTap: () => AppRouter.navigateToTaskDetail(context, task.id.value),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIcon(task.status),
                  SizedBox(width: Spacing.small),
                  Expanded(
                    child: Text(
                      task.title.value,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Spacing.xSmall),
              Text(
                task.description.value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(dynamic status) {
    final statusValue = status is String ? status : (status as dynamic).value;
    final (color, icon) = switch (statusValue) {
      'todo' => (AppColors.neutral500, Icons.radio_button_unchecked),
      'doing' => (AppColors.warning, Icons.schedule),
      'done' => (AppColors.success, Icons.check_circle),
      _ => (AppColors.neutral500, Icons.radio_button_unchecked),
    };

    return Icon(icon, color: color, size: 20);
  }
}
