import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../navigation/app_router.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../../application/providers/use_case_providers.dart';
import '../../../../domain/entities/goal.dart';
import 'goal_detail_widgets.dart';

/// ゴール詳細画面
///
/// 選択されたゴールの詳細情報とマイルストーン一覧を表示します。
/// ゴール編集やマイルストーン追加ができます。
class GoalDetailPage extends ConsumerWidget {
  final String goalId;

  const GoalDetailPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailProvider(goalId));
    final milestonesAsync = ref.watch(milestonsByGoalProvider(goalId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ゴール詳細',
        hasLeading: true,
        onLeadingPressed: () => Navigator.of(context).pop(),
        actions: [
          // 編集ボタン
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => AppRouter.navigateToGoalEdit(context, goalId),
          ),
          // 削除ボタン
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              goalAsync.whenData((goal) {
                if (goal != null) {
                  _showDeleteGoalDialog(context, ref, goal);
                }
              });
            },
          ),
        ],
      ),
      body: goalAsync.when(
        data: (goal) {
          if (goal == null) {
            return Center(
              child: Text('ゴールが見つかりません', style: AppTextStyles.titleMedium),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(Spacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GoalDetailHeaderWidget(goal: goal),
                  SizedBox(height: Spacing.large),
                  GoalDetailMilestoneSection(
                    goal: goal,
                    goalId: goalId,
                    milestonesAsync: milestonesAsync,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => GoalDetailErrorWidget(error: error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppRouter.navigateToMilestoneCreate(context, goalId),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteGoalDialog(BuildContext context, WidgetRef ref, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ゴール削除'),
        content: Text(
          '「${goal.title.value}」を削除してもよろしいですか？\n関連するマイルストーンとタスクもすべて削除されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final deleteGoalUseCase = ref.read(deleteGoalUseCaseProvider);
                await deleteGoalUseCase(goal.id.value);

                // ゴール一覧をリフレッシュ
                ref.invalidate(goalsProvider);
                ref.invalidate(goalProgressProvider);
                // 本日のタスク一覧もリフレッシュ（カスケード削除されたタスクを反映）
                ref.invalidate(todayTasksProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('ゴールを削除しました')));
                  // ホーム画面に戻る
                  AppRouter.navigateToHome(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('削除に失敗しました: $e')));
                }
              }
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
