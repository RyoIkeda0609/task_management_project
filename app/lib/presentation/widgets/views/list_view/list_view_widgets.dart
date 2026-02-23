import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../utils/date_formatter.dart';

/// ゴールカード
class GoalCard extends ConsumerWidget {
  final Goal goal;
  final VoidCallback onTap;

  const GoalCard({super.key, required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.medium),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GoalCardHeader(goal: goal, goalId: goal.itemId.value),
              SizedBox(height: Spacing.small),
              _GoalCardCategoryChip(category: goal.category.value),
              SizedBox(height: Spacing.xSmall),
              Text(
                '期限：${DateFormatter.toJapaneseDate(goal.deadline.value)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              SizedBox(height: Spacing.small),
              _GoalCardProgressBar(goalId: goal.itemId.value),
            ],
          ),
        ),
      ),
    );
  }
}

/// ゴールカード - ヘッダー（タイトル + 右上に進捗%）
class _GoalCardHeader extends ConsumerWidget {
  final Goal goal;
  final String goalId;

  const _GoalCardHeader({required this.goal, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(goalProgressProvider(goalId));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            goal.title.value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: Spacing.small),
        progressAsync.when(
          data: (progress) => _buildProgressBadge(progress.value),
          loading: () => SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildProgressBadge(int progressValue) {
    final color = AppColors.getProgressColor(progressValue);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.small,
        vertical: Spacing.xxSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Radii.small),
      ),
      child: Text(
        '$progressValue%',
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// ゴールカード - カテゴリChip
class _GoalCardCategoryChip extends StatelessWidget {
  final String category;

  const _GoalCardCategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xSmall,
        vertical: Spacing.xxSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Radii.small),
      ),
      child: Text(
        category,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
      ),
    );
  }
}

/// ゴールカード - プログレスバー
class _GoalCardProgressBar extends ConsumerWidget {
  final String goalId;

  const _GoalCardProgressBar({required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(goalProgressProvider(goalId));

    return progressAsync.when(
      data: (progress) => ClipRRect(
        borderRadius: BorderRadius.circular(Radii.small),
        child: LinearProgressIndicator(
          value: progress.value / 100.0,
          minHeight: 8,
          backgroundColor: AppColors.neutral200,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.getProgressColor(progress.value),
          ),
        ),
      ),
      loading: () => SizedBox(
        height: 8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Radii.small),
          child: LinearProgressIndicator(
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
