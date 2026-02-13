import 'package:app/presentation/state_management/providers/app_providers.dart';
import 'package:app/presentation/widgets/views/pyramid_view/pyramid_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/views/pyramid_view/pyramid_view.dart';
import '../../../navigation/app_router.dart';
import '../../../../domain/entities/goal.dart';
import '../../../../domain/entities/milestone.dart';

class GoalDetailHeaderWidget extends StatelessWidget {
  final Goal goal;

  const GoalDetailHeaderWidget({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(goal.title.value, style: AppTextStyles.headlineMedium),
        SizedBox(height: Spacing.small),
        Row(
          children: [
            Text(
              '達成予定日: ${_formatDate(goal.deadline)}',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(width: Spacing.medium),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.small,
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
        SizedBox(height: Spacing.medium),
        Text('説明・理由', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.xSmall),
        Text(goal.reason.value, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  String _formatDate(dynamic deadline) {
    try {
      final dt = deadline is DateTime ? deadline : DateTime.now();
      return '${dt.year}年${dt.month}月${dt.day}日';
    } catch (e) {
      return '達成予定日未設定';
    }
  }
}

class GoalDetailMilestoneSection extends ConsumerWidget {
  final Goal goal;
  final String goalId;
  final AsyncValue<List<Milestone>> milestonesAsync;

  const GoalDetailMilestoneSection({
    super.key,
    required this.goal,
    required this.goalId,
    required this.milestonesAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Spacing.medium),
        milestonesAsync.when(
          data: (milestones) => milestones.isEmpty
              ? _buildMilestonesEmpty(context, goalId)
              : _buildMilestonesList(context, ref, milestones),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text('マイルストーン取得エラー: $error'),
        ),
      ],
    );
  }

  Widget _buildMilestonesList(
    BuildContext context,
    WidgetRef ref,
    List<Milestone> milestones,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('マイルストーン', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.medium),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: milestones.length,
          itemBuilder: (context, index) {
            final milestone = milestones[index];
            return PyramidMilestoneNode(
              milestone: milestone,
              goalId: goalId,
              milestoneTasks: ref.watch(
                tasksByMilestoneProvider(milestone.id.value),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMilestonesEmpty(BuildContext context, String goalId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('マイルストーン', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.medium),
        EmptyState(
          icon: Icons.flag_outlined,
          title: 'マイルストーンがありません',
          message: 'マイルストーンを追加してゴールを達成しましょう。',
          actionText: 'マイルストーン追加',
          onActionPressed: () =>
              AppRouter.navigateToMilestoneCreate(context, goalId),
        ),
      ],
    );
  }
}

class GoalDetailErrorWidget extends StatelessWidget {
  final Object error;

  const GoalDetailErrorWidget({super.key, required this.error});

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
