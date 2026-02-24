import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../utils/date_formatter.dart';

class TaskEditFormWidget extends StatelessWidget {
  final String taskId;
  final String title;
  final String description;
  final DateTime deadline;
  final bool isLoading;
  final Function(String) onTitleChanged;
  final Function(String) onDescriptionChanged;
  final Function(DateTime) onDeadlineSelected;
  final VoidCallback onSubmit;

  const TaskEditFormWidget({
    super.key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.isLoading,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onDeadlineSelected,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildFormFields(),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      // タイトル
      Text('タスク名（具体的な作業・行動内容）', style: AppTextStyles.labelLarge),
      CustomTextField(
        key: ValueKey('title_$taskId'),
        hintText: 'タスク名を入力（100文字以内）',
        initialValue: title,
        maxLength: 100,
        onChanged: onTitleChanged,
      ),
      SizedBox(height: Spacing.medium),

      // 説明
      Text('タスクの詳細（任意）', style: AppTextStyles.labelLarge),
      CustomTextField(
        key: ValueKey('description_$taskId'),
        hintText: 'タスクの詳細を入力（500文字以内、任意）',
        initialValue: description,
        maxLength: 500,
        onChanged: onDescriptionChanged,
        multiline: true,
      ),
      SizedBox(height: Spacing.medium),

      // 期限
      _TaskEditDeadlineField(
        selectedDeadline: deadline,
        onDeadlineSelected: onDeadlineSelected,
      ),
      SizedBox(height: Spacing.large),

      // ボタン
      _TaskEditActions(onSubmit: onSubmit, isLoading: isLoading),
    ];
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
              borderRadius: BorderRadius.circular(Radii.medium),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                SizedBox(width: Spacing.small),
                Expanded(
                  child: Text(
                    DateFormatter.toJapaneseDate(selectedDeadline),
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
            onPressed: isLoading ? null : () => context.pop(),
            type: ButtonType.secondary,
          ),
        ),
        SizedBox(width: Spacing.medium),
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
