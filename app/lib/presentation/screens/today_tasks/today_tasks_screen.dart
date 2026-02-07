import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/empty_state.dart';
import '../../../domain/entities/task.dart';
import '../../state_management/providers/app_providers.dart';
import '../../navigation/app_router.dart';

/// 今日のタスク画面
///
/// 本日中に完了すべきタスクを表示します。
/// ステータス別にタスクをグループ化して表示します。
class TodayTasksScreen extends ConsumerWidget {
  const TodayTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: '今日のタスク',
        hasLeading: false,
        backgroundColor: AppColors.neutral100,
      ),
      body: tasksAsync.when(
        data: (allTasks) => _buildContent(context, allTasks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(error),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Task> allTasks) {
    // 今日のタスクをフィルタリング
    final today = DateTime.now();
    final todayTasks = allTasks.where((task) {
      try {
        final deadline = task.deadline.value;
        return deadline.year == today.year &&
            deadline.month == today.month &&
            deadline.day == today.day;
      } catch (e) {
        return false;
      }
    }).toList();

    if (todayTasks.isEmpty) {
      return EmptyState(
        icon: Icons.check_circle_outline,
        title: '今日のタスクはありません',
        message: '今日完了するタスクはすべて終わりました。\nお疲れ様でした！',
        actionText: 'ホームに戻る',
        onActionPressed: () => AppRouter.navigateToHome(context),
      );
    }

    // ステータス別にグループ化
    final todoTasks = todayTasks
        .where((t) => _isStatus(t.status, 'todo'))
        .toList();
    final doingTasks = todayTasks
        .where((t) => _isStatus(t.status, 'doing'))
        .toList();
    final doneTasks = todayTasks
        .where((t) => _isStatus(t.status, 'done'))
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // サマリー
          _buildSummary(context, todayTasks.length, doneTasks.length),
          SizedBox(height: Spacing.medium),

          // 未完了タスク
          if (todoTasks.isNotEmpty) ...[
            _buildTaskSection(context, '未完了', todoTasks, AppColors.neutral400),
            SizedBox(height: Spacing.medium),
          ],

          // 進行中タスク
          if (doingTasks.isNotEmpty) ...[
            _buildTaskSection(context, '進行中', doingTasks, AppColors.warning),
            SizedBox(height: Spacing.medium),
          ],

          // 完了タスク
          if (doneTasks.isNotEmpty) ...[
            _buildTaskSection(context, '完了', doneTasks, AppColors.success),
            SizedBox(height: Spacing.medium),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, int total, int done) {
    final percentage = total > 0 ? (done / total * 100).toInt() : 0;

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$done / $total 完了',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: Spacing.small),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.neutral200,
                        valueColor: AlwaysStoppedAnimation(
                          percentage == 100
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Spacing.medium),
              Container(
                padding: EdgeInsets.all(Spacing.small),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentage%',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
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
          onTap: () => _navigateToTaskDetail(context, task.id.value),
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
                // チェックボックス
                _buildStatusCheckbox(task.status),
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

  Widget _buildStatusCheckbox(dynamic status) {
    final isDone = _isStatus(status, 'done');

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isDone ? AppColors.success : Colors.transparent,
        border: Border.all(
          color: isDone ? AppColors.success : AppColors.neutral300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isDone ? Icon(Icons.check, size: 16, color: Colors.white) : null,
    );
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

  void _navigateToTaskDetail(BuildContext context, String taskId) {
    AppRouter.navigateToTaskDetail(context, taskId);
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
