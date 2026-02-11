import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/goal.dart';
import '../../../../domain/entities/milestone.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../theme/app_theme.dart';
import 'pyramid_widgets.dart';

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
        PyramidGoalNode(goal: goal),
        if (milestones.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: Spacing.medium),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: milestones.length,
              itemBuilder: (context, index) {
                final milestone = milestones[index];
                return PyramidMilestoneNode(
                  milestone: milestone,
                  goalId: goal.id.value,
                  milestoneTasks: ref.watch(
                    tasksByMilestoneProvider(milestone.id.value),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
