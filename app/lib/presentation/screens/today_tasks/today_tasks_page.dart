import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../state_management/providers/app_providers.dart';
import '../../navigation/app_router.dart';
import '../../widgets/common/empty_state.dart';
import '../../../application/use_cases/task/get_tasks_grouped_by_status_use_case.dart';
import 'today_tasks_widgets.dart';
import 'today_tasks_state.dart';

/// 今日のタスク画面
///
/// 本日中に完了すべきタスクを表示します。
/// ステータス別にタスクをグループ化して表示します。
class TodayTasksPage extends ConsumerWidget {
  const TodayTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(todayTasksGroupedProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: '今日のタスク',
        hasLeading: false,
        backgroundColor: AppColors.neutral100,
      ),
      body: groupedAsync.when(
        data: (grouped) => _Body(state: TodayTasksPageState.withData(grouped)),
        loading: () => _Body(state: TodayTasksPageState.loading()),
        error: (error, stackTrace) =>
            _Body(state: TodayTasksPageState.withError(error.toString())),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final TodayTasksPageState state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state.viewState) {
      TodayTasksViewState.loading => const _LoadingView(),
      TodayTasksViewState.error => _ErrorView(
        error: state.errorMessage ?? 'Unknown error',
      ),
      TodayTasksViewState.empty => _EmptyView(),
      TodayTasksViewState.data => _ContentView(grouped: state.groupedTasks!),
    };
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
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
      title: '今日のタスクはありません',
      message: '今日完了するタスクはすべて終わりました。\nお疲れ様でした！',
      actionText: 'ホームに戻る',
      onActionPressed: () => AppRouter.navigateToHome(context),
    );
  }
}

class _ContentView extends StatelessWidget {
  final GroupedTasks grouped;

  const _ContentView({required this.grouped});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(grouped: grouped),
        SizedBox(height: Spacing.medium),
        _Content(grouped: grouped),
      ],
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
  final GroupedTasks grouped;

  const _Content({required this.grouped});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (grouped.todoTasks.isNotEmpty)
            TodayTasksSectionWidget(
              title: '未完了',
              tasks: grouped.todoTasks,
              color: AppColors.neutral400,
            ),
          if (grouped.todoTasks.isNotEmpty) SizedBox(height: Spacing.medium),
          if (grouped.doingTasks.isNotEmpty)
            TodayTasksSectionWidget(
              title: '進行中',
              tasks: grouped.doingTasks,
              color: AppColors.warning,
            ),
          if (grouped.doingTasks.isNotEmpty) SizedBox(height: Spacing.medium),
          if (grouped.doneTasks.isNotEmpty)
            TodayTasksSectionWidget(
              title: '完了',
              tasks: grouped.doneTasks,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }
}
