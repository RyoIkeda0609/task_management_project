import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import '../../../navigation/app_router.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import 'list_view_widgets.dart';

/// ゴールリストビュー
class GoalListView extends ConsumerWidget {
  final List<Goal> goals;
  final String sortLabel;
  final VoidCallback onCreatePressed;

  const GoalListView({
    super.key,
    required this.goals,
    this.sortLabel = '期限が近い順',
    required this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: EdgeInsets.all(Spacing.medium),
      itemCount: goals.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: Spacing.small),
            child: Text(
              '${sortLabel}に表示',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
            ),
          );
        }
        return GoalCard(
          goal: goals[index - 1],
          onTap: () => _onGoalCardTapped(context, goals[index - 1]),
        );
      },
    );
  }

  void _onGoalCardTapped(BuildContext context, Goal goal) {
    AppRouter.navigateToGoalDetail(context, goal.itemId.value);
  }
}
