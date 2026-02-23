import 'package:app/presentation/state_management/providers/app_providers.dart';
import 'package:app/presentation/widgets/views/pyramid_view/pyramid_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../navigation/app_router.dart';
import '../../../../domain/entities/goal.dart';
import '../../../../domain/entities/milestone.dart';
import '../../../utils/date_formatter.dart';

class GoalDetailHeaderWidget extends ConsumerWidget {
  final Goal goal;
  final String goalId;

  const GoalDetailHeaderWidget({
    super.key,
    required this.goal,
    required this.goalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(goalProgressProvider(goalId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ゴール情報'),
        SizedBox(height: Spacing.small),
        Text(goal.title.value, style: AppTextStyles.headlineMedium),
        SizedBox(height: Spacing.small),
        _buildDeadlineRow(),
        SizedBox(height: Spacing.medium),
        progressAsync.when(
          data: (progress) =>
              _GoalProgressSection(progressValue: progress.value),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        Divider(height: Spacing.xLarge, color: AppColors.neutral200),
        _buildDescriptionSection(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(Radii.small),
          ),
        ),
        SizedBox(width: Spacing.small),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineRow() {
    return Row(
      children: [
        Text(
          '達成予定日: ${DateFormatter.toJapaneseDate(goal.deadline.value)}',
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
            borderRadius: BorderRadius.circular(Radii.small),
          ),
          child: Text(
            goal.category.value,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('説明・理由', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.xSmall),
        Text(goal.description.value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

/// ゴールの進捗バーと進捗率を表示するウィジェット
class _GoalProgressSection extends StatelessWidget {
  final int progressValue;

  const _GoalProgressSection({required this.progressValue});

  @override
  Widget build(BuildContext context) {
    final isCompleted = progressValue >= 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('進捗', style: AppTextStyles.labelLarge),
            Row(
              children: [
                if (isCompleted)
                  Padding(
                    padding: EdgeInsets.only(right: Spacing.xxSmall),
                    child: Icon(
                      Icons.celebration,
                      size: 16,
                      color: AppColors.success,
                    ),
                  ),
                Text(
                  '$progressValue%',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: Spacing.xSmall),
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.small),
          child: LinearProgressIndicator(
            value: progressValue / 100,
            minHeight: 8,
            backgroundColor: AppColors.neutral300,
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? AppColors.success : AppColors.primary,
            ),
          ),
        ),
        if (isCompleted)
          Padding(
            padding: EdgeInsets.only(top: Spacing.xSmall),
            child: Text(
              'おめでとうございます！ゴールを達成しました！',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
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
        _buildSectionHeader('マイルストーン'),
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
                tasksByMilestoneProvider(milestone.itemId.value),
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
        _buildSectionHeader('マイルストーン'),
        SizedBox(height: Spacing.medium),
        EmptyState(
          icon: Icons.flag_outlined,
          title: 'マイルストーンがありません',
          message: 'このゴールを分解してみましょう。',
          actionText: 'マイルストーン追加',
          onActionPressed: () =>
              AppRouter.navigateToMilestoneCreate(context, goalId),
        ),
      ],
    );
  }

  /// セクションヘッダー（アクセントバー + タイトル）
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(Radii.small),
          ),
        ),
        SizedBox(width: Spacing.small),
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
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
