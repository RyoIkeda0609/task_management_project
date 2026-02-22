import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/goal.dart';
import '../../../../domain/entities/milestone.dart';
import '../../../../domain/entities/task.dart';
import '../../../../domain/value_objects/task/task_status.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../navigation/app_router.dart';
import 'pyramid_view_model.dart';
import '../../../utils/date_formatter.dart';

/// ピラミッドのゴールノード
class PyramidGoalNode extends StatelessWidget {
  final Goal goal;

  const PyramidGoalNode({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Spacing.medium),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => AppRouter.navigateToGoalDetail(context, goal.itemId.value),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(Spacing.medium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  goal.title.value,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: Spacing.small),
              Icon(Icons.arrow_forward, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// ピラミッドのマイルストーンノード
class PyramidMilestoneNode extends ConsumerWidget {
  final Milestone milestone;
  final String goalId;
  final AsyncValue<List<Task>> milestoneTasks;
  final void Function(Task task)? onTaskTap;

  const PyramidMilestoneNode({
    super.key,
    required this.milestone,
    required this.goalId,
    required this.milestoneTasks,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelState = ref.watch(pyramidViewModelProvider);
    final viewModel = ref.read(pyramidViewModelProvider.notifier);
    final isExpanded =
        viewModelState.expandedMilestones[milestone.itemId.value] ?? false;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: Spacing.xxSmall),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            border: Border(
              left: BorderSide(color: AppColors.primaryLight, width: 4),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: _buildExpansionTile(context, isExpanded, viewModel),
        ),
      ],
    );
  }

  Widget _buildExpansionTile(
    BuildContext context,
    bool isExpanded,
    PyramidViewModel viewModel,
  ) {
    return ExpansionTile(
      tilePadding: EdgeInsets.symmetric(
        horizontal: Spacing.small,
        vertical: Spacing.xxSmall,
      ),
      childrenPadding: EdgeInsets.only(
        left: Spacing.small,
        right: Spacing.small,
        bottom: Spacing.xxSmall,
      ),
      initiallyExpanded: isExpanded,
      onExpansionChanged: (_) {
        viewModel.toggleMilestoneExpansion(milestone.itemId.value);
      },
      title: _buildMilestoneTitle(),
      trailing: _buildMilestoneTrailing(context),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.small,
            vertical: Spacing.xxSmall,
          ),
          child: _buildTaskList(),
        ),
      ],
    );
  }

  Widget _buildMilestoneTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            milestone.title.value,
            style: AppTextStyles.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: Spacing.small),
        Text(
          DateFormatter.toJapaneseDate(milestone.deadline.value),
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600),
        ),
      ],
    );
  }

  Widget _buildMilestoneTrailing(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRouter.navigateToMilestoneDetail(
        context,
        goalId,
        milestone.itemId.value,
      ),
      child: Icon(Icons.arrow_forward, size: 18, color: AppColors.primary),
    );
  }

  Widget _buildTaskList() {
    return milestoneTasks.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.xxSmall),
            child: Text(
              'タスクなし',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neutral500,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return PyramidTaskNode(
              task: task,
              onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
            );
          },
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.xxSmall),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
      error: (error, stackTrace) => Text(
        'タスク取得エラー',
        style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
      ),
    );
  }

}

/// ピラミッドのタスクノード
class PyramidTaskNode extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const PyramidTaskNode({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: Spacing.xSmall),
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.small,
          vertical: Spacing.xxSmall,
        ),
        decoration: BoxDecoration(
          color: _getTaskStatusColor(task.status),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _getStatusIcon(task.status),
            SizedBox(width: Spacing.small),
            Expanded(
              child: Text(
                task.title.value,
                style: AppTextStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 16, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }

  Color _getTaskStatusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.todo => AppColors.neutral200.withValues(alpha: 0.5),
      TaskStatus.doing => AppColors.warning.withValues(alpha: 0.1),
      TaskStatus.done => AppColors.success.withValues(alpha: 0.1),
    };
  }

  Widget _getStatusIcon(TaskStatus status) {
    return switch (status) {
      TaskStatus.done => Icon(
        Icons.check_circle,
        color: AppColors.success,
        size: 18,
      ),
      TaskStatus.doing => Icon(
        Icons.radio_button_checked,
        color: AppColors.warning,
        size: 18,
      ),
      TaskStatus.todo => Icon(
        Icons.radio_button_unchecked,
        color: AppColors.neutral400,
        size: 18,
      ),
    };
  }
}
