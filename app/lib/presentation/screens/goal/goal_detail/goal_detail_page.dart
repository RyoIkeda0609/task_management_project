import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/presentation/theme/app_text_styles.dart';
import 'package:app/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/dialog_helper.dart';
import '../../../navigation/app_router.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../home/home_view_model.dart';
import '../../../utils/validation_helper.dart';
import '../../../utils/date_formatter.dart';
import '../../../../application/providers/use_case_providers.dart';
import '../../../widgets/views/pyramid_view/pyramid_widgets.dart';
import '../../../widgets/views/calendar_view/calendar_view_model.dart';
import '../../../widgets/views/calendar_view/calendar_state.dart';
import '../../../widgets/views/calendar_view/calendar_widgets.dart';
import '../../../widgets/common/empty_state.dart';
import 'goal_detail_state.dart';
import 'goal_detail_widgets.dart';

/// ゴール詳細画面
///
/// タブ構成：概要 / ピラミッド / カレンダー
///
/// 責務：
/// - Scaffold と Provider の接続
/// - タブ切り替え配線
/// - ナビゲーション処理
class GoalDetailPage extends ConsumerWidget {
  final String goalId;

  const GoalDetailPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailProvider(goalId));
    final milestonesAsync = ref.watch(milestonesByGoalProvider(goalId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _GoalDetailAppBar(
          goalId: goalId,
          goalAsync: goalAsync,
          onDelete: (goal) => _showDeleteConfirmation(context, ref, goal),
        ),
        body: _buildBody(goalAsync, milestonesAsync),
        floatingActionButton: FloatingActionButton(
          onPressed: () => AppRouter.navigateToMilestoneCreate(context, goalId),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<Goal?> goalAsync,
    AsyncValue<List<Milestone>> milestonesAsync,
  ) {
    return goalAsync.when(
      data: (goal) => _Body(
        state: GoalDetailPageState.withData(goal),
        goalId: goalId,
        milestonesAsync: milestonesAsync,
      ),
      loading: () => _Body(
        state: GoalDetailPageState.loading(),
        goalId: goalId,
        milestonesAsync: milestonesAsync,
      ),
      error: (error, stackTrace) => _Body(
        state: GoalDetailPageState.withError(error.toString()),
        goalId: goalId,
        milestonesAsync: milestonesAsync,
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
    final confirmed = await DialogHelper.showDeleteConfirmDialog(
      context,
      title: '本当に削除しますか？',
      message: 'ゴール「${goal.title.value}」を削除します。配下のマイルストーンとタスクもすべて削除されます。',
    );

    if (confirmed == true && context.mounted) {
      try {
        final deleteGoalUseCase = ref.read(deleteGoalUseCaseProvider);
        await deleteGoalUseCase(goalId);

        // Provider キャッシュを無効化
        ref.invalidate(goalsProvider);
        ref.invalidate(goalDetailProvider(goalId));
        ref.invalidate(homeViewModelProvider);

        if (context.mounted) {
          await ValidationHelper.showSuccess(
            context,
            title: 'ゴール削除完了',
            message: 'ゴール「${goal.title.value}」を削除しました。',
          );
        }
        if (context.mounted) {
          AppRouter.navigateToHome(context);
        }
      } catch (e) {
        if (context.mounted) {
          await ValidationHelper.showExceptionError(
            context,
            e,
            customTitle: 'ゴール削除エラー',
            customMessage: 'ゴールの削除に失敗しました。',
          );
        }
      }
    }
  }
}

// ============ AppBar with Tabs ============

class _GoalDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String goalId;
  final AsyncValue<Goal?> goalAsync;
  final void Function(Goal goal) onDelete;

  const _GoalDetailAppBar({
    required this.goalId,
    required this.goalAsync,
    required this.onDelete,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('ゴール詳細', style: AppTextStyles.headlineLarge),
      backgroundColor: AppColors.neutral100,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: _buildActions(context),
      surfaceTintColor: Colors.transparent,
      bottom: _buildTabBar(),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => goalAsync.whenData((goal) {
          if (goal != null) AppRouter.navigateToGoalEdit(context, goalId);
        }),
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => goalAsync.whenData((goal) {
          if (goal != null) onDelete(goal);
        }),
      ),
    ];
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      labelStyle: AppTextStyles.labelMedium,
      unselectedLabelStyle: AppTextStyles.labelSmall,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.neutral600,
      dividerColor: AppColors.neutral200,
      tabs: const [
        Tab(text: '概要'),
        Tab(text: 'ピラミッド'),
        Tab(text: 'カレンダー'),
      ],
    );
  }
}

// ============ Body ============

class _Body extends StatelessWidget {
  final GoalDetailPageState state;
  final String goalId;
  final AsyncValue<List<Milestone>> milestonesAsync;

  const _Body({
    required this.state,
    required this.goalId,
    required this.milestonesAsync,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state.viewState) {
      GoalDetailViewState.loading => const _LoadingView(),
      GoalDetailViewState.notFound => _NotFoundView(),
      GoalDetailViewState.error => _ErrorView(error: state.errorMessage),
      GoalDetailViewState.data => _ContentView(
        goal: state.goal!,
        goalId: goalId,
        milestonesAsync: milestonesAsync,
      ),
    };
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('ゴールが見つかりません', style: AppTextStyles.titleMedium));
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return GoalDetailErrorWidget(error: error);
  }
}

// ============ Content View with Tabs ============

class _ContentView extends ConsumerWidget {
  final Goal goal;
  final String goalId;
  final AsyncValue<List<Milestone>> milestonesAsync;

  const _ContentView({
    required this.goal,
    required this.goalId,
    required this.milestonesAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBarView(
      children: [
        // タブ1: 概要
        _OverviewTab(goal: goal, goalId: goalId),
        // タブ2: ピラミッド
        _PyramidTab(
          goal: goal,
          goalId: goalId,
          milestonesAsync: milestonesAsync,
        ),
        // タブ3: カレンダー
        _CalendarTab(goalId: goalId),
      ],
    );
  }
}

// ============ Tab 1: 概要 ============

class _OverviewTab extends StatelessWidget {
  final Goal goal;
  final String goalId;

  const _OverviewTab({required this.goal, required this.goalId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: GoalDetailHeaderWidget(goal: goal, goalId: goalId),
      ),
    );
  }
}

// ============ Tab 2: ピラミッド ============

class _PyramidTab extends ConsumerWidget {
  final Goal goal;
  final String goalId;
  final AsyncValue<List<Milestone>> milestonesAsync;

  const _PyramidTab({
    required this.goal,
    required this.goalId,
    required this.milestonesAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return milestonesAsync.when(
      data: (milestones) => _buildMilestoneList(context, ref, milestones),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('読み込みエラー: $error')),
    );
  }

  Widget _buildMilestoneList(
    BuildContext context,
    WidgetRef ref,
    List<Milestone> milestones,
  ) {
    if (milestones.isEmpty) {
      return EmptyState(
        icon: Icons.account_tree_outlined,
        title: 'マイルストーンがありません',
        message: 'マイルストーンを追加してゴールを達成しましょう。',
        actionText: 'マイルストーン追加',
        onActionPressed: () =>
            AppRouter.navigateToMilestoneCreate(context, goalId),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(Spacing.medium),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        return PyramidMilestoneNode(
          milestone: milestone,
          goalId: goalId,
          milestoneTasks: ref.watch(
            tasksByMilestoneProvider(milestone.itemId.value),
          ),
          onTaskTap: (task) {
            context.push(
              '/home/goal/$goalId/milestone/${task.milestoneId.value}/task/${task.itemId.value}',
            );
          },
        );
      },
    );
  }
}

// ============ Tab 3: カレンダー ============

class _CalendarTab extends ConsumerWidget {
  final String goalId;

  const _CalendarTab({required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByGoalProvider(goalId));
    final state = ref.watch(goalCalendarViewModelProvider(goalId));
    final viewModel = ref.read(goalCalendarViewModelProvider(goalId).notifier);

    // タスクが更新されたときにキャッシュを再構築
    ref.listen(tasksByGoalProvider(goalId), (previous, next) {
      next.whenData((tasks) {
        viewModel.buildTasksCache(tasks);
      });
    });

    // 初回データロード時のキャッシュ構築
    tasksAsync.whenData((tasks) {
      if (state.tasksCache.isEmpty && tasks.isNotEmpty) {
        Future.microtask(() => viewModel.buildTasksCache(tasks));
      }
    });

    return tasksAsync.when(
      data: (_) => _buildCalendar(state, viewModel),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('エラー: $error')),
    );
  }

  Widget _buildCalendar(CalendarPageState state, CalendarViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CalendarMonthNavigator(
            onPreviousMonth: viewModel.previousMonth,
            onNextMonth: viewModel.nextMonth,
            monthDisplayText: DateFormatter.toJapaneseMonth(
              state.displayedMonth,
            ),
          ),
          CalendarGrid(
            displayedMonth: state.displayedMonth,
            selectedDate: state.selectedDate,
            onDateSelected: viewModel.selectDate,
            getTasksForDate: state.getTasksForDate,
          ),
          _GoalCalendarTaskList(
            goalId: goalId,
            selectedDate: state.selectedDate,
            tasks: state.getTasksForDate(state.selectedDate),
            selectedDateDisplayText: DateFormatter.toJapaneseDateTaskHeader(
              state.selectedDate,
            ),
          ),
        ],
      ),
    );
  }
}

/// ゴール詳細カレンダー用タスクリスト（push ナビゲーション）
class _GoalCalendarTaskList extends StatelessWidget {
  final String goalId;
  final DateTime selectedDate;
  final List<Task> tasks;
  final String selectedDateDisplayText;

  const _GoalCalendarTaskList({
    required this.goalId,
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
          _buildTaskContent(context),
        ],
      ),
    );
  }

  Widget _buildTaskContent(BuildContext context) {
    if (tasks.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.large),
        child: Center(
          child: Text(
            'この日のタスクはありません',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
      );
    }
    return Column(
      children: tasks.map((task) {
        return CalendarTaskItem(
          task: task,
          onTap: () {
            context.push(
              '/home/goal/$goalId/milestone/${task.milestoneId.value}/task/${task.itemId.value}',
            );
          },
        );
      }).toList(),
    );
  }
}
