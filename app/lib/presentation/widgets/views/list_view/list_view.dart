import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_text_styles.dart';
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
    final sortedGoals = [...goals]
      ..sort((a, b) => a.deadline.value.compareTo(b.deadline.value));

    return ListView.builder(
      padding: EdgeInsets.all(Spacing.medium),
      itemCount: sortedGoals.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: Spacing.small),
            child: Text(
              '期限が近い順に表示',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
            ),
          );
        }
        return GoalCard(
          goal: sortedGoals[index - 1],
          onTap: () => _onGoalCardTapped(context, sortedGoals[index - 1]),
        );
      },
    );
  }

  void _onGoalCardTapped(BuildContext context, Goal goal) {
    // go_routerを使用してゴール詳細画面へナビゲート
    context.go('/home/goal/${goal.itemId.value}');
  }
}
