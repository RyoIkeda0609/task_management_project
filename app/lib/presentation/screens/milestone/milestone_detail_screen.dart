import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../widgets/common/status_badge.dart';
import '../../../domain/entities/milestone.dart';
import '../../../domain/entities/task.dart';
import '../../state_management/providers/app_providers.dart';
import '../../navigation/app_router.dart';

/// マイルストーン詳細画面
///
/// マイルストーンの詳細情報を表示し、
/// 紐付けられたタスク一覧を表示します。
class MilestoneDetailScreen extends ConsumerWidget {
  final String milestoneId;

  const MilestoneDetailScreen({super.key, required this.milestoneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestoneAsync = ref.watch(milestoneDetailProvider(milestoneId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'マイルストーン詳細',
        hasLeading: true,
        onLeadingPressed: () => context.pop(),
      ),
      body: milestoneAsync.when(
        data: (milestone) => _buildContent(context, ref, milestone),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(error),
      ),
      floatingActionButton: milestoneAsync
          .whenData(
            (milestone) => FloatingActionButton(
              onPressed: () => milestone != null
                  ? _navigateToTaskCreate(context, milestone.goalId)
                  : null,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            ),
          )
          .value,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Milestone? milestone,
  ) {
    if (milestone == null) {
      return Center(
        child: Text('マイルストーンが見つかりません', style: AppTextStyles.titleMedium),
      );
    }

    return CustomScrollView(
      slivers: [
        // ヘッダー情報
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(Spacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title.value,
                  style: AppTextStyles.headlineMedium,
                ),
                SizedBox(height: Spacing.medium),
                _buildMilestoneInfo(milestone),
              ],
            ),
          ),
        ),

        // タスク一覧
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.medium),
            child: Text('タスク', style: AppTextStyles.labelLarge),
          ),
        ),
        _buildTasksList(ref, milestone),
      ],
    );
  }

  Widget _buildMilestoneInfo(Milestone milestone) {
    return Container(
      padding: EdgeInsets.all(Spacing.medium),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: AppColors.neutral600, size: 16),
          SizedBox(width: Spacing.small),
          Text(
            '期限: ${_formatDate(milestone.deadline.value)}',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(WidgetRef ref, Milestone milestone) {
    final tasksAsync = ref.watch(tasksByMilestoneProvider(milestoneId));

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: Spacing.medium),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: AppColors.neutral300,
                    ),
                    SizedBox(height: Spacing.medium),
                    Text('タスクがありません', style: AppTextStyles.headlineMedium),
                    SizedBox(height: Spacing.small),
                    Text(
                      'このマイルストーンに紐付けられたタスクはありません。',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    SizedBox(height: Spacing.large),
                    FilledButton.tonal(
                      onPressed: () {
                        // ここは`context`がないため、別の方法で処理が必要
                        // 実装時にはNavigatorを利用してtaskCreate画面へ遷移
                      },
                      child: const Text('タスクを追加'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index == 0) {
              return SizedBox(height: Spacing.small);
            }
            final taskIndex = index - 1;
            if (taskIndex >= tasks.length) {
              return const SizedBox.shrink();
            }
            final task = tasks[taskIndex];
            return _buildTaskItem(context, ref, task);
          }, childCount: tasks.length + 1),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(Spacing.medium),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) =>
          SliverToBoxAdapter(child: _buildErrorWidget(error)),
    );
  }

  Widget _buildTaskItem(BuildContext context, WidgetRef ref, Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.medium,
        vertical: Spacing.xSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToTaskDetail(context, task.id.value),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(Spacing.medium),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // ステータスアイコン
                _buildTaskStatusIcon(task.status),
                SizedBox(width: Spacing.small),
                // タスク情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title.value,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Spacing.xSmall),
                      Text(
                        _formatDate(task.deadline),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Spacing.small),
                // ステータスバッジ
                StatusBadge(
                  status: _mapTaskStatus(task.status),
                  size: BadgeSize.small,
                ),
                SizedBox(width: Spacing.small),
                // メニューボタン
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('ステータス変更'),
                      onTap: () {
                        // TODO: ステータス変更機能
                      },
                    ),
                    PopupMenuItem(
                      child: const Text(
                        '削除',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        _showDeleteTaskDialog(context, ref, task);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskStatusIcon(dynamic status) {
    final statusStr = status?.toString() ?? 'unknown';
    if (statusStr.contains('done')) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(Icons.check, size: 14, color: AppColors.success),
      );
    } else if (statusStr.contains('doing')) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(Icons.schedule, size: 14, color: AppColors.warning),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(Icons.circle_outlined, size: 14, color: AppColors.neutral400),
    );
  }

  String _formatDate(dynamic date) {
    try {
      final dt = date is DateTime ? date : DateTime.now();
      return '${dt.year}年${dt.month}月${dt.day}日';
    } catch (e) {
      return '未設定';
    }
  }

  String _mapTaskStatus(dynamic status) {
    final statusStr = status?.toString() ?? 'unknown';
    if (statusStr.contains('done')) return 'done';
    if (statusStr.contains('doing')) return 'doing';
    return 'todo';
  }

  void _navigateToTaskCreate(BuildContext context, String goalId) {
    AppRouter.navigateToTaskCreate(context, milestoneId, goalId);
  }

  void _showDeleteTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タスク削除'),
        content: Text('「${task.title.value}」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              try {
                final taskRepository = ref.read(taskRepositoryProvider);
                await taskRepository.deleteTask(task.id.value);

                // タスク一覧をリフレッシュ
                ref.invalidate(tasksByMilestoneProvider(milestoneId));

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('タスクを削除しました')));
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

  void _navigateToTaskDetail(BuildContext context, String taskId) {
    AppRouter.navigateToTaskDetail(context, taskId);
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
