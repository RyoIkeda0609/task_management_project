import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/status_badge.dart';
import '../../../navigation/app_router.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../../application/providers/use_case_providers.dart';
import '../../../../domain/entities/milestone.dart';
import '../../../../domain/entities/task.dart';
import '../../../../domain/value_objects/task/task_status.dart';
import '../../../utils/date_formatter.dart';

class MilestoneDetailHeaderWidget extends StatelessWidget {
  final Milestone milestone;

  const MilestoneDetailHeaderWidget({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(milestone.title.value, style: AppTextStyles.headlineMedium),
          SizedBox(height: Spacing.medium),
          _buildMilestoneInfo(milestone),
        ],
      ),
    );
  }

  Widget _buildMilestoneInfo(Milestone milestone) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(Radii.medium),
      ),
      child: Text(
        '目標日時: ${DateFormatter.toJapaneseDate(milestone.deadline.value)}',
        style: AppTextStyles.bodyMedium,
      ),
    );
  }
}

class MilestoneDetailTasksSection extends ConsumerWidget {
  final String milestoneId;
  final Milestone milestone;

  const MilestoneDetailTasksSection({
    super.key,
    required this.milestoneId,
    required this.milestone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByMilestoneProvider(milestoneId));

    return tasksAsync.when(
      data: (tasks) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.medium),
            child: Text('タスク', style: AppTextStyles.labelLarge),
          ),
          SizedBox(height: Spacing.small),
          if (tasks.isEmpty)
            _buildTasksEmpty(context, milestone)
          else
            _buildTasksList(context, ref, tasks, milestone),
        ],
      ),
      loading: () => Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _buildErrorWidget(error),
    );
  }

  Widget _buildTasksEmpty(BuildContext context, Milestone milestone) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.medium,
        vertical: Spacing.large,
      ),
      child: EmptyState(
        icon: Icons.assignment_outlined,
        title: 'まだタスクがありません',
        message: 'まずは一つ決めてみましょう。',
      ),
    );
  }

  Widget _buildTasksList(
    BuildContext context,
    WidgetRef ref,
    List<Task> tasks,
    Milestone milestone,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.medium,
            vertical: Spacing.xSmall,
          ),
          child: _buildTaskItem(context, ref, task, milestone),
        );
      },
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    WidgetRef ref,
    Task task,
    Milestone milestone,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToTaskDetail(
          context,
          task.itemId.value,
          milestone.goalId.value,
        ),
        borderRadius: BorderRadius.circular(Radii.medium),
        child: Container(
          padding: EdgeInsets.all(Spacing.medium),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(Radii.medium),
          ),
          child: Row(
            children: [
              _buildTaskStatusIcon(task.status),
              SizedBox(width: Spacing.small),
              Expanded(child: _buildTaskInfo(task)),
              SizedBox(width: Spacing.small),
              StatusBadge(status: task.status, size: BadgeSize.small),
              SizedBox(width: Spacing.small),
              _buildTaskMenu(context, ref, task),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfo(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title.value,
          style: AppTextStyles.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: Spacing.xSmall),
        Text(
          DateFormatter.toJapaneseDate(task.deadline.value),
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral500),
        ),
      ],
    );
  }

  Widget _buildTaskMenu(BuildContext context, WidgetRef ref, Task task) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          child: const Text('ステータス変更'),
          onTap: () async {
            await _changeTaskStatus(ref, task);
          },
        ),
        PopupMenuItem(
          child: Text(
            '削除',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
          ),
          onTap: () {
            _showDeleteTaskDialog(context, ref, task);
          },
        ),
      ],
    );
  }

  Future<void> _changeTaskStatus(WidgetRef ref, Task task) async {
    final changeTaskStatusUseCase = ref.read(changeTaskStatusUseCaseProvider);
    await changeTaskStatusUseCase(task.itemId.value);

    // State を再取得
    ref.invalidate(milestoneDetailProvider(task.milestoneId.value));
    ref.invalidate(tasksByMilestoneProvider(task.milestoneId.value));
  }

  Widget _buildTaskStatusIcon(TaskStatus status) {
    return switch (status) {
      TaskStatus.done => _buildStatusIconBox(AppColors.success, Icons.check),
      TaskStatus.doing => _buildStatusIconBox(
        AppColors.warning,
        Icons.schedule,
      ),
      TaskStatus.todo => _buildStatusIconBox(
        AppColors.neutral400,
        Icons.circle_outlined,
      ),
    };
  }

  Widget _buildStatusIconBox(Color color, IconData icon) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Radii.small),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }

  void _navigateToTaskDetail(
    BuildContext context,
    String taskId,
    String goalId,
  ) {
    AppRouter.navigateToTaskDetailFromMilestone(
      context,
      goalId,
      milestoneId,
      taskId,
    );
  }

  void _showDeleteTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('タスク削除'),
        content: Text('「${task.title.value}」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _executeDeleteTask(context, ref, task);
            },
            child: Text(
              '削除',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeDeleteTask(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    try {
      final deleteTaskUseCase = ref.read(deleteTaskUseCaseProvider);
      await deleteTaskUseCase(task.itemId.value);
      ref.invalidate(tasksByMilestoneProvider(milestoneId));

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('タスクを削除しました')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('削除に失敗しました: $e')));
    }
  }

  Widget _buildErrorWidget(Object error) {
    return MilestoneDetailErrorWidget(error: error);
  }
}

/// マイルストーン詳細エラー表示ウィジェット
///
/// GoalDetailErrorWidget / TaskDetailErrorWidget と同一パターン
class MilestoneDetailErrorWidget extends StatelessWidget {
  final Object error;

  const MilestoneDetailErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          SizedBox(height: Spacing.medium),
          Text('エラーが発生しました', style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }
}
