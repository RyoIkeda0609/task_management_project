import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../navigation/app_router.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../../application/providers/use_case_providers.dart';
import '../../../../domain/entities/milestone.dart';
import 'milestone_detail_widgets.dart';

/// マイルストーン詳細画面
///
/// マイルストーンの詳細情報を表示し、
/// 紐付けられたタスク一覧を表示します。
class MilestoneDetailPage extends ConsumerWidget {
  final String milestoneId;

  const MilestoneDetailPage({super.key, required this.milestoneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestoneAsync = ref.watch(milestoneDetailProvider(milestoneId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'マイルストーン詳細',
        hasLeading: true,
        onLeadingPressed: () => context.pop(),
        actions: [
          // 編集ボタン
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              milestoneAsync.whenData((milestone) {
                if (milestone != null) {
                  AppRouter.navigateToMilestoneEdit(
                    context,
                    milestone.goalId,
                    milestoneId,
                  );
                }
              });
            },
          ),
          // 削除ボタン
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              milestoneAsync.whenData((milestone) {
                if (milestone != null) {
                  _showDeleteMilestoneDialog(context, ref, milestone);
                }
              });
            },
          ),
        ],
      ),
      body: milestoneAsync.when(
        data: (milestone) {
          if (milestone == null) {
            return Center(
              child: Text('マイルストーンが見つかりません', style: AppTextStyles.titleMedium),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MilestoneDetailHeaderWidget(milestone: milestone),
                SizedBox(height: Spacing.large),
                MilestoneDetailTasksSection(
                  milestoneId: milestoneId,
                  milestone: milestone,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => milestoneAsync
            .whenData(
              (milestone) => milestone != null
                  ? _navigateToTaskCreate(context, milestone.goalId)
                  : null,
            )
            .value,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToTaskCreate(BuildContext context, String goalId) {
    AppRouter.navigateToTaskCreate(context, milestoneId, goalId);
  }

  void _showDeleteMilestoneDialog(
    BuildContext context,
    WidgetRef ref,
    Milestone milestone,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('マイルストーン削除'),
        content: Text(
          '「${milestone.title.value}」を削除してもよろしいですか？\n関連するタスクもすべて削除されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                final deleteMilestoneUseCase = ref.read(
                  deleteMilestoneUseCaseProvider,
                );
                await deleteMilestoneUseCase(milestoneId);

                // マイルストーン一覧をリフレッシュ
                ref.invalidate(milestonsByGoalProvider(milestone.goalId));
                ref.invalidate(goalsProvider);
                ref.invalidate(goalProgressProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('マイルストーンを削除しました')),
                  );
                  // 親画面（ゴール詳細）に戻る
                  Navigator.of(context).pop();
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

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: Spacing.medium),
          Text('エラーが発生しました', style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }
}
