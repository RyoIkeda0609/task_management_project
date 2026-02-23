import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../home/home_view_model.dart';
import '../../../../application/providers/use_case_providers.dart';
import '../../../../domain/entities/task.dart';
import '../../../../domain/value_objects/task/task_status.dart';
import '../../../utils/date_formatter.dart';

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
        Text(
          DateFormatter.toJapaneseDate(task.deadline.value),
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
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
    final changeTaskStatusUseCase = ref.read(changeTaskStatusUseCaseProvider);
    await changeTaskStatusUseCase(task.itemId.value);

    // State を再取得 - すべての Task Provider と進捗 Provider を invalidate
    ref.invalidate(taskDetailProvider(task.itemId.value));
    ref.invalidate(tasksByMilestoneProvider(task.milestoneId.value));
    ref.invalidate(todayTasksProvider);
    ref.invalidate(goalsProvider);
    ref.invalidate(goalProgressProvider);
    ref.invalidate(homeViewModelProvider);
  }

  String _getStatusLabel(TaskStatus status) {
    return switch (status) {
      TaskStatus.todo => '未完了',
      TaskStatus.doing => '進行中',
      TaskStatus.done => '完了',
    };
  }

  IconData _getStatusIcon(TaskStatus status) {
    return switch (status) {
      TaskStatus.done => Icons.check_circle,
      TaskStatus.doing => Icons.radio_button_checked,
      TaskStatus.todo => Icons.radio_button_unchecked,
    };
  }

  Color _getStatusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.done => AppColors.success,
      TaskStatus.doing => AppColors.warning,
      TaskStatus.todo => AppColors.neutral400,
    };
  }

  Color _getStatusBackgroundColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.done => AppColors.success.withValues(alpha: 0.1),
      TaskStatus.doing => AppColors.warning.withValues(alpha: 0.1),
      TaskStatus.todo => AppColors.neutral100,
    };
  }

  Color _getStatusBorderColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.done => AppColors.success.withValues(alpha: 0.3),
      TaskStatus.doing => AppColors.warning.withValues(alpha: 0.3),
      TaskStatus.todo => AppColors.neutral300,
    };
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
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          SizedBox(height: Spacing.medium),
          Text('エラーが発生しました', style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }
}
