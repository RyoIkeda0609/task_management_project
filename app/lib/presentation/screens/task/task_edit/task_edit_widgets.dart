import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../state_management/providers/app_providers.dart';
import 'task_edit_view_model.dart';

class TaskEditFormWidget extends ConsumerWidget {
  final String taskId;
  final VoidCallback onSubmit;
  final String taskTitle;
  final String taskDescription;
  final DateTime taskDeadline;

  const TaskEditFormWidget({
    super.key,
    required this.taskId,
    required this.onSubmit,
    required this.taskTitle,
    required this.taskDescription,
    required this.taskDeadline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskEditViewModelProvider);
    final viewModel = ref.read(taskEditViewModelProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル入力
            Text('タスク名 *', style: AppTextStyles.labelLarge),
            SizedBox(height: Spacing.small),
            CustomTextField(
              key: ValueKey('title_${state.title}'),
              label: 'タスク名を入力してください',
              initialValue: state.taskId == taskId ? state.title : taskTitle,
              onChanged: viewModel.updateTitle,
            ),
            SizedBox(height: Spacing.medium),

            // 説明入力
            Text(
              'タスクの説明 （任意）',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: Spacing.small),
            CustomTextField(
              key: ValueKey('description_${state.description}'),
              label: 'タスクの詳細を入力してください',
              initialValue: state.taskId == taskId
                  ? state.description
                  : taskDescription,
              onChanged: viewModel.updateDescription,
              multiline: true,
            ),
            SizedBox(height: Spacing.medium),

            // 期限選択
            _TaskEditDeadlineField(
              selectedDeadline: state.taskId == taskId
                  ? state.selectedDeadline
                  : taskDeadline,
              onDeadlineSelected: viewModel.updateDeadline,
            ),
            SizedBox(height: Spacing.large),

            // マイルストーン情報（読み取り専用）
            _TaskEditMilestoneInfo(taskId: taskId),
            SizedBox(height: Spacing.large),

            // ボタン
            _TaskEditActions(onSubmit: onSubmit, isLoading: state.isLoading),
          ],
        ),
      ),
    );
  }
}

class _TaskEditDeadlineField extends StatelessWidget {
  final DateTime selectedDeadline;
  final Function(DateTime) onDeadlineSelected;

  const _TaskEditDeadlineField({
    required this.selectedDeadline,
    required this.onDeadlineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('期限 *', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.small),
        InkWell(
          onTap: () => _selectDeadline(context),
          child: Container(
            padding: EdgeInsets.all(Spacing.medium),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                SizedBox(width: Spacing.small),
                Expanded(
                  child: Text(
                    _formatDate(selectedDeadline),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onDeadlineSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

class _TaskEditMilestoneInfo extends ConsumerWidget {
  final String taskId;

  const _TaskEditMilestoneInfo({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));

    return taskAsync.when(
      data: (task) {
        if (task == null || task.milestoneId.isEmpty) return SizedBox.shrink();

        final milestoneAsync = ref.watch(
          milestoneDetailProvider(task.milestoneId),
        );
        return milestoneAsync.when(
          data: (milestone) {
            if (milestone == null) return SizedBox.shrink();
            return Container(
              padding: EdgeInsets.all(Spacing.medium),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.flag, color: AppColors.primary, size: 20),
                  SizedBox(width: Spacing.small),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'マイルストーンに紐付けられています',
                          style: AppTextStyles.labelSmall,
                        ),
                        SizedBox(height: Spacing.xSmall),
                        Text(
                          milestone.title.value,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutral600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => Container(
            padding: EdgeInsets.all(Spacing.medium),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.flag, color: AppColors.primary, size: 20),
                SizedBox(width: Spacing.small),
                const Expanded(child: CircularProgressIndicator()),
              ],
            ),
          ),
          error: (error, stackTrace) => Container(
            padding: EdgeInsets.all(Spacing.medium),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: AppColors.error, size: 20),
                SizedBox(width: Spacing.small),
                const Expanded(child: Text('マイルストーン情報を読み込めません')),
              ],
            ),
          ),
        );
      },
      loading: () => SizedBox.shrink(),
      error: (error, stackTrace) => SizedBox.shrink(),
    );
  }
}

class _TaskEditActions extends ConsumerWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const _TaskEditActions({required this.onSubmit, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        CustomButton(
          text: 'タスクを更新',
          onPressed: isLoading ? null : onSubmit,
          width: double.infinity,
          type: ButtonType.primary,
          isLoading: isLoading,
        ),
        SizedBox(height: Spacing.small),
        CustomButton(
          text: 'キャンセル',
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          width: double.infinity,
          type: ButtonType.secondary,
        ),
      ],
    );
  }
}
