import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../../application/providers/use_case_providers.dart';
import '../../../../domain/entities/task.dart';

// ============ Header Widget ============

class TaskDetailHeaderWidget extends StatelessWidget {
  final Task task;

  const TaskDetailHeaderWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
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
}

class TaskDetailDeadlineWidget extends StatelessWidget {
  final Task task;

  const TaskDetailDeadlineWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('期限', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.xSmall),
        Text(_formatDate(task.deadline), style: AppTextStyles.bodyMedium),
      ],
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
}

class TaskDetailStatusWidget extends ConsumerWidget {
  final Task task;
  final String source;

  const TaskDetailStatusWidget({
    super.key,
    required this.task,
    required this.source,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ステータス', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.small),
        InkWell(
          onTap: () => _changeTaskStatus(ref),
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
        ),
      ],
    );
  }

  Future<void> _changeTaskStatus(WidgetRef ref) async {
    try {
      final changeTaskStatusUseCase = ref.read(changeTaskStatusUseCaseProvider);
      await changeTaskStatusUseCase(task.id.value);

      // State を再取得 - すべての Task Provider と進捗 Provider を invalidate
      ref.invalidate(taskDetailProvider(task.id.value));
      ref.invalidate(tasksByMilestoneProvider(task.milestoneId));
      ref.invalidate(todayTasksProvider);
      ref.invalidate(goalsProvider);
      ref.invalidate(goalProgressProvider);
    } catch (e) {
      rethrow;
    }
  }

  String _getStatusLabel(dynamic status) {
    final statusStr = status.toString();
    if (statusStr.contains('todo')) return '未完了';
    if (statusStr.contains('doing')) return '進行中';
    if (statusStr.contains('done')) return '完了';
    return statusStr;
  }

  IconData _getStatusIcon(dynamic status) {
    final statusStr = status.toString();
    if (statusStr.contains('done')) return Icons.check_circle;
    if (statusStr.contains('doing')) return Icons.radio_button_checked;
    return Icons.radio_button_unchecked;
  }

  Color _getStatusColor(dynamic status) {
    final statusStr = status.toString();
    if (statusStr.contains('done')) return AppColors.success;
    if (statusStr.contains('doing')) return AppColors.warning;
    return AppColors.neutral400;
  }

  Color _getStatusBackgroundColor(dynamic status) {
    final statusStr = status.toString();
    if (statusStr.contains('done')) {
      return AppColors.success.withValues(alpha: 0.1);
    }
    if (statusStr.contains('doing')) {
      return AppColors.warning.withValues(alpha: 0.1);
    }
    return AppColors.neutral100;
  }

  Color _getStatusBorderColor(dynamic status) {
    final statusStr = status.toString();
    if (statusStr.contains('done')) {
      return AppColors.success.withValues(alpha: 0.3);
    }
    if (statusStr.contains('doing')) {
      return AppColors.warning.withValues(alpha: 0.3);
    }
    return AppColors.neutral300;
  }
}

class TaskDetailInfoWidget extends StatelessWidget {
  final Task task;

  const TaskDetailInfoWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
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
}

class TaskDetailErrorWidget extends StatelessWidget {
  final Object error;

  const TaskDetailErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
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
