import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../../application/providers/use_case_providers.dart';
import '../../../application/use_cases/task/get_tasks_grouped_by_status_use_case.dart';
import '../../../domain/entities/task.dart';
import '../../state_management/providers/app_providers.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/common/status_badge.dart';
import '../../navigation/app_router.dart';

// ============ Summary Widget ============

class TodayTasksSummaryWidget extends StatelessWidget {
  final GroupedTasks grouped;

  const TodayTasksSummaryWidget({super.key, required this.grouped});

  @override
  Widget build(BuildContext context) {
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
          _buildProgressRow(),
        ],
      ),
    );
  }

  Widget _buildProgressRow() {
    return Row(
      children: [
        Expanded(child: _buildProgressDetails()),
        SizedBox(width: Spacing.medium),
        _buildPercentageBadge(),
      ],
    );
  }

  Widget _buildProgressDetails() {
    final progressPercentage = _calculateProgressPercentage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${grouped.doneTasks.length} / ${grouped.total} 完了',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: Spacing.small),
        _buildProgressBar(progressPercentage),
        SizedBox(height: Spacing.small),
        Text(
          '進捗: ${progressPercentage.toStringAsFixed(0)}%',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progressPercentage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progressPercentage / 100,
        minHeight: 8,
        backgroundColor: AppColors.neutral200,
        valueColor: AlwaysStoppedAnimation(
          _getProgressColor(progressPercentage),
        ),
      ),
    );
  }

  Widget _buildPercentageBadge() {
    final progressPercentage = _calculateProgressPercentage();

    return Container(
      padding: EdgeInsets.all(Spacing.small),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${progressPercentage.toStringAsFixed(0)}%',
        style: AppTextStyles.headlineSmall.copyWith(
          color: _getProgressColor(progressPercentage),
        ),
      ),
    );
  }

  double _calculateProgressPercentage() {
    if (grouped.total == 0) return 0.0;
    return ((grouped.doingTasks.length * 50 + grouped.doneTasks.length * 100) /
        (grouped.total * 100)) *
        100;
  }

  Color _getProgressColor(double progressPercentage) {
    if (progressPercentage == 100) {
      return AppColors.success;
    } else if (progressPercentage >= 50) {
      return AppColors.warning;
    } else {
      return AppColors.primary;
    }
  }
}

// ============ Section Widget ============

class TodayTasksSectionWidget extends ConsumerWidget {
  final String title;
  final List<Task> tasks;
  final Color color;

  const TodayTasksSectionWidget({
    super.key,
    required this.title,
    required this.tasks,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(),
        SizedBox(height: Spacing.small),
        ...tasks.map((task) => TodayTaskItemWidget(task: task)),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
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
    );
  }
}

// ============ Task Item Widget ============

class TodayTaskItemWidget extends ConsumerWidget {
  final Task task;

  const TodayTaskItemWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.medium,
        vertical: Spacing.xSmall,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral200),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            _buildStatusIndicator(context, ref),
            SizedBox(width: Spacing.small),
            _buildTaskInfo(context),
            SizedBox(width: Spacing.small),
            _buildStatusBadge(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, WidgetRef ref) {
    return Expanded(
      flex: 0,
      child: GestureDetector(
        onTap: () => _toggleTaskStatus(context, ref),
        child: Container(
          padding: EdgeInsets.all(Spacing.medium),
          child: Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfo(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => AppRouter.navigateToTaskDetail(context, task.id.value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Spacing.medium),
          child: Text(
            task.title.value,
            style: _getTaskTextStyle(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, WidgetRef ref) {
    return Expanded(
      flex: 0,
      child: GestureDetector(
        onTap: () => _toggleTaskStatus(context, ref),
        child: Container(
          padding: EdgeInsets.all(Spacing.medium),
          child: StatusBadge(
            status: _normalizeTaskStatus(),
            size: BadgeSize.small,
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    final statusStr = task.status.toString();
    if (statusStr.contains('done')) {
      return Icons.check_circle;
    } else if (statusStr.contains('doing')) {
      return Icons.radio_button_checked;
    } else {
      return Icons.radio_button_unchecked;
    }
  }

  Color _getStatusColor() {
    final statusStr = task.status.toString();
    if (statusStr.contains('done')) {
      return AppColors.success;
    } else if (statusStr.contains('doing')) {
      return AppColors.warning;
    } else {
      return AppColors.neutral400;
    }
  }

  TextStyle _getTaskTextStyle() {
    final statusStr = task.status.toString();
    if (statusStr.contains('done')) {
      return AppTextStyles.bodyMedium.copyWith(
        decoration: TextDecoration.lineThrough,
        color: AppColors.neutral500,
      );
    } else {
      return AppTextStyles.bodyMedium;
    }
  }

  String _normalizeTaskStatus() {
    final statusStr = task.status.toString();
    if (statusStr.contains('done')) return 'done';
    if (statusStr.contains('doing')) return 'doing';
    return 'todo';
  }

  Future<void> _toggleTaskStatus(BuildContext context, WidgetRef ref) async {
    try {
      final changeTaskStatusUseCase =
          ref.read(changeTaskStatusUseCaseProvider);
      await changeTaskStatusUseCase(task.id.value);

      ref.invalidate(todayTasksProvider);
      ref.invalidate(taskDetailProvider(task.id.value));
      ref.invalidate(tasksByMilestoneProvider(task.milestoneId));

      if (context.mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'ステータス更新完了',
          message: 'タスク「${task.title.value}」のステータスを更新しました。',
        );
      }
    } catch (e) {
      if (context.mounted) {
        await ValidationHelper.handleException(
          context,
          e,
          customTitle: 'ステータス更新エラー',
          customMessage: 'ステータスの更新に失敗しました。',
        );
      }
    }
  }
}

// ============ Error Widget ============

class TodayTasksErrorWidget extends StatelessWidget {
  final Object error;

  const TodayTasksErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
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
