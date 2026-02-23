import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import '../../../navigation/app_router.dart';
import '../../../theme/app_theme.dart';
import 'list_view_widgets.dart';

/// ゴールリストビュー
class GoalListView extends ConsumerWidget {
  final List<Goal> goals;
  final VoidCallback onCreatePressed;

  const GoalListView({
    super.key,
    required this.goals,
    required this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: EdgeInsets.all(Spacing.screenPadding),
      itemCount: goals.length,
      separatorBuilder: (_, __) => SizedBox(height: Spacing.itemSpacing),
      itemBuilder: (context, index) {
        return GoalCard(
          goal: goals[index],
          onTap: () => _onGoalCardTapped(context, goals[index]),
        );
      },
    );
  }

  void _onGoalCardTapped(BuildContext context, Goal goal) {
    AppRouter.navigateToGoalDetail(context, goal.itemId.value);
  }
}
