import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../state_management/providers/app_providers.dart';
import 'pyramid_view.dart';

/// ピラミッドビュー（マイルストーン表示）
/// 複数のゴールを各々ピラミッド形式で表示します
class GoalPyramidView extends ConsumerWidget {
  final List<Goal> goals;

  const GoalPyramidView({super.key, required this.goals});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: EdgeInsets.all(Spacing.medium),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final milestonesAsync = ref.watch(
          milestonesByGoalProvider(goal.itemId.value),
        );

        return milestonesAsync.when(
          data: (milestones) => Padding(
            padding: EdgeInsets.only(bottom: Spacing.large),
            child: PyramidView(goal: goal, milestones: milestones),
          ),
          loading: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          error: (error, _) => _buildErrorView('ピラミッドビュー読み込みエラー'),
        );
      },
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
    );
  }
}
