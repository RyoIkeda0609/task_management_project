import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/views/pyramid_view.dart';
import '../../widgets/views/calendar_view.dart';
import '../../state_management/providers/app_providers.dart';
import 'home_state.dart';
import 'home_view_model.dart';

// ============ AppBar ============

/// ホーム画面の AppBar（TabBar 付き）
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('ゴール管理'),
      backgroundColor: AppColors.neutral100,
      elevation: 0,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: _HomeTabBar(),
      ),
    );
  }
}

/// ホーム画面の TabBar
class _HomeTabBar extends StatelessWidget {
  const _HomeTabBar();

  @override
  Widget build(BuildContext context) {
    return TabBar(
      labelStyle: AppTextStyles.labelMedium,
      unselectedLabelStyle: AppTextStyles.labelSmall,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.neutral600,
      dividerColor: AppColors.neutral200,
      tabs: const [
        Tab(icon: Icon(Icons.list), child: Text('リスト')),
        Tab(icon: Icon(Icons.account_tree), child: Text('ピラミッド')),
        Tab(icon: Icon(Icons.calendar_today), child: Text('カレンダー')),
      ],
    );
  }
}

// ============ List View ============

/// ゴールリストビュー
class GoalListView extends ConsumerWidget {
  final List<Goal> goals;
  final VoidCallback onCreatePressed;

  const GoalListView({
    super.key,
    required this.goals,
    required this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortedGoals = [...goals]
      ..sort((a, b) => a.deadline.value.compareTo(b.deadline.value));

    return ListView.builder(
      padding: EdgeInsets.all(Spacing.medium),
      itemCount: sortedGoals.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: Spacing.small),
            child: Text(
              '期限が近い順に表示',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
            ),
          );
        }
        return GoalCard(
          goal: sortedGoals[index - 1],
          onTap: () => onGoalCardTapped(context, sortedGoals[index - 1]),
        );
      },
    );
  }

  void onGoalCardTapped(BuildContext context, Goal goal) {
    // ナビゲーションは外側で処理
    Navigator.pushNamed(context, '/home/goal/${goal.id.value}');
  }
}

/// ゴールカード
class GoalCard extends ConsumerWidget {
  final Goal goal;
  final VoidCallback onTap;

  const GoalCard({super.key, required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GoalCardHeader(goal: goal),
              SizedBox(height: Spacing.small),
              _GoalCardReason(reason: goal.reason.value),
              SizedBox(height: Spacing.medium),
              _GoalCardProgress(goalId: goal.id.value),
              SizedBox(height: Spacing.medium),
              _GoalCardDeadline(deadline: goal.deadline.value),
            ],
          ),
        ),
      ),
    );
  }
}

/// ゴールカード - ヘッダー（タイトル + カテゴリ）
class _GoalCardHeader extends StatelessWidget {
  final Goal goal;

  const _GoalCardHeader({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            goal.title.value,
            style: AppTextStyles.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: Spacing.small),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.xSmall,
            vertical: Spacing.xSmall,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            goal.category.value,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

/// ゴールカード - 理由説明
class _GoalCardReason extends StatelessWidget {
  final String reason;

  const _GoalCardReason({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Text(
      reason,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// ゴールカード - 進捗セクション
class _GoalCardProgress extends ConsumerWidget {
  final String goalId;

  const _GoalCardProgress({required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(goalProgressProvider(goalId));
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return progressAsync.when(
      data: (progress) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '進捗: ${progress.value}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: Spacing.xSmall),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.value / 100.0,
                minHeight: 8,
                backgroundColor: AppColors.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  viewModel.getProgressColor(progress.value),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => SizedBox(
        height: 16,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, _) => Text(
        '進捗読み込みエラー',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
    );
  }
}

/// ゴールカード - 期限
class _GoalCardDeadline extends StatelessWidget {
  final DateTime deadline;

  const _GoalCardDeadline({required this.deadline});

  @override
  Widget build(BuildContext context) {
    return Text(
      '期限: ${_formatDate(deadline)}',
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

// ============ Pyramid View ============

/// ピラミッドビュー（マイルストーン表示）
class GoalPyramidView extends ConsumerWidget {
  final List<Goal> goals;

  const GoalPyramidView({super.key, required this.goals});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: EdgeInsets.all(Spacing.medium),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final milestonesAsync = ref.watch(
          milestonsByGoalProvider(goal.id.value),
        );

        return milestonesAsync.when(
          data: (milestones) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: Spacing.medium),
                child: Text(
                  goal.title.value,
                  style: AppTextStyles.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: Spacing.large),
                child: PyramidView(goal: goal, milestones: milestones),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorView('ピラミッドビュー読み込みエラー'),
        );
      },
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
    );
  }
}

// ============ Empty / Error States ============

/// ゴールがない場合のビュー
class GoalEmptyView extends StatelessWidget {
  final VoidCallback onCreatePressed;

  const GoalEmptyView({super.key, required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        _buildEmptyTab(onCreatePressed),
        _buildEmptyTab(onCreatePressed),
        _buildEmptyTab(onCreatePressed),
      ],
    );
  }

  Widget _buildEmptyTab(VoidCallback onCreatePressed) {
    return EmptyState(
      icon: Icons.flag_outlined,
      title: 'ゴールがまだありません',
      message: 'まずは今月のゴールを設定しましょう。',
      actionText: 'ゴールを作成',
      onActionPressed: onCreatePressed,
    );
  }
}

/// エラーが起きた場合のビュー
class GoalErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onCreatePressed;

  const GoalErrorView({
    super.key,
    required this.errorMessage,
    required this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: 'ゴールを読み込めませんでした',
      message: errorMessage,
      actionText: 'ゴールを作成',
      onActionPressed: onCreatePressed,
    );
  }
}

// ============ Main Content ============

/// ホーム画面のメインコンテンツ
class HomeContent extends ConsumerWidget {
  final HomePageState state;
  final VoidCallback onCreatePressed;

  const HomeContent({
    super.key,
    required this.state,
    required this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isError) {
      return GoalErrorView(
        errorMessage: state.errorMessage ?? 'エラーが発生しました',
        onCreatePressed: onCreatePressed,
      );
    }

    if (state.isEmpty) {
      return GoalEmptyView(onCreatePressed: onCreatePressed);
    }

    return DefaultTabController(
      length: 3,
      child: TabBarView(
        children: [
          GoalListView(goals: state.goals, onCreatePressed: onCreatePressed),
          GoalPyramidView(goals: state.goals),
          CalendarView(goals: state.goals),
        ],
      ),
    );
  }
}
