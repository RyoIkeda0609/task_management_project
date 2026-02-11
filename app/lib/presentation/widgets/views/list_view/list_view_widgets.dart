import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../state_management/providers/app_providers.dart';

/// ゴールカード
class GoalCard extends ConsumerWidget {
  final Goal goal;
  final VoidCallback onTap;

  const GoalCard({super.key, required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GoalCardHeader(goal: goal),
              SizedBox(height: Spacing.small),
              _GoalCardReason(reason: goal.reason.value),
              SizedBox(height: Spacing.medium),
              _GoalCardProgress(goalId: goal.id.value),
              SizedBox(height: Spacing.medium),
              _GoalCardDeadline(deadline: goal.deadline.value),
            ],
          ),
        ),
      ),
    );
  }
}

/// ゴールカード - ヘッダー（タイトル + カテゴリ）
class _GoalCardHeader extends StatelessWidget {
  final Goal goal;

  const _GoalCardHeader({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            goal.title.value,
            style: AppTextStyles.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: Spacing.small),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.xSmall,
            vertical: Spacing.xSmall,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            goal.category.value,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

/// ゴールカード - 理由説明
class _GoalCardReason extends StatelessWidget {
  final String reason;

  const _GoalCardReason({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Text(
      reason,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// ゴールカード - 進捗セクション
class _GoalCardProgress extends ConsumerWidget {
  final String goalId;

  const _GoalCardProgress({required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(goalProgressProvider(goalId));

    return progressAsync.when(
      data: (progress) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '進捗: ${progress.value}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: Spacing.xSmall),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.value / 100.0,
                minHeight: 8,
                backgroundColor: AppColors.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(progress.value),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => SizedBox(
        height: 16,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, _) => Text(
        '進捗読み込みエラー',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress < 25) {
      return AppColors.error;
    } else if (progress < 50) {
      return AppColors.warning;
    } else if (progress < 75) {
      return AppColors.primary;
    } else {
      return AppColors.success;
    }
  }
}

/// ゴールカード - 期限
class _GoalCardDeadline extends StatelessWidget {
  final DateTime deadline;

  const _GoalCardDeadline({required this.deadline});

  @override
  Widget build(BuildContext context) {
    return Text(
      '期限: ${_formatDate(deadline)}',
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
