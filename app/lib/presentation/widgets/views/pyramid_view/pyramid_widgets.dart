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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ゴール',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: Spacing.xSmall),
                        Text(
                          goal.title.value,
                          style: AppTextStyles.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: AppColors.primary),
                ],
              ),
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
          margin: EdgeInsets.only(bottom: Spacing.small),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            border: Border(
              left: BorderSide(color: AppColors.primaryLight, width: 4),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ExpansionTile(
            initiallyExpanded: isExpanded,
            onExpansionChanged: (_) {
              viewModel.toggleMilestoneExpansion(milestone.id.value);
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title.value,
                  style: AppTextStyles.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Spacing.xSmall),
                Text(
                  '期限: ${_formatDate(milestone.deadline.value)}',
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
              child: Container(
                padding: EdgeInsets.all(Spacing.xSmall),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(Spacing.medium),
                child: milestoneTasks.when(
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: Spacing.small),
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
                    padding: EdgeInsets.symmetric(vertical: Spacing.small),
                    child: const CircularProgressIndicator(strokeWidth: 2),
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
    return '${date.year}年${date.month}月${date.day}日';
  }
}

/// ピラミッドのタスクノード
class PyramidTaskNode extends StatelessWidget {
  final Task task;

  const PyramidTaskNode({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Spacing.small),
      padding: EdgeInsets.all(Spacing.medium),
      decoration: BoxDecoration(
        color: _getTaskStatusColor(task.status.value),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(right: Spacing.small),
            child: _getStatusIcon(task.status.value),
          ),
          Expanded(
            child: Column(
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
                  '期限: ${_formatDate(task.deadline.value)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTaskStatusColor(String status) {
    switch (status) {
      case 'todo':
        return Colors.grey.withValues(alpha: 0.1);
      case 'doing':
        return Colors.orange.withValues(alpha: 0.1);
      case 'done':
        return Colors.green.withValues(alpha: 0.1);
      default:
        return Colors.grey.withValues(alpha: 0.1);
    }
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'todo':
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neutral400),
          ),
          child: const SizedBox.shrink(),
        );
      case 'doing':
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.withValues(alpha: 0.3),
            border: Border.all(color: Colors.orange),
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange,
              ),
            ),
          ),
        );
      case 'done':
        return Icon(Icons.check_circle, color: Colors.green, size: 24);
      default:
        return const SizedBox(width: 24, height: 24);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
