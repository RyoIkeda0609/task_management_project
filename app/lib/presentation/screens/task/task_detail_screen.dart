// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/value_objects/task/task_status.dart';
import '../../state_management/providers/app_providers.dart';

/// タスク詳細画面
///
/// 選択されたタスクの詳細情報を表示し、
/// ステータスの変更ができます。
class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenStateImpl();
}

class _TaskDetailScreenStateImpl extends ConsumerState<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'タスク詳細',
        hasLeading: true,
        onLeadingPressed: () => Navigator.of(context).pop(),
        actions: [
          // 編集ボタン
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('タスク編集機能は準備中です')));
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
        data: (task) => _buildContent(context, task),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(error),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Task? task) {
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
            _buildTaskHeader(task),
            SizedBox(height: Spacing.large),
            _buildDeadlineSection(task),
            SizedBox(height: Spacing.large),
            _buildStatusSection(task, context),
            SizedBox(height: Spacing.large),
            _buildStatusButtons(context, task),
            SizedBox(height: Spacing.large),
            _buildTaskInfoSection(task),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskHeader(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(task.title.value, style: AppTextStyles.headlineMedium),
        SizedBox(height: Spacing.medium),
        Text('タスクの説明', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.xSmall),
        Text(task.description.value, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildDeadlineSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('期限', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.xSmall),
        Text(_formatDate(task.deadline), style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildStatusSection(Task task, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ステータス', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.small),
        _buildStatusDisplay(task),
      ],
    );
  }

  Widget _buildStatusDisplay(Task task) {
    return InkWell(
      onTap: () => _cycleTaskStatus(task),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(Spacing.medium),
        decoration: BoxDecoration(
          color: _getStatusBackgroundColor(task.status),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _getStatusBorderColor(task.status)),
        ),
        child: Row(
          children: [
            Icon(
              _getStatusIcon(task.status),
              color: _getStatusColor(task.status),
            ),
            SizedBox(width: Spacing.small),
            Expanded(
              child: Text(
                _getStatusLabel(task.status),
                style: AppTextStyles.bodyMedium,
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: _getStatusColor(task.status),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButtons(BuildContext context, Task task) {
    return const SizedBox.shrink(); // ステータスボタンセクションを非表示にする
  }

  Widget _buildTaskInfoSection(Task task) {
    return Container(
      padding: EdgeInsets.all(Spacing.medium),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('タスク情報', style: AppTextStyles.labelLarge),
          SizedBox(height: Spacing.small),
          _buildInfoRow('タスクID', task.id.value),
          SizedBox(height: Spacing.xSmall),
          _buildInfoRow('マイルストーン', task.milestoneId),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral600),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// ステータスを循環変更（todo → doing → done → todo）
  void _cycleTaskStatus(Task task) {
    final newStatus = task.status.toString().contains('todo')
        ? TaskStatus.doing()
        : task.status.toString().contains('doing')
        ? TaskStatus.done()
        : TaskStatus.todo();

    _updateStatus(newStatus, task);
  }

  /// ステータスを更新
  Future<void> _updateStatus(TaskStatus newStatus, Task task) async {
    try {
      final taskRepository = ref.read(taskRepositoryProvider);

      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        deadline: task.deadline,
        status: newStatus,
        milestoneId: task.milestoneId,
      );

      await taskRepository.saveTask(updatedTask);
      ref.invalidate(taskDetailProvider(widget.taskId));
      ref.invalidate(tasksByMilestoneProvider(task.milestoneId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ステータスを「${_getStatusLabel(newStatus)}」に更新しました。'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新に失敗しました: $e')));
      }
    }
  }

  String _formatDate(dynamic deadline) {
    try {
      final dt = deadline is DateTime ? deadline : DateTime.now();
      return '${dt.year}年${dt.month}月${dt.day}日';
    } catch (e) {
      return '期限未設定';
    }
  }

  String _getStatusLabel(dynamic status) {
    final statusStr = status?.toString() ?? 'unknown';
    if (statusStr.contains('todo')) return '未完了';
    if (statusStr.contains('doing')) return '進行中';
    if (statusStr.contains('done')) return '完了';
    return statusStr;
  }

  IconData _getStatusIcon(dynamic status) {
    final statusStr = status?.toString() ?? 'unknown';
    if (statusStr.contains('done')) return Icons.check_circle;
    if (statusStr.contains('doing')) return Icons.radio_button_checked;
    return Icons.radio_button_unchecked;
  }

  Color _getStatusColor(dynamic status) {
    final statusStr = status?.toString() ?? 'unknown';
    if (statusStr.contains('done')) return AppColors.success;
    if (statusStr.contains('doing')) return AppColors.warning;
    return AppColors.neutral400;
  }

  Color _getStatusBackgroundColor(dynamic status) {
    final statusStr = status?.toString() ?? 'unknown';
    if (statusStr.contains('done')) {
      return AppColors.success.withValues(alpha: 0.1);
    }
    if (statusStr.contains('doing')) {
      return AppColors.warning.withValues(alpha: 0.1);
    }
    return AppColors.neutral100;
  }

  Color _getStatusBorderColor(dynamic status) {
    final statusStr = status?.toString() ?? 'unknown';
    if (statusStr.contains('done')) {
      return AppColors.success.withValues(alpha: 0.3);
    }
    if (statusStr.contains('doing')) {
      return AppColors.warning.withValues(alpha: 0.3);
    }
    return AppColors.neutral300;
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
              Navigator.of(dialogContext).pop(); // ダイアログを閉じる
              try {
                final taskRepository = ref.read(taskRepositoryProvider);
                await taskRepository.deleteTask(task.id.value);

                // タスク一覧をリフレッシュ
                ref.invalidate(tasksByMilestoneProvider(task.milestoneId));

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('タスクを削除しました')));
                  // 親画面（マイルストーン詳細）に戻る
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
}
