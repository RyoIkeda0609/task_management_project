import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/application/use_cases/task/get_tasks_grouped_by_status_use_case.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/empty_state.dart';
import '../../utils/validation_helper.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/value_objects/task/task_status.dart';
import '../../state_management/providers/app_providers.dart';
import '../../navigation/app_router.dart';

/// 今日のタスク画面
///
/// 本日中に完了すべきタスクを表示します。
/// ステータス別にタスクをグループ化して表示します。
class TodayTasksScreen extends ConsumerStatefulWidget {
  const TodayTasksScreen({super.key});

  @override
  ConsumerState<TodayTasksScreen> createState() => _TodayTasksScreenState();
}

class _TodayTasksScreenState extends ConsumerState<TodayTasksScreen> {
  @override
  Widget build(BuildContext context) {
    final groupedAsync = ref.watch(todayTasksGroupedProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: '今日のタスク',
        hasLeading: false,
        backgroundColor: AppColors.neutral100,
      ),
      body: groupedAsync.when(
        data: (grouped) => _buildContent(context, grouped),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(error),
      ),
    );
  }

  Widget _buildContent(BuildContext context, GroupedTasks grouped) {
    if (grouped.total == 0) {
      return EmptyState(
        icon: Icons.check_circle_outline,
        title: '今日のタスクはありません',
        message: '今日完了するタスクはすべて終わりました。\nお疲れ様でした！',
        actionText: 'ホームに戻る',
        onActionPressed: () => AppRouter.navigateToHome(context),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // サマリー
          _buildSummary(context, grouped),
          SizedBox(height: Spacing.medium),

          // 未完了タスク
          if (grouped.todoTasks.isNotEmpty) ...[
            _buildTaskSection(
              context,
              '未完了',
              grouped.todoTasks,
              AppColors.neutral400,
            ),
            SizedBox(height: Spacing.medium),
          ],

          // 進行中タスク
          if (grouped.doingTasks.isNotEmpty) ...[
            _buildTaskSection(
              context,
              '進行中',
              grouped.doingTasks,
              AppColors.warning,
            ),
            SizedBox(height: Spacing.medium),
          ],

          // 完了タスク
          if (grouped.doneTasks.isNotEmpty) ...[
            _buildTaskSection(
              context,
              '完了',
              grouped.doneTasks,
              AppColors.success,
            ),
            SizedBox(height: Spacing.medium),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, GroupedTasks grouped) {
    return Container(
      margin: EdgeInsets.all(Spacing.medium),
      padding: EdgeInsets.all(Spacing.medium),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('本日の進捗', style: AppTextStyles.labelLarge),
          SizedBox(height: Spacing.small),
          _buildProgressRow(grouped),
        ],
      ),
    );
  }

  Widget _buildProgressRow(GroupedTasks grouped) {
    return Row(
      children: [
        Expanded(child: _buildProgressDetails(grouped)),
        SizedBox(width: Spacing.medium),
        _buildPercentageBadge(grouped),
      ],
    );
  }

  Widget _buildProgressDetails(GroupedTasks grouped) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${grouped.completedCount} / ${grouped.total} 完了',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: Spacing.small),
        _buildProgressBar(grouped),
      ],
    );
  }

  Widget _buildProgressBar(GroupedTasks grouped) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: grouped.completionPercentage / 100,
        minHeight: 8,
        backgroundColor: AppColors.neutral200,
        valueColor: AlwaysStoppedAnimation(
          grouped.completionPercentage == 100
              ? AppColors.success
              : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildPercentageBadge(GroupedTasks grouped) {
    return Container(
      padding: EdgeInsets.all(Spacing.small),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${grouped.completionPercentage}%',
        style: AppTextStyles.headlineSmall.copyWith(
          color: grouped.completionPercentage == 100
              ? AppColors.success
              : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTaskSection(
    BuildContext context,
    String title,
    List<Task> tasks,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.medium),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: Spacing.small),
              Text('$title (${tasks.length})', style: AppTextStyles.titleSmall),
            ],
          ),
        ),
        SizedBox(height: Spacing.small),
        ...tasks.asMap().entries.map((entry) {
          final task = entry.value;
          return _buildTaskItem(context, task);
        }),
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.medium,
        vertical: Spacing.xSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleTaskStatus(task),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(Spacing.medium),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral200),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                // ステータスインジケーター（左側）
                _buildStatusIndicator(task.status),
                SizedBox(width: Spacing.small),
                // タスク情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title.value,
                        style: _isStatus(task.status, 'done')
                            ? AppTextStyles.bodyMedium.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.neutral500,
                              )
                            : AppTextStyles.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Spacing.small),
                // ステータスバッジ
                StatusBadge(
                  status: _mapTaskStatus(task.status),
                  size: BadgeSize.small,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(dynamic status) {
    Color color;
    IconData icon;

    if (_isStatus(status, 'done')) {
      color = AppColors.success;
      icon = Icons.check_circle;
    } else if (_isStatus(status, 'doing')) {
      color = AppColors.warning;
      icon = Icons.radio_button_checked;
    } else {
      color = AppColors.neutral400;
      icon = Icons.radio_button_unchecked;
    }

    return Icon(icon, color: color, size: 24);
  }

  Future<void> _toggleTaskStatus(Task task) async {
    try {
      final taskRepository = ref.read(taskRepositoryProvider);

      // ステータスをサイクル：todo → doing → done → todo
      final TaskStatus newTaskStatus;
      if (_isStatus(task.status, 'done')) {
        newTaskStatus = TaskStatus.todo();
      } else if (_isStatus(task.status, 'doing')) {
        newTaskStatus = TaskStatus.done();
      } else {
        // todo の場合
        newTaskStatus = TaskStatus.doing();
      }

      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        deadline: task.deadline,
        status: newTaskStatus,
        milestoneId: task.milestoneId,
      );

      // タスクを保存
      await taskRepository.saveTask(updatedTask);

      // プロバイダーキャッシュを無効化
      if (mounted) {
        ref.invalidate(todayTasksProvider);
        ref.invalidate(taskDetailProvider(task.id.value));
        ref.invalidate(tasksByMilestoneProvider(task.milestoneId));
      }

      if (mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'ステータス更新完了',
          message: 'タスク「${task.title.value}」のステータスを更新しました。',
        );
      }
    } catch (e) {
      if (mounted) {
        await ValidationHelper.handleException(
          context,
          e,
          customTitle: 'ステータス更新エラー',
          customMessage: 'ステータスの更新に失敗しました。',
        );
      }
    }
  }

  String _mapTaskStatus(dynamic status) {
    final statusStr = status?.toString() ?? 'unknown';
    if (statusStr.contains('done')) return 'done';
    if (statusStr.contains('doing')) return 'doing';
    return 'todo';
  }

  bool _isStatus(dynamic status, String target) {
    final statusStr = status?.toString() ?? 'unknown';
    return statusStr.contains(target);
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: Spacing.medium),
          Text('エラーが発生しました', style: AppTextStyles.titleMedium),
          SizedBox(height: Spacing.small),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.large),
            child: Text(
              error.toString(),
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
