import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/goal.dart';
import '../../../domain/entities/milestone.dart';
import '../../../domain/entities/task.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../state_management/providers/app_providers.dart';
import '../../navigation/app_router.dart';

/// ピラミッドビュー
///
/// ゴール → マイルストーン → タスクの階層構造を展開可能なリスト形式で表示します。
class PyramidView extends ConsumerWidget {
  final Goal goal;
  final List<Milestone> milestones;

  const PyramidView({super.key, required this.goal, required this.milestones});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGoalNode(context, ref, goal),
        if (milestones.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: Spacing.medium),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: milestones.length,
              itemBuilder: (context, index) => _buildMilestoneNode(
                context,
                ref,
                goal.id.value,
                milestones[index],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGoalNode(BuildContext context, WidgetRef ref, Goal goal) {
    return Container(
      margin: EdgeInsets.only(bottom: Spacing.medium),
      padding: EdgeInsets.all(Spacing.medium),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ゴール',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
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
    );
  }

  Widget _buildMilestoneNode(
    BuildContext context,
    WidgetRef ref,
    String goalId,
    Milestone milestone,
  ) {
    return _MilestoneExpansionTile(
      milestone: milestone,
      goalId: goalId,
      milestoneTasks: ref.watch(tasksByMilestoneIdProvider(milestone.id.value)),
      onNavigateToMilestoneDetail: () => AppRouter.navigateToMilestoneDetail(
        context,
        goalId,
        milestone.id.value,
      ),
    );
  }
}

/// マイルストーンの展開可能なノード
class _MilestoneExpansionTile extends ConsumerWidget {
  final Milestone milestone;
  final String goalId;
  final AsyncValue<List<Task>> milestoneTasks;
  final VoidCallback onNavigateToMilestoneDetail;

  const _MilestoneExpansionTile({
    required this.milestone,
    required this.goalId,
    required this.milestoneTasks,
    required this.onNavigateToMilestoneDetail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              onTap: onNavigateToMilestoneDetail,
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
                          _buildTaskNode(context, tasks[index]),
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

  Widget _buildTaskNode(BuildContext context, Task task) {
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
          // ステータスアイコン
          Container(
            margin: EdgeInsets.only(right: Spacing.small),
            child: _getStatusIcon(task.status.value),
          ),
          // タスク情報
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
