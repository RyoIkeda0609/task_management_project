import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../widgets/common/custom_button.dart';
import '../../utils/validation_helper.dart';
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
            // タスク情報
            Text(task.title.value, style: AppTextStyles.headlineMedium),
            SizedBox(height: Spacing.medium),

            Text('タスクの説明', style: AppTextStyles.labelLarge),
            SizedBox(height: Spacing.xSmall),
            Text(task.description.value, style: AppTextStyles.bodyMedium),
            SizedBox(height: Spacing.large),

            // 期限
            Text('期限', style: AppTextStyles.labelLarge),
            SizedBox(height: Spacing.xSmall),
            Text(_formatDate(task.deadline), style: AppTextStyles.bodyMedium),
            SizedBox(height: Spacing.large),

            // ステータス
            Text('ステータス', style: AppTextStyles.labelLarge),
            SizedBox(height: Spacing.small),
            Container(
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
                  Text(
                    _getStatusLabel(task.status),
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            SizedBox(height: Spacing.large),

            // ステータス変更ボタン
            Text('ステータスを更新', style: AppTextStyles.labelLarge),
            SizedBox(height: Spacing.small),
            Column(
              children: [
                CustomButton(
                  text: '未完了にする',
                  onPressed: () => _updateStatus(context, task, 'todo'),
                  type: ButtonType.secondary,
                  width: double.infinity,
                ),
                SizedBox(height: Spacing.small),
                CustomButton(
                  text: '進行中にする',
                  onPressed: () => _updateStatus(context, task, 'doing'),
                  type: ButtonType.secondary,
                  width: double.infinity,
                ),
                SizedBox(height: Spacing.small),
                CustomButton(
                  text: '完了にする',
                  onPressed: () => _updateStatus(context, task, 'done'),
                  type: ButtonType.primary,
                  width: double.infinity,
                ),
              ],
            ),
            SizedBox(height: Spacing.large),

            // タスク詳細情報
            Container(
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
            ),
          ],
        ),
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

  void _updateStatus(BuildContext context, Task task, String newStatus) async {
    try {
      final taskRepository = ref.read(taskRepositoryProvider);

      // ステータスの値オブジェクトを作成
      final newTaskStatus = newStatus == 'done'
          ? TaskStatus.done()
          : newStatus == 'doing'
          ? TaskStatus.doing()
          : TaskStatus.todo();

      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        deadline: task.deadline,
        status: newTaskStatus,
        milestoneId: task.milestoneId,
      );

      // タスクを保存
      await taskRepository.saveTask(updatedTask);

      // プロバイダーキャッシュを無効化
      if (mounted) {
        ref.invalidate(taskDetailProvider(widget.taskId));
        ref.invalidate(tasksByMilestoneProvider(task.milestoneId));
      }

      if (mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'ステータス更新完了',
          message: 'ステータスを「${_getStatusLabel(newStatus)}」に更新しました。',
        );
      }
    } catch (e) {
      if (mounted) {
        await ValidationHelper.handleException(
          context,
          e,
          customTitle: 'ステータス更新エラー',
          customMessage: 'ステータスの更新に失敗しました。',
        );
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
}
