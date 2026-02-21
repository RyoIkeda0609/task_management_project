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
              SizedBox(height: Spacing.medium),
              _GoalCardFooter(goal: goal, goalId: goal.itemId.value),
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

/// ゴールカード - フッター（期限と進捗を1行にまとめる）
class _GoalCardFooter extends ConsumerWidget {
  final Goal goal;
  final String goalId;

  const _GoalCardFooter({required this.goal, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(goalProgressProvider(goalId));

    return progressAsync.when(
      data: (progress) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 期限と進捗を1行にまとめる
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '期限：${_formatDate(goal.deadline.value)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.neutral600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: Spacing.small),
                Text(
                  '進捗：${progress.value}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
            SizedBox(height: Spacing.small),
            // 進捗バー
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.value / 100.0,
                minHeight: 6,
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
        height: 20,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      error: (error, _) => Text(
        '進捗読み込みエラー',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  Color _getProgressColor(int progress) {
    if (progress < 25) {
      return AppColors.neutral400;
    } else if (progress < 50) {
      return AppColors.primary;
    } else if (progress < 75) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }
}
