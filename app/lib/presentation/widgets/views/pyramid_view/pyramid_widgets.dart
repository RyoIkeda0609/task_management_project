import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/goal.dart';
import '../../../../domain/entities/milestone.dart';
import '../../../../domain/entities/task.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../navigation/app_router.dart';
import 'pyramid_view_model.dart';

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
        onTap: () => AppRouter.navigateToGoalDetail(context, goal.id.value),
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

  const PyramidMilestoneNode({
    super.key,
    required this.milestone,
    required this.goalId,
    required this.milestoneTasks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelState = ref.watch(pyramidViewModelProvider);
    final viewModel = ref.read(pyramidViewModelProvider.notifier);
    final isExpanded =
        viewModelState.expandedMilestones[milestone.id.value] ?? false;

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
          child: ExpansionTile(
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
              viewModel.toggleMilestoneExpansion(milestone.id.value);
            },
            title: Row(
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
                  _formatDate(milestone.deadline.value),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
            trailing: GestureDetector(
              onTap: () => AppRouter.navigateToMilestoneDetail(
                context,
                goalId,
                milestone.id.value,
              ),
              child: Icon(
                Icons.arrow_forward,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.small,
                  vertical: Spacing.xxSmall,
                ),
                child: milestoneTasks.when(
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Spacing.xxSmall,
                        ),
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
                      itemBuilder: (context, index) =>
                          PyramidTaskNode(task: tasks[index]),
                    );
                  },
                  loading: () => Padding(
                    padding: EdgeInsets.symmetric(vertical: Spacing.xxSmall),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  error: (error, stackTrace) => Text(
                    'タスク取得エラー',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

/// ピラミッドのタスクノード
class PyramidTaskNode extends StatelessWidget {
  final Task task;

  const PyramidTaskNode({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Spacing.xSmall),
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.small,
        vertical: Spacing.xxSmall,
      ),
      decoration: BoxDecoration(
        color: _getTaskStatusColor(task.status.value),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _getStatusIcon(task.status.value),
          SizedBox(width: Spacing.small),
          Expanded(
            child: Text(
              task.title.value,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTaskStatusColor(String status) {
    switch (status) {
      case 'todo':
        return AppColors.neutral200.withValues(alpha: 0.5);
      case 'doing':
        return AppColors.warning.withValues(alpha: 0.1);
      case 'done':
        return AppColors.success.withValues(alpha: 0.1);
      default:
        return AppColors.neutral100;
    }
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'done':
        return Icon(Icons.check_circle, color: AppColors.success, size: 18);
      case 'doing':
        return Icon(
          Icons.radio_button_checked,
          color: AppColors.warning,
          size: 18,
        );
      default:
        return Icon(
          Icons.radio_button_unchecked,
          color: AppColors.neutral400,
          size: 18,
        );
    }
  }
}
