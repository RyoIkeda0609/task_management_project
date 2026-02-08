import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/goal.dart';
import '../../../domain/entities/task.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../state_management/providers/app_providers.dart';
import '../../navigation/app_router.dart';

/// カレンダービュー
///
/// 月単位のカレンダーで、日付ごとのタスク期限を可視化します。
class CalendarView extends ConsumerStatefulWidget {
  final List<Goal> goals;

  const CalendarView({super.key, required this.goals});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  final Map<DateTime, List<Task>> _tasksCache = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    // すべてのタスクを取得してキャッシュ
    final allTasksAsync = ref.watch(todayTasksProvider);

    return allTasksAsync.when(
      data: (allTasks) {
        _buildTasksCache(allTasks);
        return _buildCalendarContent();
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('エラー: $error')),
    );
  }

  void _buildTasksCache(List<Task> allTasks) {
    _tasksCache.clear();
    for (final task in allTasks) {
      final dateKey = DateTime(
        task.deadline.value.year,
        task.deadline.value.month,
        task.deadline.value.day,
      );
      _tasksCache.putIfAbsent(dateKey, () => []).add(task);
    }
  }

  Widget _buildCalendarContent() {
    return Column(
      children: [
        _buildMonthNavigator(),
        _buildCalendarGrid(),
        Expanded(child: _buildTaskListForSelectedDate()),
      ],
    );
  }

  Widget _buildMonthNavigator() {
    return Container(
      color: AppColors.neutral100,
      padding: EdgeInsets.all(Spacing.medium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            '${_displayedMonth.year}年${_displayedMonth.month}月',
            style: AppTextStyles.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    return Container(
      color: AppColors.neutral50,
      padding: EdgeInsets.all(Spacing.small),
      child: Column(
        children: [
          _buildWeekdayHeader(),
          GridView.builder(
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
              final date = DateTime(
                _displayedMonth.year,
                _displayedMonth.month,
                day,
              );
              return _buildDayCell(date);
            },
          ),
        ],
      ),
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

  Widget _buildDayCell(DateTime date) {
    final isToday =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    final isSelected =
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    // タスク数を計算
    final tasksForDate = _getTasksForDate(date);
    final taskCount = tasksForDate.length;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
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
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListForSelectedDate() {
    final tasksForDate = _getTasksForDate(_selectedDate);

    return Container(
      color: AppColors.neutral100,
      padding: EdgeInsets.all(Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日のタスク',
            style: AppTextStyles.titleMedium,
          ),
          SizedBox(height: Spacing.medium),
          if (tasksForDate.isEmpty)
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
                itemCount: tasksForDate.length,
                itemBuilder: (context, index) {
                  return _buildTaskItem(tasksForDate[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
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
    // status は TaskStatus オブジェクトの value プロパティを使用
    final statusValue = status is String ? status : (status as dynamic).value;
    final (color, icon) = switch (statusValue) {
      'todo' => (AppColors.neutral500, Icons.radio_button_unchecked),
      'doing' => (AppColors.warning, Icons.schedule),
      'done' => (AppColors.success, Icons.check_circle),
      _ => (AppColors.neutral500, Icons.radio_button_unchecked),
    };

    return Icon(icon, color: color, size: 20);
  }

  List<Task> _getTasksForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _tasksCache[dateKey] ?? [];
  }
}
