import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../../domain/entities/goal.dart';
import '../../../domain/entities/milestone.dart';
import '../../state_management/providers/app_providers.dart';
import '../../navigation/app_router.dart';

/// ゴール詳細画面
///
/// 選択されたゴールの詳細情報とマイルストーン一覧を表示します。
/// ゴール編集やマイルストーン追加ができます。
class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalByIdProvider(goalId));
    final milestonesAsync = ref.watch(milestonesByGoalIdProvider(goalId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ゴール詳細',
        hasLeading: true,
        onLeadingPressed: () => Navigator.of(context).pop(),
        actions: [
          // 編集ボタン
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: ゴール編集画面へナビゲート
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('ゴール編集機能は準備中です')));
            },
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
                  _buildGoalHeader(goal),
                  SizedBox(height: Spacing.large),
                  _buildMilestoneSection(context, ref, goalId, milestonesAsync),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).pushNamed(AppRouter.milestoneCreate, arguments: goalId),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGoalHeader(Goal goal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(goal.title.value, style: AppTextStyles.headlineMedium),
        SizedBox(height: Spacing.small),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.small,
            vertical: Spacing.xSmall,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            goal.category.value,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          ),
        ),
        SizedBox(height: Spacing.medium),
        Text('ゴールの理由', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.xSmall),
        Text(goal.reason.value, style: AppTextStyles.bodyMedium),
        SizedBox(height: Spacing.medium),
        Text(
          '期限: ${_formatDate(goal.deadline)}',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildMilestoneSection(
    BuildContext context,
    WidgetRef ref,
    String goalId,
    AsyncValue<List<Milestone>> milestonesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('マイルストーン', style: AppTextStyles.headlineSmall),
        SizedBox(height: Spacing.medium),
        milestonesAsync.when(
          data: (milestones) {
            if (milestones.isEmpty) {
              return EmptyState(
                icon: Icons.flag_outlined,
                title: 'マイルストーンがありません',
                message: 'マイルストーンを追加してゴールを達成しましょう。',
                actionText: 'マイルストーン追加',
                onActionPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRouter.milestoneCreate, arguments: goalId);
                },
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: milestones.length,
              itemBuilder: (context, index) =>
                  _buildMilestoneCard(context, ref, milestones[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text('マイルストーン取得エラー: $error'),
        ),
      ],
    );
  }

  Widget _buildMilestoneCard(
    BuildContext context,
    WidgetRef ref,
    Milestone milestone,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: Spacing.small),
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    milestone.title.value,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('詳細'),
                      onTap: () {
                        // TODO: マイルストーン詳細画面へナビゲート
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('マイルストーン詳細表示は準備中です')),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('編集'),
                      onTap: () {
                        // TODO: マイルストーン編集画面へナビゲート
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('マイルストーン編集機能は準備中です')),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Text(
                        '削除',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        _showDeleteMilestoneDialog(context, ref, milestone);
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: Spacing.small),
            Text(
              '期限: ${_formatDate(milestone.deadline)}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic deadline) {
    try {
      final dt = deadline is DateTime ? deadline : DateTime.now();
      return '${dt.year}年${dt.month}月${dt.day}日';
    } catch (e) {
      return '期限未設定';
    }
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
                final goalRepository = ref.read(goalRepositoryProvider);
                await goalRepository.deleteGoal(goal.id.value);

                // ゴール一覧をリフレッシュ
                ref.invalidate(goalListProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('ゴールを削除しました')));
                  // ホーム画面に戻る
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

  void _showDeleteMilestoneDialog(
    BuildContext context,
    WidgetRef ref,
    Milestone milestone,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('マイルストーン削除'),
        content: Text('「${milestone.title.value}」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final milestoneRepository = ref.read(
                  milestoneRepositoryProvider,
                );
                await milestoneRepository.deleteMilestone(milestone.id.value);

                // マイルストーン一覧をリフレッシュ
                ref.invalidate(milestonesByGoalIdProvider(goalId));

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('マイルストーンを削除しました')),
                  );
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
