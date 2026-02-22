import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import 'task_create_view_model.dart';

class TaskCreateFormWidget extends ConsumerWidget {
  final String milestoneId;
  final String goalId;
  final VoidCallback onSubmit;

  const TaskCreateFormWidget({
    super.key,
    required this.milestoneId,
    required this.goalId,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      taskCreateViewModelProvider((milestoneId: milestoneId, goalId: goalId)),
    );
    final viewModel = ref.read(
      taskCreateViewModelProvider((
        milestoneId: milestoneId,
        goalId: goalId,
      )).notifier,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タスク名
            Text('タスク名（具体的な作業・行動内容）', style: AppTextStyles.labelLarge),
            _TaskCreateTitleField(
              title: state.title,
              onChanged: viewModel.updateTitle,
            ),
            SizedBox(height: Spacing.medium),

            // タスクの詳細
            Text('タスクの詳細（任意）', style: AppTextStyles.labelLarge),
            _TaskCreateDescriptionField(
              description: state.description,
              onChanged: viewModel.updateDescription,
            ),
            SizedBox(height: Spacing.medium),

            // 期限
            _TaskCreateDeadlineField(
              selectedDeadline: state.deadline,
              onDeadlineSelected: viewModel.updateDeadline,
            ),
            SizedBox(height: Spacing.xxxLarge),

            // アクションボタン
            _TaskCreateActions(onSubmit: onSubmit, isLoading: state.isLoading),
          ],
        ),
      ),
    );
  }
}

class _TaskCreateTitleField extends StatelessWidget {
  final String title;
  final Function(String) onChanged;

  const _TaskCreateTitleField({required this.title, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: '過去問を10周する、週に3回ジムに行くなど',
      initialValue: title,
      maxLength: 100,
      onChanged: onChanged,
    );
  }
}

class _TaskCreateDescriptionField extends StatelessWidget {
  final String description;
  final Function(String) onChanged;

  const _TaskCreateDescriptionField({
    required this.description,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: '・タスクの具体的な内容\n・タスクの完了条件\n・注意点やポイントなど',
      initialValue: description,
      maxLength: 500,
      onChanged: onChanged,
      multiline: true,
    );
  }
}

class _TaskCreateDeadlineField extends StatelessWidget {
  final DateTime selectedDeadline;
  final Function(DateTime) onDeadlineSelected;

  const _TaskCreateDeadlineField({
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

class _TaskCreateActions extends ConsumerWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const _TaskCreateActions({required this.onSubmit, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'キャンセル',
            onPressed: isLoading ? null : () => context.pop(),
            type: ButtonType.secondary,
          ),
        ),
        SizedBox(width: Spacing.medium),
        Expanded(
          child: CustomButton(
            text: '作成',
            onPressed: isLoading ? null : onSubmit,
            type: ButtonType.primary,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
