import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
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
            // タイトル
            Text('タスク名（具体的な作業・行動内容）', style: AppTextStyles.labelLarge),
            CustomTextField(
              key: ValueKey('title_$taskId'),
              hintText: 'タスク名を入力（100文字以内）',
              initialValue: state.taskId == taskId ? state.title : taskTitle,
              maxLength: 100,
              onChanged: viewModel.updateTitle,
            ),
            SizedBox(height: Spacing.medium),

            // 説明
            Text('タスクの詳細（任意）', style: AppTextStyles.labelLarge),
            CustomTextField(
              key: ValueKey('description_$taskId'),
              hintText: 'タスクの詳細を入力（500文字以内、任意）',
              initialValue: state.taskId == taskId
                  ? state.description
                  : taskDescription,
              maxLength: 500,
              onChanged: viewModel.updateDescription,
              multiline: true,
            ),
            SizedBox(height: Spacing.medium),

            // 期限
            _TaskEditDeadlineField(
              selectedDeadline: state.taskId == taskId
                  ? state.selectedDeadline
                  : taskDeadline,
              onDeadlineSelected: viewModel.updateDeadline,
            ),
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
        Text('期限', style: AppTextStyles.labelLarge),
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
    final firstDate = DateTime.now().add(const Duration(days: 1));
    final initialDate = selectedDeadline.isBefore(firstDate)
        ? firstDate
        : selectedDeadline;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
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

class _TaskEditActions extends ConsumerWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const _TaskEditActions({required this.onSubmit, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'キャンセル',
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
            type: ButtonType.secondary,
          ),
        ),
        SizedBox(width: Spacing.small),
        Expanded(
          child: CustomButton(
            text: '更新',
            onPressed: isLoading ? null : onSubmit,
            type: ButtonType.primary,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
