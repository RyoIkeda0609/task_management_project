import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../state_management/providers/app_providers.dart';
import '../../navigation/app_router.dart';
import '../../widgets/common/empty_state.dart';
import '../../utils/date_formatter.dart';
import '../../../application/use_cases/task/get_tasks_grouped_by_status_use_case.dart';
import 'today_tasks_widgets.dart';
import 'today_tasks_state.dart';

/// 今日のタスク画面
///
/// 本日中に完了すべきタスクを表示します。
/// ステータス別にタスクをグループ化して表示します。
/// 日付切り替え機能で前後の日のタスクも確認できます。
class TodayTasksPage extends ConsumerWidget {
  const TodayTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(tasksBySelectedDateGroupedProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'タスク一覧',
        hasLeading: false,
        backgroundColor: AppColors.neutral100,
      ),
      body: Column(
        children: [
          _DateNavigator(selectedDate: selectedDate, ref: ref),
          Expanded(
            child: groupedAsync.when(
              data: (grouped) =>
                  _Body(state: TodayTasksPageState.withData(grouped)),
              loading: () => _Body(state: TodayTasksPageState.loading()),
              error: (error, stackTrace) =>
                  _Body(state: TodayTasksPageState.withError(error.toString())),
            ),
          ),
        ],
      ),
    );
  }
}

/// 日付切り替えナビゲーター
class _DateNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final WidgetRef ref;

  const _DateNavigator({required this.selectedDate, required this.ref});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDate.isAtSameMomentAs(today);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.medium,
        vertical: Spacing.small,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeDate(-1),
            tooltip: '前日',
          ),
          GestureDetector(
            onTap: () => _resetToToday(),
            child: Column(
              children: [
                Text(
                  _formatDate(selectedDate),
                  style: AppTextStyles.titleSmall,
                ),
                if (!isToday)
                  Text(
                    'タップで今日に戻る',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                if (isToday)
                  Text(
                    '今日',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeDate(1),
            tooltip: '翌日',
          ),
        ],
      ),
    );
  }

  void _changeDate(int days) {
    final current = ref.read(selectedDateProvider);
    ref.read(selectedDateProvider.notifier).state = current.add(
      Duration(days: days),
    );
  }

  void _resetToToday() {
    final now = DateTime.now();
    ref.read(selectedDateProvider.notifier).state = DateTime(
      now.year,
      now.month,
      now.day,
    );
  }

  String _formatDate(DateTime date) {
    return DateFormatter.toJapaneseDateWithWeekday(date);
  }
}

class _Body extends StatelessWidget {
  final TodayTasksPageState state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state.viewState) {
      TodayTasksViewState.loading => const _LoadingView(),
      TodayTasksViewState.error => _ErrorView(error: state.errorMessage),
      TodayTasksViewState.empty => _EmptyView(),
      TodayTasksViewState.data => _ContentView(state: state),
    };
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return TodayTasksErrorWidget(error: error);
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.check_circle_outline,
      title: '今日のタスクはすべて完了！',
      message: 'お疲れさまでした！\nゆっくり休んでくださいね。',
      actionText: 'ホームに戻る',
      onActionPressed: () => AppRouter.navigateToHome(context),
    );
  }
}

class _ContentView extends StatelessWidget {
  final TodayTasksPageState state;

  const _ContentView({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(grouped: state.groupedTasks!),
          SizedBox(height: Spacing.sectionSpacing),
          _Content(state: state),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final GroupedTasks grouped;

  const _Header({required this.grouped});

  @override
  Widget build(BuildContext context) {
    return TodayTasksSummaryWidget(grouped: grouped);
  }
}

class _Content extends StatelessWidget {
  final TodayTasksPageState state;

  const _Content({required this.state});

  @override
  Widget build(BuildContext context) {
    final grouped = state.groupedTasks!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.showTodoSection) ...[
          TodayTasksSectionWidget(
            title: '未完了',
            tasks: grouped.todoTasks,
            color: AppColors.info,
          ),
          SizedBox(height: Spacing.sectionSpacing),
        ],
        if (state.showDoingSection) ...[
          TodayTasksSectionWidget(
            title: '進行中',
            tasks: grouped.doingTasks,
            color: AppColors.warning,
          ),
          SizedBox(height: Spacing.sectionSpacing),
        ],
        if (state.showDoneSection)
          TodayTasksSectionWidget(
            title: '完了',
            tasks: grouped.doneTasks,
            color: AppColors.success,
          ),
      ],
    );
  }
}
