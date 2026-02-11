// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../navigation/app_router.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../../application/providers/use_case_providers.dart';
import '../../../../domain/entities/task.dart';
import 'task_detail_widgets.dart';

/// タスク詳細画面
///
/// 選択されたタスクの詳細情報を表示し、
/// ステータスの変更ができます。
class TaskDetailPage extends ConsumerWidget {
  final String taskId;
  final String source;

  const TaskDetailPage({
    super.key,
    required this.taskId,
    this.source = 'today_tasks',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'タスク詳細',
        hasLeading: true,
        onLeadingPressed: () => _navigateBack(context),
        actions: [
          // 編集ボタン
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              taskAsync.whenData((task) {
                if (task != null) {
                  if (source == 'milestone') {
                    // マイルストーン情報を取得してgoalIdを取得
                    ref
                        .watch(milestoneDetailProvider(task.milestoneId))
                        .whenData((milestone) {
                          if (milestone != null) {
                            AppRouter.navigateToTaskEditFromMilestone(
                              context,
                              milestone.goalId,
                              task.milestoneId,
                              taskId,
                            );
                          }
                        });
                  } else {
                    // today_tasks
                    AppRouter.navigateToTaskEditFromTodayTasks(context, taskId);
                  }
                }
              });
            },
          ),
          // 削除ボタン
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              taskAsync.whenData((task) {
                if (task != null) {
                  _showDeleteTaskDialog(context, ref, task);
                }
              });
            },
          ),
        ],
      ),
      body: taskAsync.when(
        data: (task) {
          if (task == null) {
            return Center(
              child: Text('タスクが見つかりません', style: AppTextStyles.titleMedium),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(Spacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TaskDetailHeaderWidget(task: task),
                  SizedBox(height: Spacing.large),
                  TaskDetailDeadlineWidget(task: task),
                  SizedBox(height: Spacing.large),
                  TaskDetailStatusWidget(
                    task: task,
                    onStatusChanged: () {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ステータスを更新しました。'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: Spacing.large),
                  TaskDetailInfoWidget(task: task),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => TaskDetailErrorWidget(error: error),
      ),
    );
  }

  /// 遷移元に基づいて戻る処理
  void _navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _showDeleteTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('タスク削除'),
        content: Text('「${task.title.value}」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                final deleteTaskUseCase = ref.read(deleteTaskUseCaseProvider);
                await deleteTaskUseCase(task.id.value);

                // タスク一覧をリフレッシュ
                ref.invalidate(tasksByMilestoneProvider(task.milestoneId));
                ref.invalidate(todayTasksProvider);
                ref.invalidate(goalsProvider);
                ref.invalidate(goalProgressProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('タスクを削除しました')));
                  // 親画面に戻る
                  _navigateBack(context);
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
