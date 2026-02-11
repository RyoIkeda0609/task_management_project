import 'package:app/presentation/widgets/views/pyramid_view/pyramid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/views/calendar_view/calendar_view.dart';
import '../../../domain/entities/goal.dart';
import '../../state_management/providers/app_providers.dart';
import '../../navigation/app_router.dart';

/// ホーム画面
///
/// 3つの異なるビュー（リスト / ピラミッド / カレンダー）でゴール・マイルストーン・タスクを表示します。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ゴール管理'),
          backgroundColor: AppColors.neutral100,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: TabBar(
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
            ),
          ),
        ),
        body: goalsAsync.when(
          data: (goals) => _buildViewPager(context, ref, goals),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildErrorWidget(context, error),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => AppRouter.navigateToGoalCreate(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildViewPager(
    BuildContext context,
    WidgetRef ref,
    List<Goal> goals,
  ) {
    if (goals.isEmpty) {
      return TabBarView(
        children: [
          EmptyState(
            icon: Icons.flag_outlined,
            title: 'ゴールがまだありません',
            message: 'まずは今月のゴールを設定しましょう。',
            actionText: 'ゴールを作成',
            onActionPressed: () => AppRouter.navigateToGoalCreate(context),
          ),
          EmptyState(
            icon: Icons.flag_outlined,
            title: 'ゴールがまだありません',
            message: 'まずは今月のゴールを設定しましょう。',
            actionText: 'ゴールを作成',
            onActionPressed: () => AppRouter.navigateToGoalCreate(context),
          ),
          EmptyState(
            icon: Icons.flag_outlined,
            title: 'ゴールがまだありません',
            message: 'まずは今月のゴールを設定しましょう。',
            actionText: 'ゴールを作成',
            onActionPressed: () => AppRouter.navigateToGoalCreate(context),
          ),
        ],
      );
    }

    return TabBarView(
      children: [
        _buildListView(context, ref, goals),
        _buildPyramidViewTab(context, ref, goals),
        CalendarView(goals: goals),
      ],
    );
  }

  Widget _buildListView(BuildContext context, WidgetRef ref, List<Goal> goals) {
    // 期限の近い順でソート（期限の値で比較）
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
        return _buildGoalCard(context, ref, sortedGoals[index - 1]);
      },
    );
  }

  Widget _buildPyramidViewTab(
    BuildContext context,
    WidgetRef ref,
    List<Goal> goals,
  ) {
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
          error: (error, stackTrace) => _buildErrorWidget(context, error),
        );
      },
    );
  }

  Widget _buildGoalCard(BuildContext context, WidgetRef ref, Goal goal) {
    return InkWell(
      onTap: () => AppRouter.navigateToGoalDetail(context, goal.id.value),
      borderRadius: BorderRadius.circular(8),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトルとカテゴリを並べて表示
              Row(
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
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Spacing.small),
              // 説明
              Text(
                goal.reason.value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: Spacing.medium),
              // 進捗表示
              _buildGoalProgressSection(goal, ref),
              SizedBox(height: Spacing.medium),
              // 期限
              Text(
                '期限: ${_formatDate(goal.deadline.value)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ゴールの進捗セクション
  Widget _buildGoalProgressSection(Goal goal, WidgetRef ref) {
    final progressAsync = ref.watch(goalProgressProvider(goal.id.value));

    return progressAsync.when(
      data: (progress) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 進捗率テキスト
            Text(
              '進捗: ${progress.value}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: Spacing.xSmall),
            // 進捗バー
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.value / 100.0,
                minHeight: 8,
                backgroundColor: AppColors.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(progress.value),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 16,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stackTrace) => Text(
        '進捗読み込みエラー',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
    );
  }

  /// 進捗率に応じた色を取得
  Color _getProgressColor(int progressValue) {
    if (progressValue == 0) {
      return AppColors.neutral400;
    } else if (progressValue < 50) {
      return AppColors.primary;
    } else if (progressValue < 100) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  Widget _buildErrorWidget(BuildContext context, Object error) {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: 'ゴールがまだありません',
      message: '最初にゴールを作成してください。',
      actionText: 'ゴールを作成',
      onActionPressed: () => AppRouter.navigateToGoalCreate(context),
    );
  }
}
